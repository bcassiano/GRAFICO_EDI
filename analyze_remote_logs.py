import paramiko
import os
import re
import json
import subprocess
import time
import urllib.request
from datetime import datetime
from dotenv import load_dotenv

# Carregar variáveis do .env
load_dotenv()

SSH_HOST = os.getenv("SSH_HOST", "192.168.1.244")
SSH_USER = os.getenv("SSH_USER", "root")
SSH_PASS = os.getenv("SSH_PASS", "Rust0n@2023@")
TODAY_STR = datetime.now().strftime("%Y-%m-%d")
REMOTE_LOG_PATH = f"/SPS/PRD/integracao_neogrid/logs/{TODAY_STR}.log"
OUTPUT_HTML = "relatorio_analise.html"
CACHE_FILE = "cnpj_cache.json"

def load_cache():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except: return {}
    return {}

def save_cache(cache):
    try:
        with open(CACHE_FILE, 'w', encoding='utf-8') as f:
            json.dump(cache, f, ensure_ascii=False, indent=2)
    except: pass

def get_api_data(cnpj):
    # BrasilAPI exige User-Agent para algumas requisições
    url = f"https://brasilapi.com.br/api/cnpj/v1/{cnpj}"
    headers = {'User-Agent': 'Mozilla/5.0'}
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                return data.get('razao_social') or data.get('nome_fantasia')
    except Exception as e:
        print(f"Erro API ({cnpj}): {e}")
    return None

def get_sap_data(cnpjs):
    if not cnpjs:
        return {}
    
    print(f"Consultando SAP para {len(cnpjs)} CNPJs...")
    
    def clean_cnpj(c):
        return re.sub(r'\D', '', str(c))
        
    cleaned_cnpjs = set(clean_cnpj(c) for c in cnpjs if c and c != "Desconhecido")
    if not cleaned_cnpjs:
        return {}

    cnpj_list_sql = ", ".join([f"'{c}'" for c in cleaned_cnpjs])
    query = f"SELECT T0.CardFName, T0.CardCode, T0.CardName, T1.GroupName, T0.CardType FROM OCRD T0 LEFT JOIN OCRG T1 ON T0.GroupCode = T1.GroupCode WHERE REPLACE(REPLACE(REPLACE(T0.CardFName, '.', ''), '/', ''), '-', '') IN ({cnpj_list_sql}) ORDER BY T0.CardType ASC"
    
    cmd = ["powershell", "-File", "ExecQuery.ps1", "-SQLQuery", query]
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
                raw_cnpj = clean_cnpj(item.get('CardFName', ''))
                card_type = item.get('CardType', '')
                if raw_cnpj:
                    # Se já existe um cadastro de cliente ('C'), não sobrescrever com fornecedor ('S')
                    if raw_cnpj in enrichment_map and enrichment_map[raw_cnpj].get('CardType') == 'C' and card_type != 'C':
                        continue
                        
                    enrichment_map[raw_cnpj] = {
                        'CardCode': item.get('CardCode'),
                        'CardName': item.get('CardName'),
                        'GroupName': item.get('GroupName'),
                        'CardType': card_type
                    }
            return enrichment_map
    except Exception as e:
        print(f"Erro ao consultar SAP: {e}")
    return {}

