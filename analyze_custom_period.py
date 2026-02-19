import glob
import os
import json
import csv
import re
import paramiko
import time
from datetime import datetime, timedelta
import sys

# Add edi_dashboard to path to import lib.database
sys.path.append(os.path.join(os.path.dirname(__file__), 'edi_dashboard'))
try:
    from lib.database import run_sql
except ImportError:
    print("AVISO: Não foi possível importar lib.database. Verifique o caminho.")
    run_sql = None

# Remote Configuration
SSH_HOST = "192.168.1.244"
SSH_USER = "root"
SSH_PASS = "Rust0n@2023@"
REMOTE_LOG_DIR = "/SPS/PRD/integracao_neogrid/logs"
LOG_DIR = r"c:\PERSONAL\BANCO_DE_DADOS\LOGS_EDI"
OUTPUT_SUCCESS_CSV = "relatorio_sucesso.csv"
OUTPUT_ERROR_CSV = "relatorio_erro.csv"
OUTPUT_HTML = "relatorio_analise.html"
CNPJ_CACHE_FILE = "cnpj_cache.json"

# Global Cache
_cnpj_cache = {}

def load_cache():
    global _cnpj_cache
    if os.path.exists(CNPJ_CACHE_FILE):
        try:
            with open(CNPJ_CACHE_FILE, 'r', encoding='utf-8') as f:
                _cnpj_cache = json.load(f)
        except:
            _cnpj_cache = {}

def save_cache():
    try:
        with open(CNPJ_CACHE_FILE, 'w', encoding='utf-8') as f:
            json.dump(_cnpj_cache, f, ensure_ascii=False, indent=2)
    except:
        pass

def parse_date(date_str):
    if not date_str or len(date_str) < 12:
        return date_str
    try:
        dt = datetime.strptime(date_str[:12], "%d%m%Y%H%M")
        return dt.strftime("%Y-%m-%d %H:%M")
    except ValueError:
        return date_str

def get_api_data(cnpj):
    global _cnpj_cache
    
    # Clean CNPJ
    clean_cnpj = re.sub(r'[^0-9]', '', cnpj)
    
    if clean_cnpj in _cnpj_cache:
        return _cnpj_cache[clean_cnpj]
        
    try:
        import urllib.request
        url = f"https://publica.cnpj.ws/cnpj/{clean_cnpj}"
        with urllib.request.urlopen(url) as response:
            if response.getcode() == 200:
                data = json.loads(response.read().decode())
                razao = data.get('razao_social', '')
                fantasia = data.get('estabelecimento', {}).get('nome_fantasia', '')
                name = fantasia if fantasia else razao
                _cnpj_cache[clean_cnpj] = name
                save_cache()
                return name
    except Exception as e:
        print(f"Erro API ({cnpj}): {e}")
        
    return None

