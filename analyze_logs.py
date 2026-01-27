import glob
import os
import json
import csv
import re
import subprocess
import urllib.request
import time
from datetime import datetime

# Configuration
try:
    with open("config.json", "r") as f:
        config = json.load(f)
        LOG_DIR = config.get("LOG_DIR", r"c:\PERSONAL\BANCO_DE_DADOS\LOGS_EDI")
except Exception as e:
    print(f"Warning: Could not load config.json. Using default path. Error: {e}")
    LOG_DIR = r"c:\PERSONAL\BANCO_DE_DADOS\LOGS_EDI"

OUTPUT_SUCCESS_CSV = "relatorio_sucesso.csv"
OUTPUT_ERROR_CSV = "relatorio_erro.csv"
OUTPUT_HTML = "relatorio_analise.html"

def parse_date(date_str):
    """
    Parses date string format ddmmyyyyHHmm to YYYY-MM-DD HH:MM
    Example: 051220250941 -> 2025-12-05 09:41
    """
    if not date_str or len(date_str) < 12:
        return date_str
    try:
        # Assuming format ddMMyyyyHHmm based on "051220250941"
        dt = datetime.strptime(date_str[:12], "%d%m%Y%H%M")
        return dt.strftime("%Y-%m-%d %H:%M")
    except ValueError:
        return date_str