def generate_html(success_count, error_count, group_stats):
    total_unique = success_count + error_count
    rate = (success_count / total_unique * 100) if total_unique > 0 else 0
    
    groups_data = []
    # Sort groups by error descending
    sorted_groups = sorted(group_stats.items(), key=lambda x: x[1]['total_error'], reverse=True)
    
    for grp_name, stats in sorted_groups:
        entries_list = []
        # Entries represent (Client + NF)
        sorted_entries = sorted(stats['entries'], key=lambda x: (x['error'], x['success']), reverse=True)
        
        for entry in sorted_entries:
            label = f"[{entry['code']}] {entry['name']} - Pedido: {entry['nf']}"
            is_corrected = entry['error'] > 0 and entry['success'] > 0
            
            entries_list.append({
                'label': label,
                'success': entry['success'],
                'error': entry['error'],
                'isCorrected': is_corrected,
                'error_types': entry['error_types']
            })
            
        groups_data.append({
            'groupName': grp_name,
            'totalSuccess': stats['total_success'],
            'totalError': stats['total_error'],
            'entries': entries_list
        })
        
    json_groups = json.dumps(groups_data)
    
    html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Relatório EDI por Pedido (""" + TODAY_STR + """)</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .summary-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: flex; justify-content: center; align-items: center; max-width: 900px; margin: 0 auto 30px auto; gap: 50px; }
        .chart-container-doughnut { width: 250px; height: 250px; }
        .metrics-container { display: flex; flex-direction: column; justify-content: center; gap: 15px; text-align: left; }
        .metric-row { font-size: 16px; color: #555; }
        .metric-value { font-weight: bold; font-size: 20px; }
        .metric-large { font-size: 24px; font-weight: bold; border-top: 1px solid #eee; padding-top: 10px; margin-top: 5px; }
        .group-container { max-width: 1000px; margin: 0 auto; }
        .group-card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 15px; overflow: hidden; }
        .group-header { padding: 20px; cursor: pointer; display: flex; justify-content: space-between; align-items: center; border-left: 5px solid #ddd; transition: background 0.2s; }
        .group-header:hover { background-color: #f9f9f9; }
        .group-header.has-error { border-left-color: #FF6384; }
        .group-header.all-success { border-left-color: #4BC0C0; }
        .group-info h3 { margin: 0 0 5px 0; font-size: 18px; }
        .group-stats { font-size: 14px; color: #555; }
        .toggle-icon { font-size: 20px; color: #999; transition: transform 0.3s; }
        .group-card.active .toggle-icon { transform: rotate(180deg); }
        .group-content { display: none; padding: 20px; border-top: 1px solid #eee; background-color: #fafafa; position: relative; }
        .group-card.active .group-content { display: block; }
        .chart-wrapper { position: relative; height: 400px; width: 100%; }
        .btn-load { background-color: #36A2EB; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; margin-top: 10px; }
        .error-detail-tooltip { position: absolute; background: rgba(0, 0, 0, 0.85); color: white; padding: 10px; border-radius: 4px; font-size: 12px; pointer-events: none; z-index: 100; max-width: 300px; display: none; }
        .error-detail-header { font-weight: bold; margin-bottom: 5px; border-bottom: 1px solid #555; padding-bottom: 3px; }
        .error-item { display: flex; justify-content: space-between; margin-bottom: 2px; }
        .error-count { font-weight: bold; color: #FF6384; margin-right: 10px; }
        .legend-corrected { color: #2ecc71; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header"><h1>Relatório EDI por Pedido (""" + TODAY_STR + """)</h1></div>
    <div class="summary-card">
        <div class="chart-container-doughnut"><canvas id="doughnutChart"></canvas></div>
        <div class="metrics-container">
            <div class="metric-row">Total de Pedidos Únicos: <span class="metric-value">""" + str(total_unique) + """</span></div>
            <div class="metric-row">Sucessos: <span class="metric-value" style="color: #4BC0C0;">""" + str(success_count) + """</span></div>
            <div class="metric-row">Erros Únicos: <span class="metric-value" style="color: #FF6384;">""" + str(error_count) + """</span></div>
            <div class="metric-large">Taxa de Sucesso: """ + f"{rate:.2f}" + """%</div>
        </div>
    </div>
    <div class="group-container" id="groupsContainer"></div>
    <div id="customTooltip" class="error-detail-tooltip"></div>
    <script>
        const groupsData = """ + json_groups + """;
        const PAGE_SIZE = 10;
        
        new Chart(document.getElementById('doughnutChart').getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['Sucesso', 'Erros'],
                datasets: [{ data: [""" + str(success_count) + "," + str(error_count) + """], backgroundColor: ['#4BC0C0', '#FF6384'] }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });

        const container = document.getElementById('groupsContainer');
        groupsData.forEach((grp, index) => {
            const card = document.createElement('div');
            card.className = 'group-card';
            const borderClass = grp.totalError > 0 ? 'has-error' : 'all-success';
            card.innerHTML = `
                <div class="group-header ${borderClass}" onclick="toggleGroup(${index})">
                    <div class="group-info">
                        <h3>${grp.groupName}</h3>
                        <div class="group-stats">Sucesso: <b>${grp.totalSuccess}</b> | Erros: <b>${grp.totalError}</b></div>
                    </div>
                    <div class="toggle-icon">▼</div>
                </div>
                <div class="group-content" id="content-${index}">
                    <div class="chart-wrapper"><canvas id="chart-${index}"></canvas></div>
                    <button class="btn-load" id="btn-${index}" onclick="loadMore(${index})">Carregar Mais</button>
                </div>
            `;
            container.appendChild(card);
            grp.visualIndex = 0;
            grp.chartInstance = null;
        });

        function toggleGroup(i) {
            const content = document.getElementById(`content-${i}`);
            if (content.style.display === 'block') {
                content.style.display = 'none';
                content.parentElement.classList.remove('active');
            } else {
                content.style.display = 'block';
                content.parentElement.classList.add('active');
                if (!groupsData[i].chartInstance) {
                    initChart(i);
                    loadMore(i);
                }
            }
        }

        function initChart(i) {
            const ctx = document.getElementById(`chart-${i}`).getContext('2d');
            groupsData[i].chartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: [],
                    datasets: [
                        { label: 'Sucesso', data: [], backgroundColor: '#4BC0C0' },
                        { label: 'Erro', data: [], backgroundColor: '#FF6384' },
                        { label: 'Corrigido', data: [], backgroundColor: '#2ecc71' }
                    ]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    layout: { padding: { left: 20 } },
                    scales: { 
                        x: { stacked: true }, 
                        y: { 
                            stacked: true,
                            ticks: {
                                font: { size: 10 },
                                callback: function(value) {
                                    const label = this.getLabelForValue(value);
                                    if (label.length > 45) {
                                        const parts = label.split(' - Pedido: ');
                                        const prefix = parts[0];
                                        const order = parts.length > 1 ? ' - Ped: ' + parts[1] : '';
                                        const codeMatch = prefix.match(/^(\[.*?\])/);
                                        const code = codeMatch ? codeMatch[1] : "";
                                        const name = prefix.replace(code, "").trim();
                                        if (name.length > 20) {
                                            return code + " " + name.substring(0, 17) + "..." + order;
                                        }
                                    }
                                    return label;
                                }
                            }
                        } 
                    },
                    plugins: { 
                        legend: { display: true, position: 'top' },
                        tooltip: { 
                            enabled: false,
                            external: function(context) {
                                const el = document.getElementById('customTooltip');
                                if (context.tooltip.opacity === 0) { el.style.display = 'none'; return; }
                                
                                const entry = groupsData[i].entries[context.tooltip.dataPoints[0].dataIndex];
                                let html = `<div class="error-detail-header">${entry.label}</div>`;
                                
                                if (entry.isCorrected) {
                                    html += `<div style="color: #2ecc71; font-weight: bold; margin-bottom:5px;">ERRO CORRIGIDO COM SUCESSO!</div>`;
                                }

                                if (Object.keys(entry.error_types).length > 0) {
                                    html += `<div style="font-weight:bold; margin-top:5px;">Erros Identificados:</div>`;
                                    for (const [m, c] of Object.entries(entry.error_types)) {
                                        html += `<div class="error-item"><span>${m}</span><b>${c}</b></div>`;
                                    }
                                }
                                
                                if (entry.success > 0) {
                                    html += `<div style="margin-top:5px; color:#4BC0C0;">Status Final: SUCESSO</div>`;
                                }

                                el.innerHTML = html;
                                el.style.display = 'block';
                                const position = context.chart.canvas.getBoundingClientRect();
                                el.style.left = position.left + window.pageXOffset + context.tooltip.caretX + 20 + 'px';
                                el.style.top = position.top + window.pageYOffset + context.tooltip.caretY + 'px';
                            }
                        }
                    }
                }
            });
        }

        function loadMore(i) {
            const g = groupsData[i];
            const batch = g.entries.slice(g.visualIndex, g.visualIndex + PAGE_SIZE);
            if (batch.length === 0) return;

            batch.forEach(entry => {
                g.chartInstance.data.labels.push(entry.label);
                
                if (entry.isCorrected) {
                    // Show small Red part and bigger Green part
                    g.chartInstance.data.datasets[1].data.push(0.3); // Micro erro
                    g.chartInstance.data.datasets[2].data.push(0.7); // Sucesso Corrigido
                    g.chartInstance.data.datasets[0].data.push(0);
                } else if (entry.error > 0) {
                    g.chartInstance.data.datasets[1].data.push(1);
                    g.chartInstance.data.datasets[0].data.push(0);
                    g.chartInstance.data.datasets[2].data.push(0);
                } else {
                    g.chartInstance.data.datasets[0].data.push(1);
                    g.chartInstance.data.datasets[1].data.push(0);
                    g.chartInstance.data.datasets[2].data.push(0);
                }
            });
            
            g.visualIndex += batch.length;
            g.chartInstance.update();
            if (g.visualIndex >= g.entries.length) document.getElementById(`btn-${i}`).style.display = 'none';
        }
    </script>
</body>
</html>
"""
    with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
        f.write(html_template)
    print(f"Relatório gerado em: {OUTPUT_HTML}")

def analyze_remote_log():
    print(f"Conectando ao servidor {SSH_HOST}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        client.connect(SSH_HOST, username=SSH_USER, password=SSH_PASS, timeout=10)
        stdin, stdout, stderr = client.exec_command(f"cat {REMOTE_LOG_PATH}")
        
        # Structure: {(cnpj, nf): {'success': 0, 'error': 0, 'errors': {} }}
        order_stats = {}
        
        for line in stdout:
            if "gravaLog(" in line:
                status = "Sucesso" if "Sucesso" in line else "Erro"
                json_match = re.search(r'(\{.*\})', line)
                cnpj = "Desconhecido"
                nf = "N/A"
                if json_match:
                    try:
                        payload = json.loads(json_match.group(1))
                        cabecalho = payload.get("cabecalho", {})
                        cnpj = cabecalho.get("cnpjComprador", "Desconhecido")
                        nf = cabecalho.get("numeroPedidoComprador", "N/A")
                    except: pass
                
                key = (cnpj, nf)
                if key not in order_stats:
                    order_stats[key] = {'success': 0, 'error': 0, 'errors': {}}
                
                if status == "Sucesso":
                    order_stats[key]['success'] += 1
                else:
                    order_stats[key]['error'] += 1
                    msg_match = re.search(r'gravaLog\(5,Erro,(.*?),,', line)
                    if msg_match:
                        msg = msg_match.group(1).strip().replace("'", "").replace('"', '')
                        short_msg = (msg[:60] + '..') if len(msg) > 60 else msg
                        order_stats[key]['errors'][short_msg] = order_stats[key]['errors'].get(short_msg, 0) + 1

        print("Enriquecendo dados...")
        cnpjs = set(k[0] for k in order_stats.keys())
        enrichment = get_sap_data(cnpjs)
        cache = load_cache()
        cache_updated = False
        
        group_stats = {}
        total_unique_success = 0
        total_unique_error = 0
        
        for (cnpj, nf), stats in order_stats.items():
            if cnpj == "Desconhecido":
                info = {'CardName': 'Desconhecido', 'CardCode': 'S/C', 'GroupName': 'Não Identificado'}
            else:
                # Limpar CNPJ antes de buscar
                clean_c = re.sub(r'\D', '', str(cnpj))
                info = enrichment.get(clean_c)
                
                if not info:
                    # Tenta cache
                    cached_name = cache.get(clean_c)
                    if cached_name:
                        info = {'CardName': cached_name, 'CardCode': 'API', 'GroupName': 'Outros (API)'}
                    else:
                        # Tenta API
                        api_name = get_api_data(clean_c)
                        if api_name:
                            info = {'CardName': api_name, 'CardCode': 'API', 'GroupName': 'Outros (API)'}
                            cache[clean_c] = api_name
                            cache_updated = True
                        else:
                            info = {'CardName': f"CNPJ: {cnpj}", 'CardCode': 'API', 'GroupName': 'Outros (API)'}

            if cache_updated:
                save_cache(cache)
                cache_updated = False

            grp = info.get('GroupName') or ("Outros (API)" if cnpj != "Desconhecido" else "Não Identificado")
            code = info.get('CardCode') or "S/C"
            name = info.get('CardName') or "Desconhecido"
            
            if grp not in group_stats:
                group_stats[grp] = {'total_success': 0, 'total_error': 0, 'entries': []}
            
            # Global unique counts (only if order finally succeeded vs only failed)
            # If an order has at least one success, we count it as a global success
            if stats['success'] > 0:
                total_unique_success += 1
                group_stats[grp]['total_success'] += 1
            else:
                total_unique_error += 1
                group_stats[grp]['total_error'] += 1
            
            group_stats[grp]['entries'].append({
                'name': name,
                'code': code,
                'nf': nf,
                'success': stats['success'],
                'error': stats['error'],
                'error_types': stats['errors']
            })
        
        generate_html(total_unique_success, total_unique_error, group_stats)

    except Exception as e:
        print(f"Erro: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    analyze_remote_log()