def get_sap_data(cnpj_list):
    if not run_sql:
        return {}
    
    print(f"Preparando consulta SAP para {len(cnpj_list)} CNPJs...")

    # Map candidate variations to original CNPJ for final lookup
    candidate_map = {}
    for c in cnpj_list:
        raw = re.sub(r'[^0-9]', '', str(c))
        if not raw: continue
        
        # Add exact match
        candidate_map[raw] = c
        # Add padded (14 digits)
        padded = raw.zfill(14)
        candidate_map[padded] = c
        # Add trimmed (remove leading zeros) just in case SAP stores as int/string without zeros
        trimmed = raw.lstrip('0')
        if trimmed:
             candidate_map[trimmed] = c

    candidates = list(candidate_map.keys())
    if not candidates:
        return {}
        
    print(f"Buscando {len(candidates)} variações de CNPJ no SAP (Queries Otimizadas)...")
    
    chunk_size = 50
    chunks = [candidates[i:i + chunk_size] for i in range(0, len(candidates), chunk_size)]
    
    mapping = {}
    
    for chunk in chunks:
        in_clause = "', '".join(chunk)
        
        # Optimized query using REPLACE to clean potential formatting in DB
        # Querying CardFName (legacy), LicTradNum (standard), TaxId0/4 (CRD7)
        sql = f"""
        SELECT DISTINCT
            T0.CardCode, 
            T0.CardName, 
            ISNULL(T0.CardFName, '') as CardFName,
            ISNULL(T0.LicTradNum, '') as LicTradNum,
            ISNULL(T1.TaxId0, '') as TaxId0,
            ISNULL(T1.TaxId4, '') as TaxId4,
            ISNULL(T2.GroupName, 'Sem Grupo') as GroupName 
        FROM OCRD T0 
        LEFT JOIN CRD7 T1 ON T0.CardCode = T1.CardCode
        LEFT JOIN OCRG T2 ON T0.GroupCode = T2.GroupCode 
        WHERE 
             REPLACE(REPLACE(REPLACE(ISNULL(T0.CardFName,''),'.',''),'/',''),'-','') IN ('{in_clause}')
          OR REPLACE(REPLACE(REPLACE(ISNULL(T0.LicTradNum,''),'.',''),'/',''),'-','') IN ('{in_clause}')
          OR REPLACE(REPLACE(REPLACE(ISNULL(T1.TaxId0,''),'.',''),'/',''),'-','') IN ('{in_clause}')
          OR REPLACE(REPLACE(REPLACE(ISNULL(T1.TaxId4,''),'.',''),'/',''),'-','') IN ('{in_clause}')
        """
        
        try:
            results = run_sql(sql)
            if not results:
                continue
                
            for row in results:
                card_code = row.get('CardCode', '')
                stats = {
                    'CardName': row.get('CardName'),
                    'CardCode': card_code,
                    'GroupName': row.get('GroupName')
                }
                
                # Check ALL four CNPJ fields to find which candidate matched
                matched_originals = set()
                fields_to_check = [
                    row.get('CardFName', ''), 
                    row.get('LicTradNum', ''),
                    row.get('TaxId0', ''), 
                    row.get('TaxId4', '')
                ]
                
                for field in fields_to_check:
                    clean = re.sub(r'[^0-9]', '', str(field))
                    # Check both the cleaned value AND padded variants (14 digits)
                    for variant in [clean, clean.zfill(14), clean.lstrip('0')]:
                        if variant and variant in candidate_map:
                            matched_originals.add(candidate_map[variant])
                        
                # Map the *original* CNPJ requested to this result
                # Priority: prefer CardCodes starting with 'C' (clients) over vendors
                is_new_client = card_code.upper().startswith('C')
                for original in matched_originals:
                    existing = mapping.get(original, {})
                    already_has_client = existing.get('CardCode', '').upper().startswith('C')
                    if original not in mapping or (is_new_client and not already_has_client):
                        mapping[original] = stats
                    
        except Exception as e:
            print(f"Erro no chunk SAP: {e}")

    return mapping