def get_sap_data(cnpjs):
    """
    Queries SAP OCRD table for given CNPJs.
    Returns dict: { cnpj: {'CardCode': ..., 'CardName': ..., 'GroupName': ...} }
    """
    if not cnpjs:
        return {}
        
    print(f"Consultando SAP para {len(cnpjs)} CNPJs...")
    
    # helper to strip non-digits
    def clean_cnpj(c):
        return re.sub(r'\D', '', str(c))
        
    cleaned_cnpjs = set(clean_cnpj(c) for c in cnpjs if c)
    if not cleaned_cnpjs:
        return {}

    # Format CNPJs for SQL IN Clause
    cnpj_list_sql = ", ".join([f"'{c}'" for c in cleaned_cnpjs])
    
    # Robust Query: Join OCRD and OCRG to get GroupName
    # T0 = OCRD, T1 = OCRG
    query = f"SELECT T0.CardFName, T0.CardCode, T0.CardName, T1.GroupName FROM OCRD T0 LEFT JOIN OCRG T1 ON T0.GroupCode = T1.GroupCode WHERE REPLACE(REPLACE(REPLACE(T0.CardFName, '.', ''), '/', ''), '-', '') IN ({cnpj_list_sql})"
    
    # Call PowerShell ExecQuery.ps1
    cmd = [
        "powershell", 
        "-File", "ExecQuery.ps1", 
        "-SQLQuery", query
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        output = result.stdout.strip()
        
        json_start = output.find('[')
        json_end = output.rfind(']')
        
        if json_start != -1 and json_end != -1:
            json_str = output[json_start:json_end+1]
            data = json.loads(json_str)
            
            enrichment_map = {}
            for item in data:
                # Normalize key from DB to match our log CNPJs
                raw_cnpj = clean_cnpj(item.get('CardFName', ''))
                if raw_cnpj:
                    enrichment_map[raw_cnpj] = {
                        'CardCode': item.get('CardCode'),
                        'CardName': item.get('CardName'),
                        'GroupName': item.get('GroupName')
                    }
            return enrichment_map
            
    except Exception as e:
        print(f"Erro ao consultar SAP: {e}")
        # print("Output:", result.stdout if 'result' in locals() else "N/A")
        
    return {}

def get_api_data(cnpj):
    """
    Queries BrasilAPI for CNPJ data.
    """
    url = f"https://brasilapi.com.br/api/cnpj/v1/{cnpj}"
    try:
        with urllib.request.urlopen(url) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                return data.get('razao_social') or data.get('nome_fantasia')
    except Exception:
        pass
    return None

def analyze_logs():
    print(f"Buscando logs em: {LOG_DIR}")
    log_files = glob.glob(os.path.join(LOG_DIR, "*.log"))
    
    seen_errors = set() 
    cnpj_stats = {} # { cnpj: { 'success': 0, 'error': 0, 'name': '', 'code': '', 'group': '', 'errors': {} } }
    success_list = []
    error_list = []
    
    total_processed = 0
    total_raw_errors = 0
    
    for log_file in log_files:
        filename = os.path.basename(log_file)
        
        try:
            with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
                for line in f:
                    if "gravaLog(" in line:
                        json_start = line.find('{')
                        if json_start == -1: continue
                        
                        metadata_str = line[:json_start]
                        
                        grava_index = metadata_str.find("gravaLog(")
                        if grava_index != -1:
                            inner_meta = metadata_str[grava_index + 9:]
                            meta_parts = inner_meta.split(',')
                            if len(meta_parts) >= 2:
                                status = meta_parts[1].strip()
                                error_msg = meta_parts[2].strip() if len(meta_parts) > 2 else ""
                            else:
                                status = "Unknown"
                                error_msg = ""
                        else:
                            status = "Unknown"
                            error_msg = ""

                        json_end = line.rfind('}')
                        if json_end == -1: continue
                            
                        json_str = line[json_start : json_end + 1]
                        
                        try:
                            payload = json.loads(json_str)
                            cabecalho = payload.get("cabecalho", {})
                            cnpj = cabecalho.get("cnpjComprador", "Desconhecido")
                            dhe = cabecalho.get("dataHoraEmissao", "")
                            nf = cabecalho.get("numeroPedidoComprador", "")
                            
                            formatted_date = parse_date(dhe)
                            
                            row = {
                                "Arquivo": filename,
                                "Status": status,
                                "CNPJ": cnpj,
                                "DataEmissao": formatted_date,
                                "Pedido": nf,
                                "InfoOriginal": dhe
                            }
                            
                            # Initialize CNPJ entry
                            if cnpj not in cnpj_stats:
                                cnpj_stats[cnpj] = {'success': 0, 'error': 0, 'name': 'Desconhecido', 'code': '', 'group': 'Não Identificado', 'errors': {}}

                            if status == "Sucesso":
                                success_list.append(row)
                                cnpj_stats[cnpj]['success'] += 1
                            elif status == "Erro":
                                total_raw_errors += 1
                                error_key = (cnpj, nf)
                                if error_key not in seen_errors:
                                    seen_errors.add(error_key)
                                    error_list.append(row)
                                    cnpj_stats[cnpj]['error'] += 1
                                    
                                    # Track Error Type
                                    clean_msg = error_msg.replace('"', '').replace("'", "")
                                    # Simple classification based on common errors or just raw message
                                    # We'll use the raw message but truncated if too long
                                    short_msg = (clean_msg[:50] + '..') if len(clean_msg) > 50 else clean_msg
                                    if short_msg not in cnpj_stats[cnpj]['errors']:
                                        cnpj_stats[cnpj]['errors'][short_msg] = 0
                                    cnpj_stats[cnpj]['errors'][short_msg] += 1
                                
                            total_processed += 1
                            
                        except json.JSONDecodeError:
                            pass
                            
        except Exception as e:
            print(f"Erro ao ler arquivo {filename}: {e}")

    # Enrichment Step
    print("Iniciando enriquecimento de dados...")
    unique_cnpjs = [c for c in cnpj_stats.keys() if c != "Desconhecido"]
    
    # 1. SAP Query
    sap_data = get_sap_data(unique_cnpjs)
    
    # 2. Enrich and Fallback
    for cnpj in unique_cnpjs:
        if cnpj in sap_data:
            cnpj_stats[cnpj]['name'] = sap_data[cnpj]['CardName']
            cnpj_stats[cnpj]['code'] = sap_data[cnpj]['CardCode']
            cnpj_stats[cnpj]['group'] = sap_data[cnpj]['GroupName'] if sap_data[cnpj]['GroupName'] else "Sem Grupo SAP"
        else:
            # Fallback to API
            print(f"CNPJ {cnpj} não encontrado no SAP. Buscando na API...")
            api_name = get_api_data(cnpj)
            
            cnpj_stats[cnpj]['code'] = "API"
            cnpj_stats[cnpj]['group'] = "Outros (API)"
            
            if api_name:
                cnpj_stats[cnpj]['name'] = api_name
            else:
                # Fallback to CNPJ number if API name not found
                cnpj_stats[cnpj]['name'] = f"CNPJ: {cnpj}"
                
            time.sleep(0.5) 

    print(f"Total processado: {total_processed}")
    print(f"Sucessos: {len(success_list)}")
    print(f"Erros encontrados (Cru): {total_raw_errors}")
    print(f"Erros Únicos (Deduplicados): {len(error_list)}")

    # Aggregate by Group -> Client Code
    # structure: { 'GroupName': { 'total_success': 0, 'total_error': 0, 'clients': { 'CardCode': { ... } } } }
    group_stats = {}
    
    for cnpj, stats in cnpj_stats.items():
        grp = stats['group']
        code = stats['code'] if stats['code'] else "SEM_CODIGO"
        
        if grp not in group_stats:
            group_stats[grp] = {'total_success': 0, 'total_error': 0, 'clients': {}}
            
        # Add to Group Totals
        group_stats[grp]['total_success'] += stats['success']
        group_stats[grp]['total_error'] += stats['error']
        
        # Aggregate to Client Level (within Group)
        if code not in group_stats[grp]['clients']:
            group_stats[grp]['clients'][code] = {
                'name': stats['name'], 
                'success': 0, 
                'error': 0, 
                'error_types': {}
            }
        
        client = group_stats[grp]['clients'][code]
        client['success'] += stats['success']
        client['error'] += stats['error']
        
        for msg, count in stats['errors'].items():
            if msg not in client['error_types']:
                client['error_types'][msg] = 0
            client['error_types'][msg] += count
            
    # Write CSVs
    with open(OUTPUT_SUCCESS_CSV, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Arquivo", "Status", "CNPJ", "DataEmissao", "Pedido", "InfoOriginal"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(success_list)
        
    with open(OUTPUT_ERROR_CSV, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Arquivo", "Status", "CNPJ", "DataEmissao", "Pedido", "InfoOriginal"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(error_list)
        
    with open("relatorio_por_cnpj.csv", 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["CNPJ", "Nome Cliente", "Cod SAP", "Grupo", "Sucessos", "Erros (Unicos)"])
        for cnpj, stats in cnpj_stats.items():
            writer.writerow([cnpj, stats['name'], stats['code'], stats['group'], stats['success'], stats['error']])
        
    # Generate HTML
    generate_html_accordion(len(success_list), len(error_list), total_raw_errors, group_stats)

def generate_html_accordion(success_count, error_count, raw_error_count, group_stats):
    total_unique = success_count + error_count
    rate = (success_count / total_unique * 100) if total_unique > 0 else 0
    
    # Prepare Data for JS
    # Structure: [ { groupName: "X", totalSuccess: 10, totalError: 5, clients: [ { label: "", success: 0, error: 0, error_types: {} } ] } ]
    
    groups_data = []
    
    # Sort groups by total error desc
    sorted_groups = sorted(group_stats.items(), key=lambda x: x[1]['total_error'], reverse=True)
    
    for grp_name, stats in sorted_groups:
        clients_list = []
        # Sort clients within group by error desc
        sorted_clients = sorted(stats['clients'].items(), key=lambda x: x[1]['error'], reverse=True)
        
        for code, cli_stats in sorted_clients:
            clients_list.append({
                'label': f"[{code}] {cli_stats['name']}",
                'success': cli_stats['success'],
                'error': cli_stats['error'],
                'error_types': cli_stats['error_types']
            })
            
        groups_data.append({
            'groupName': grp_name,
            'totalSuccess': stats['total_success'],
            'totalError': stats['total_error'],
            'clients': clients_list
        })
        
    json_groups = json.dumps(groups_data)
    
    html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Relatório EDI por Grupo</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; }}
        .header {{ text-align: center; margin-bottom: 30px; }}
        
        /* Summary Card with Doughnut */
        .summary-card {{ background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: flex; justify-content: center; align-items: center; max-width: 900px; margin: 0 auto 30px auto; gap: 50px; }}
        
        .chart-container-doughnut {{ width: 250px; height: 250px; }}
        
        .metrics-container {{ display: flex; flex-direction: column; justify-content: center; gap: 15px; text-align: left; }}
        .metric-row {{ font-size: 16px; color: #555; }}
        .metric-value {{ font-weight: bold; font-size: 20px; }}
        .metric-large {{ font-size: 24px; font-weight: bold; border-top: 1px solid #eee; padding-top: 10px; margin-top: 5px; }}
        
        /* Accordion Styles */
        .group-container {{ max-width: 1000px; margin: 0 auto; }}
        .group-card {{ background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 15px; overflow: hidden; }}
        .group-header {{ padding: 20px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; border-left: 5px solid #ddd; transition: background 0.2s; }}
        .group-header:hover {{ background-color: #f9f9f9; }}
        .group-header.has-error {{ border-left-color: #FF6384; }}
        .group-header.all-success {{ border-left-color: #4BC0C0; }}
        
        .group-info h3 {{ margin: 0 0 5px 0; font-size: 18px; }}
        .group-stats {{ font-size: 14px; color: #555; }}
        .toggle-icon {{ font-size: 20px; color: #999; transition: transform 0.3s; }}
        .group-card.active .toggle-icon {{ transform: rotate(180deg); }}
        
        .group-content {{ display: none; padding: 20px; border-top: 1px solid #eee; background-color: #fafafa; position: relative; }}
        .group-card.active .group-content {{ display: block; }}
        
        .chart-wrapper {{ position: relative; height: 300px; width: 100%; }}
        .btn-load {{ background-color: #36A2EB; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; margin-top: 10px; display: none; }}
        .btn-load:hover {{ background-color: #2481BA; }}
        
        /* Tooltip for Errors */
        .error-detail-tooltip {{
            position: absolute;
            background: rgba(0, 0, 0, 0.85);
            color: white;
            padding: 10px;
            border-radius: 4px;
            font-size: 12px;
            pointer-events: none;
            z-index: 100;
            max-width: 300px;
            display: none;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }}
        .error-detail-header {{ font-weight: bold; margin-bottom: 5px; border-bottom: 1px solid #555; padding-bottom: 3px; }}
        .error-item {{ display: flex; justify-content: space-between; margin-bottom: 2px; }}
        .error-count {{ font-weight: bold; color: #FF6384; margin-right: 10px; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Relatório de Análise EDI (Agrupado)</h1>
    </div>

    <div class="summary-card">
        <div class="chart-container-doughnut">
            <canvas id="doughnutChart"></canvas>
        </div>
        <div class="metrics-container">
            <div class="metric-row">Total de Transações: <span class="metric-value">{total_unique}</span></div>
            <div class="metric-row">Sucessos: <span class="metric-value" style="color: #4BC0C0;">{success_count}</span></div>
            <div class="metric-row">Erros Únicos: <span class="metric-value" style="color: #FF6384;">{error_count}</span></div>
            <div class="metric-row" style="font-size: 12px; color: #999;">(Erros Totais com Retentativas: {raw_error_count})</div>
            <div class="metric-large">Taxa de Sucesso: {rate:.2f}%</div>
        </div>
    </div>

    <div class="group-container" id="groupsContainer">
        <!-- JS will render groups here -->
    </div>
    
    <!-- Global Tooltip Container -->
    <div id="customTooltip" class="error-detail-tooltip"></div>

    <script>
        const groupsData = {json_groups};
        const PAGE_SIZE = 10;
        
        // --- Doughnut Chart ---
        new Chart(document.getElementById('doughnutChart').getContext('2d'), {{
            type: 'doughnut',
            data: {{
                labels: ['Sucesso', 'Erros'],
                datasets: [{{
                    data: [{success_count}, {error_count}],
                    backgroundColor: ['#4BC0C0', '#FF6384'],
                    hoverOffset: 4
                }}]
            }},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {{
                    legend: {{ position: 'bottom' }}
                }}
            }}
        }});
        
        // Render Group List
        const container = document.getElementById('groupsContainer');
        const tooltip = document.getElementById('customTooltip');
        
        groupsData.forEach((grp, index) => {{
            const card = document.createElement('div');
            card.className = 'group-card ' + (grp.totalError > 0 ? 'active-border' : ''); // Optional Logic
            
            // Border Color Logic handled by class binding above slightly modified
            const borderClass = grp.totalError > 0 ? 'has-error' : 'all-success';
            
            card.innerHTML = `
                <div class="group-header ${{borderClass}}" onclick="toggleGroup(${{index}})">
                    <div class="group-info">
                        <h3>${{grp.groupName}}</h3>
                        <div class="group-stats">
                            Sucesso: <b>${{grp.totalSuccess}}</b> | Erros: <b style="color: ${{grp.totalError > 0 ? '#FF6384' : '#666'}}">${{grp.totalError}}</b>
                        </div>
                    </div>
                    <div class="toggle-icon">▼</div>
                </div>
                <div class="group-content" id="content-${{index}}">
                    <div class="chart-wrapper">
                        <canvas id="chart-${{index}}"></canvas>
                    </div>
                    <button class="btn-load" id="btn-${{index}}" onclick="loadMore(${{index}})">Carregar Mais (10)</button>
                </div>
            `;
            container.appendChild(card);
            
            // Initialize runtime state for pagination
            grp.visualIndex = 0;
            grp.chartInstance = null;
        }});

        function toggleGroup(index) {{
            const content = document.getElementById(`content-${{index}}`);
            const card = content.parentElement;
            
            if (content.style.display === 'block') {{
                content.style.display = 'none';
                card.classList.remove('active');
            }} else {{
                content.style.display = 'block';
                card.classList.add('active');
                
                // Init Chart if first time
                const grp = groupsData[index];
                if (!grp.chartInstance) {{
                    initChart(index);
                    loadMore(index); // Load initial batch
                }}
            }}
        }}

        function initChart(index) {{
            const ctx = document.getElementById(`chart-${{index}}`).getContext('2d');
            groupsData[index].chartInstance = new Chart(ctx, {{
                type: 'bar',
                data: {{
                    labels: [],
                    datasets: [
                        {{ label: 'Sucessos', data: [], backgroundColor: '#4BC0C0' }},
                        {{ label: 'Erros', data: [], backgroundColor: '#FF6384' }}
                    ]
                }},
                options: {{
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {{ x: {{ stacked: true }}, y: {{ stacked: true }} }},
                    plugins: {{ 
                        legend: {{ position: 'bottom' }},
                        tooltip: {{
                            enabled: false, // Disable default tooltip
                            external: function(context) {{
                                // Tooltip Element
                                const tooltipEl = document.getElementById('customTooltip');

                                // Hide if no tooltip
                                const tooltipModel = context.tooltip;
                                if (tooltipModel.opacity === 0) {{
                                    tooltipEl.style.display = 'none';
                                    return;
                                }}

                                // Set Text
                                if (tooltipModel.body) {{
                                    const dataIndex = tooltipModel.dataPoints[0].dataIndex;
                                    const datasetIndex = tooltipModel.dataPoints[0].datasetIndex;
                                    
                                    // Identify Client
                                    const grp = groupsData[index];
                                    const client = grp.clients[dataIndex];
                                    
                                    if (datasetIndex === 1 && client.error > 0) {{ // Is Error Bar
                                        let innerHtml = `<div class="error-detail-header">${{client.label}}</div>`;
                                        innerHtml += `<div style="margin-bottom:5px; color:#FF6384; font-weight:bold;">Erros: ${{client.error}}</div>`;
                                        
                                        for (const [msg, count] of Object.entries(client.error_types)) {{
                                            innerHtml += `
                                                <div class="error-item">
                                                    <span style="width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: inline-block;">${{msg}}</span>
                                                    <span class="error-count">${{count}}</span>
                                                </div>`;
                                        }}
                                        tooltipEl.innerHTML = innerHtml;
                                    }} else {{
                                        // Standard Success Tooltip
                                         tooltipEl.innerHTML = `
                                            <div class="error-detail-header">${{client.label}}</div>
                                            <div>Sucessos: ${{client.success}}</div>
                                        `;
                                    }}
                                }}

                                // Position
                                const position = context.chart.canvas.getBoundingClientRect();
                                
                                tooltipEl.style.display = 'block';
                                tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
                                tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
                            }}
                        }}
                    }},
                    onClick: (e) => {{
                        // Optional: Keep tooltip open on click or do something else
                        // For now hover is sufficient as requested "Ao clicar... expandir e detalhar"
                        // But since chart.js tooltips are hover-based, let's implement a 'sticky' 
                        // behavior or just rely on the custom tooltip we just built which is quite detailed.
                    }}
                }}
            }});
        }}

        function loadMore(index) {{
            const grp = groupsData[index];
            const nextBatch = grp.clients.slice(grp.visualIndex, grp.visualIndex + PAGE_SIZE);
            
            if (nextBatch.length === 0) return;
            
            const chart = grp.chartInstance;
            
            nextBatch.forEach(client => {{
                chart.data.labels.push(client.label);
                chart.data.datasets[0].data.push(client.success);
                chart.data.datasets[1].data.push(client.error);
            }});
            
            grp.visualIndex += nextBatch.length;
            chart.update();
            
            // Resize logic
            const newHeight = grp.visualIndex * 40 + 50; // 40px per bar + padding
            if (newHeight > 300) {{
                document.querySelector(`#content-${{index}} .chart-wrapper`).style.height = newHeight + 'px';
            }}
            
            // Toggle Button
            const btn = document.getElementById(`btn-${{index}}`);
            if (grp.visualIndex < grp.clients.length) {{
                btn.style.display = 'inline-block';
            }} else {{
                btn.style.display = 'none';
            }}
        }}
    </script>
</body>
</html>
    """
    
    with open(OUTPUT_HTML, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"HTML gerado: {OUTPUT_HTML}")

if __name__ == "__main__":
    analyze_logs()