def generate_html_accordion(success_count, error_count, raw_error_count, group_stats, target_date):
    total_unique = success_count + error_count
    rate = (success_count / total_unique * 100) if total_unique > 0 else 0
    
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
                'error_types': cli_stats['error_types'],
                'success_orders': cli_stats.get('success_orders', []),
                'error_orders': cli_stats.get('error_orders', []),
                'corrected_orders': cli_stats.get('corrected_orders', [])
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
        .header {{ text-align: center; margin-bottom: 30px; position: relative; }}
        .report-date {{ color: #777; margin-top: 5px; }}
        .header h1 {{ margin: 0; color: #333; }}
        
        .summary-card {{
            background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            margin-bottom: 30px; display: flex; align-items: center; justify-content: center; gap: 40px;
        }}
        .chart-container-doughnut {{ width: 180px; height: 180px; position: relative; }}
        .metrics-container {{ text-align: left; }}
        .metric-row {{ margin-bottom: 8px; font-size: 14px; color: #555; }}
        .metric-value {{ font-weight: bold; font-size: 16px; margin-left: 5px; }}
        .metric-large {{ font-size: 18px; font-weight: bold; margin-top: 15px; color: #333; border-top: 1px solid #eee; padding-top: 10px; }}
        
        .group-container {{ display: flex; flex-direction: column; gap: 15px; }}
        .group-card {{ background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; transition: box-shadow 0.2s; }}
        .group-card:hover {{ box-shadow: 0 4px 6px rgba(0,0,0,0.15); }}
        
        .active-border {{ border-left: 5px solid #FF6384; }}
        
        .group-header {{ 
            padding: 15px 20px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; 
            background: #fff; border-bottom: 1px solid #eee;
        }}
        .group-header:hover {{ background-color: #f9f9f9; }}
        .group-header.active {{ background-color: #f0f4f8; }}
        .group-info h3 {{ margin: 0 0 5px 0; font-size: 16px; color: #333; }}
        .group-stats {{ font-size: 13px; color: #666; }}
        
        .has-error h3 {{ color: #333; }}
        .all-success h3 {{ color: #4BC0C0; }}
        
        .toggle-icon {{ font-size: 12px; color: #999; transition: transform 0.3s; }}
        .active .toggle-icon {{ transform: rotate(180deg); }}
        
        .group-content {{ display: none; padding: 20px; background-color: #fff; }}
        .chart-wrapper {{ height: 50px; position: relative; width: 100%; transition: height 0.3s; }}
        
        .btn-load {{ 
            display: none; margin: 10px auto 0; padding: 8px 20px; background: #eee; border: none; 
            border-radius: 4px; cursor: pointer; font-size: 12px; color: #555; width: 100%;
        }}
        .btn-load:hover {{ background: #e0e0e0; }}
        
        .error-detail-tooltip {{
            position: absolute; display: none; background: rgba(255, 255, 255, 0.98); 
            border: 1px solid #ccc; padding: 10px; border-radius: 4px; pointer-events: none; 
            z-index: 1000; box-shadow: 0 4px 10px rgba(0,0,0,0.2); font-size: 12px; max-width: 350px;
        }}
        .error-detail-header {{ font-weight: bold; margin-bottom: 5px; border-bottom: 1px solid #eee; padding-bottom: 3px; }}
        .error-item {{ display: flex; justify-content: space-between; margin-bottom: 2px; }}
        .error-count {{ font-weight: bold; color: #FF6384; margin-right: 10px; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Relatório de Análise EDI (Período Personalizado)</h1>
        <div class="report-date">Período: {target_date}</div>
    </div>

    <div class="summary-card">
        <div class="chart-container-doughnut">
            <canvas id="doughnutChart"></canvas>
        </div>
        <div class="metrics-container">
            <div class="metric-row">Total de Transações: <span class="metric-value">{total_unique}</span></div>
            <div class="metric-row">Sucessos: <span class="metric-value" style="color: #4BC0C0;">{success_count}</span></div>
            <div class="metric-row">Erros Únicos: <span class="metric-value" style="color: #FF6384;">{error_count}</span></div>
            <!-- Line removed as requested -->
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
                                        
                                        // Display error order numbers
                                        if (client.error_orders && client.error_orders.length > 0) {{
                                            innerHtml += `<div style="margin-top:8px; border-top:1px solid #555; padding-top:5px;"><strong style="color:#FF6384;">Pedidos com Erro:</strong></div>`;
                                            innerHtml += `<div style="max-height:100px; overflow-y:auto; font-size:11px;">`;
                                            client.error_orders.slice(0, 10).forEach(order => {{
                                                innerHtml += `<div style="color:#FF6384;">${{order}}</div>`;
                                            }});
                                            if (client.error_orders.length > 10) {{
                                                innerHtml += `<div style="color:#888; font-style:italic;">... e mais ${{client.error_orders.length - 10}} pedidos</div>`;
                                            }}
                                            innerHtml += `</div>`;
                                        }}
                                        
                                        // Display corrected orders
                                        if (client.corrected_orders && client.corrected_orders.length > 0) {{
                                            innerHtml += `<div style="margin-top:8px; border-top:1px solid #555; padding-top:5px;"><strong style="color:#FFA500;">Pedidos Corrigidos:</strong></div>`;
                                            innerHtml += `<div style="max-height:100px; overflow-y:auto; font-size:11px;">`;
                                            client.corrected_orders.slice(0, 10).forEach(order => {{
                                                innerHtml += `<div style="color:#FFA500; font-weight:bold;">${{order}}</div>`;
                                            }});
                                            if (client.corrected_orders.length > 10) {{
                                                innerHtml += `<div style="color:#888; font-style:italic;">... e mais ${{client.corrected_orders.length - 10}} pedidos</div>`;
                                            }}
                                            innerHtml += `</div>`;
                                        }}
                                        
                                        tooltipEl.innerHTML = innerHtml;
                                    }} else {{ // Is Success Bar
                                        // Standard Success Tooltip
                                        let innerHtml = `<div class="error-detail-header">${{client.label}}</div>`;
                                        innerHtml += `<div style="margin-bottom:5px; color:#4BC0C0; font-weight:bold;">Sucessos: ${{client.success}}</div>`;
                                        
                                        // Display success order numbers
                                        if (client.success_orders && client.success_orders.length > 0) {{
                                            innerHtml += `<div style="margin-top:8px; border-top:1px solid #555; padding-top:5px;"><strong style="color:#4BC0C0;">Pedidos com Sucesso:</strong></div>`;
                                            innerHtml += `<div style="max-height:100px; overflow-y:auto; font-size:11px;">`;
                                            client.success_orders.slice(0, 10).forEach(order => {{
                                                innerHtml += `<div style="color:#4BC0C0;">${{order}}</div>`;
                                            }});
                                            if (client.success_orders.length > 10) {{
                                                innerHtml += `<div style="color:#888; font-style:italic;">... e mais ${{client.success_orders.length - 10}} pedidos</div>`;
                                            }}
                                            innerHtml += `</div>`;
                                        }}
                                        
                                        tooltipEl.innerHTML = innerHtml;
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


def analyze_period(start_date, end_date, return_data=False):
    start = datetime.strptime(start_date, "%d-%m-%Y")
    end = datetime.strptime(end_date, "%d-%m-%Y")
    
    delta = end - start
    date_list = [(start + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(delta.days + 1)]
    
    print(f"Analisando período: {start_date} a {end_date} ({len(date_list)} dias)")
    
    seen_errors = set() 
    seen_successes = set()
    cnpj_stats = {} 
    success_list = []
    error_list = []
    
    total_processed = 0
    total_raw_errors = 0
    
    ssh_client = None

    order_to_cnpj = {} # Map Order Number -> CNPJ

    for target_date in date_list:
        filename = f"{target_date}.log"
        local_path = os.path.join(LOG_DIR, filename)
        
        file_obj = None
        
        if os.path.exists(local_path):
            print(f"Lendo Log Local: {filename}")
            file_obj = open(local_path, 'r', encoding='utf-8', errors='replace')
        else:
            print(f"Log Local não encontrado: {filename}. Tentando remoto...")
            if not ssh_client:
                ssh_client = paramiko.SSHClient()
                ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                try:
                    ssh_client.connect(SSH_HOST, username=SSH_USER, password=SSH_PASS)
                except Exception as e:
                    print(f"Falha na conexão SSH: {e}")
            
            if ssh_client:
                try:
                    sftp = ssh_client.open_sftp()
                    remote_path = f"{REMOTE_LOG_DIR}/{filename}"
                    try:
                        file_obj = sftp.open(remote_path, 'r')
                        print(f"Lendo Log Remoto: {filename}")
                    except FileNotFoundError:
                        print(f"Arquivo não encontrado no servidor: {filename}")
                except Exception as e:
                    print(f"Erro SFTP: {e}")
        
        if file_obj:
            try:
                for line in file_obj:
                    if "gravaLog(" in line:
                        # Special handling for "Already Registered" errors (No JSON)
                        if "já cadastrado no SAP" in line:
                            dup_match = re.search(r'Pedido\s+(\d+)\s+já\s+cadastrado', line)
                            if dup_match:
                                nf_exist = dup_match.group(1)
                                if nf_exist in order_to_cnpj:
                                    cnpj_exist = order_to_cnpj[nf_exist]
                                    if cnpj_exist in cnpj_stats:
                                        # Treat as success (correction)
                                        cnpj_stats[cnpj_exist]['success'] += 1
                                        if nf_exist not in cnpj_stats[cnpj_exist]['success_orders']:
                                            cnpj_stats[cnpj_exist]['success_orders'].append(nf_exist)
                                            # Optional: Track as specific "corrected" event if needed
                        
                        json_start = line.find('{')
                        if json_start == -1: continue
                        
                        metadata_str = line[:json_start]
                        grava_index = metadata_str.find("gravaLog(")
                        
                        status = "Unknown"
                        error_msg = ""
                        
                        if grava_index != -1:
                            inner_meta = metadata_str[grava_index + 9:]
                            meta_parts = inner_meta.split(',')
                            if len(meta_parts) >= 2:
                                status = meta_parts[1].strip()
                                error_msg = meta_parts[2].strip() if len(meta_parts) > 2 else ""
                        
                        json_end = line.rfind('}')
                        if json_end == -1: continue
                            
                        json_str = line[json_start : json_end + 1]
                        
                        try:
                            payload = json.loads(json_str)
                            cabecalho = payload.get("cabecalho", {})
                            cnpj = cabecalho.get("cnpjComprador", "Desconhecido")
                            dhe = cabecalho.get("dataHoraEmissao", "")
                            nf = cabecalho.get("numeroPedidoComprador", "")
                            
                            # Map Order to CNPJ for future lookups (e.g. duplicate check)
                            if nf and cnpj and cnpj != "Desconhecido":
                                order_to_cnpj[nf] = cnpj
                            
                            formatted_date = parse_date(dhe)
                            
                            row = {
                                "Arquivo": filename,
                                "Status": status,
                                "CNPJ": cnpj,
                                "DataEmissao": formatted_date,
                                "Pedido": nf,
                                "InfoOriginal": dhe,
                                "Erro": error_msg
                            }
                            
                            # Initialize CNPJ entry
                            if cnpj not in cnpj_stats:
                                cnpj_stats[cnpj] = {
                                    'success': 0, 
                                    'error': 0, 
                                    'name': 'Desconhecido', 
                                    'code': '', 
                                    'group': 'Não Identificado', 
                                    'errors': {}, 
                                    'error_orders': [],
                                    'success_orders': [],
                                    'last_transaction_date': ''
                                }


                            # Atualizar last_transaction_date com a mais recente
                            if formatted_date and formatted_date > cnpj_stats[cnpj]['last_transaction_date']:
                                cnpj_stats[cnpj]['last_transaction_date'] = formatted_date

                            if status == "Sucesso":
                                # Deduplicar por pedido, igual à lógica de erros
                                success_key = (cnpj, nf) if nf else None
                                if success_key and success_key not in seen_successes:
                                    seen_successes.add(success_key)
                                    success_row = row.copy()
                                    if "Erro" in success_row:
                                        del success_row["Erro"]
                                    success_list.append(success_row)
                                    cnpj_stats[cnpj]['success'] += 1
                                    cnpj_stats[cnpj]['success_orders'].append(nf)
                            elif status == "Erro":
                                total_raw_errors += 1
                                error_key = (cnpj, nf)
                                if error_key not in seen_errors:
                                    seen_errors.add(error_key)
                                    error_list.append(row)
                                    cnpj_stats[cnpj]['error'] += 1
                                    
                                    clean_msg = error_msg.replace('"', '').replace("'", "")
                                    short_msg = (clean_msg[:50] + '..') if len(clean_msg) > 50 else clean_msg
                                    if short_msg not in cnpj_stats[cnpj]['errors']:
                                        cnpj_stats[cnpj]['errors'][short_msg] = 0
                                    cnpj_stats[cnpj]['errors'][short_msg] += 1
                                    
                                    if nf and nf not in cnpj_stats[cnpj]['error_orders']:
                                        cnpj_stats[cnpj]['error_orders'].append(nf)
                                
                            total_processed += 1

                            
                        except json.JSONDecodeError:
                            pass
            except Exception as e:
                print(f"Erro ao processar arquivo {filename}: {e}")
            finally:
                file_obj.close()

    if ssh_client:
        ssh_client.close()

    # Enrichment Step
    print("Iniciando enriquecimento de dados...")
    unique_cnpjs = [c for c in cnpj_stats.keys() if c != "Desconhecido"]
    
    # 1. SAP Query Placeholder (assume cache or empty)
    # 1. SAP Query
    print(f"Consultando {len(unique_cnpjs)} CNPJs no SAP...")
    sap_data = get_sap_data(unique_cnpjs) 
    
    # 2. Enrich and Fallback
    for cnpj in unique_cnpjs:
        if cnpj in sap_data:
            cnpj_stats[cnpj]['name'] = sap_data[cnpj]['CardName']
            cnpj_stats[cnpj]['code'] = sap_data[cnpj]['CardCode']
            cnpj_stats[cnpj]['group'] = sap_data[cnpj]['GroupName'] if sap_data[cnpj]['GroupName'] else "Sem Grupo SAP"
        else:
            # Fallback to API
            # print(f"CNPJ {cnpj} não encontrado no SAP. Buscando na API...")
            api_name = get_api_data(cnpj)
            
            
            # Additional Cache Logic for API results?
            # User wants API ONLY if SAP fails.
            
            cnpj_stats[cnpj]['code'] = f"API-{cnpj}"
            cnpj_stats[cnpj]['group'] = "Outros (API)"
            
            if api_name:
                cnpj_stats[cnpj]['name'] = api_name
            else:
                cnpj_stats[cnpj]['name'] = f"CNPJ: {cnpj}"
    
    # Post-process: Adjust error counts for corrected orders
    # Post-process: Adjust error counts for corrected orders
    print("Ajustando contagens para pedidos corrigidos...")
    total_corrected = 0
    for cnpj, stats in cnpj_stats.items():
        error_orders_set = set(stats.get('error_orders', []))
        success_orders_set = set(stats.get('success_orders', []))
        corrected_orders = error_orders_set & success_orders_set
        
        if corrected_orders:
            count = len(corrected_orders)
            stats['error'] -= count
            stats['corrected_orders'] = list(corrected_orders)
            total_corrected += count
            
    print(f"Total processado: {total_processed}")
    print(f"Sucessos: {len(success_list)}")
    print(f"Erros encontrados (Cru): {total_raw_errors}")
    print(f"Erros Únicos (Deduplicados): {len(error_list)}")
    print(f"Total Autocorrigidos: {total_corrected}")

    # Aggregate by Group -> Client Code
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
                'error_types': {},
                'success_orders': [],
                'error_orders': [],
                'corrected_orders': [],
                'last_transaction_date': ''
            }

        # Propagar a data mais recente entre múltiplos CNPJs do mesmo CardCode
        existing_date = group_stats[grp]['clients'][code]['last_transaction_date']
        new_date = stats.get('last_transaction_date', '')
        if new_date and new_date > existing_date:
            group_stats[grp]['clients'][code]['last_transaction_date'] = new_date
        
        client = group_stats[grp]['clients'][code]
        client['success'] += stats['success']
        client['error'] += stats['error']
        
        for msg, count in stats['errors'].items():
            if msg not in client['error_types']:
                client['error_types'][msg] = 0
            client['error_types'][msg] += count
            
        client['success_orders'].extend(stats['success_orders'])
        client['error_orders'].extend(stats['error_orders'])
        if 'corrected_orders' in stats:
             client['corrected_orders'].extend(stats['corrected_orders'])

        # Deduplicar pedidos que chegam de múltiplos CNPJs de filiais com mesmo CardCode
        client['success_orders'] = list(dict.fromkeys(client['success_orders']))
        client['error_orders']   = list(dict.fromkeys(client['error_orders']))
        client['corrected_orders'] = list(dict.fromkeys(client.get('corrected_orders', [])))
        # Recalcular success a partir dos pedidos únicos
        client['success'] = len(client['success_orders'])

    # Recalcular totais do grupo a partir dos clientes já deduplicados
    for grp, gdata in group_stats.items():
        gdata['total_success'] = sum(c['success'] for c in gdata['clients'].values())
        gdata['total_error']   = sum(c['error']   for c in gdata['clients'].values())

    # Write CSVs
    with open(OUTPUT_SUCCESS_CSV, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Arquivo", "Status", "CNPJ", "DataEmissao", "Pedido", "InfoOriginal"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, extrasaction='ignore')
        writer.writeheader()
        writer.writerows(success_list)
        
    with open(OUTPUT_ERROR_CSV, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Arquivo", "Status", "CNPJ", "DataEmissao", "Pedido", "InfoOriginal", "Erro"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(error_list)
        
    print(f"CSV de Erros gerado: {OUTPUT_ERROR_CSV}")

    # Relatório Detalhado (Erros Únicos)
    OUTPUT_DETAILED_ERROR_CSV = "relatorio_erros_detalhado.csv"
    
    detailed_rows = []
    for row in error_list:
        cnpj = row['CNPJ']
        stats = cnpj_stats.get(cnpj, {})
        
        detailed_row = {
            "Grupo": stats.get('group', 'Não Identificado'),
            "Cliente": stats.get('name', 'Desconhecido'),
            "CodigoSAP": stats.get('code', ''),
            "CNPJ": cnpj,
            "Pedido": row['Pedido'],
            "Data": row['DataEmissao'],
            "MensagemErro": row['Erro'],
            "Arquivo": row['Arquivo']
        }
        detailed_rows.append(detailed_row)
        
    # Sort by Group then Date
    detailed_rows.sort(key=lambda x: (x['Grupo'], x['Data']))

    with open(OUTPUT_DETAILED_ERROR_CSV, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Grupo", "Cliente", "CodigoSAP", "CNPJ", "Pedido", "Data", "MensagemErro", "Arquivo"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(detailed_rows)
            
    print(f"CSV Detalhado gerado (Agrupado): {OUTPUT_DETAILED_ERROR_CSV}")
        
    # Generate old-style accordion HTML
    generate_html_accordion(len(success_list), len(error_list), total_raw_errors, group_stats, f"{start_date} a {end_date}")

    # Inject fresh data into the modern Alpine.js HTML
    inject_modern_html(group_stats, f"{start_date} a {end_date}")

    if return_data:
        return {
            'success_list': success_list,
            'error_list': error_list,
            'total_raw_errors': total_raw_errors,
            'total_corrected': total_corrected,
            'group_stats': group_stats,
            'detailed_rows': detailed_rows
        }

def inject_modern_html(group_stats, period_label):
    """
    Injects freshly computed group_stats as rawGroupData into relatorio_analise_moderno.html.
    Replaces the line starting with 'const rawGroupData = ' with updated data.
    """
    modern_html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "relatorio_analise_moderno.html")
    if not os.path.exists(modern_html_path):
        print(f"[inject_modern_html] Arquivo nao encontrado: {modern_html_path}")
        return

    # Build groups_data in the same format as the HTML expects
    groups_data = []
    sorted_groups = sorted(group_stats.items(), key=lambda x: x[1]['total_error'], reverse=True)
    for grp_name, stats in sorted_groups:
        clients_list = []
        sorted_clients = sorted(stats['clients'].items(), key=lambda x: x[1]['error'], reverse=True)
        for code, cli_stats in sorted_clients:
            clients_list.append({
                'label': f"[{code}] {cli_stats['name']}",
                'success': cli_stats['success'],
                'error': cli_stats['error'],
                'error_types': cli_stats['error_types'],
                'success_orders': cli_stats.get('success_orders', []),
                'error_orders': cli_stats.get('error_orders', []),
                'corrected_orders': cli_stats.get('corrected_orders', []),
                'last_transaction_date': cli_stats.get('last_transaction_date', '')
            })
        groups_data.append({
            'groupName': grp_name,
            'totalSuccess': stats['total_success'],
            'totalError': stats['total_error'],
            'clients': clients_list
        })

    new_raw_data_line = f"        const rawGroupData = {json.dumps(groups_data, ensure_ascii=False)};\r\n"

    with open(modern_html_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find and replace the rawGroupData line
    import re as _re
    pattern = r'        const rawGroupData = \[.*?\];\r?\n'
    new_content = _re.sub(pattern, new_raw_data_line, content, count=1, flags=_re.DOTALL)

    if new_content == content:
        print("[inject_modern_html] AVISO: padrao rawGroupData nao encontrado no HTML moderno.")
        return

    with open(modern_html_path, 'w', encoding='utf-8', newline='') as f:
        f.write(new_content)

    print(f"[inject_modern_html] rawGroupData atualizado em relatorio_analise_moderno.html ({len(groups_data)} grupos, periodo: {period_label})")

if __name__ == "__main__":
    load_cache()
    analyze_period("01-01-2026", "19-02-2026")

