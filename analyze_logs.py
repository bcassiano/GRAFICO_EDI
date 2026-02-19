import glob
import os
import json
import csv
import re
import subprocess
import urllib.request
import paramiko
import time
from datetime import datetime

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
    Searches CardFName, LicTradNum, TaxId0 (CRD7), TaxId4 (CRD7).
    """
    if not cnpjs:
        return {}
        
    print(f"Consultando SAP para {len(cnpjs)} CNPJs...")
    
    # Helper to strip non-digits
    def clean_cnpj(c):
        return re.sub(r'\D', '', str(c))

    # Build candidate map: all digit-variants -> original log CNPJ
    candidate_map = {}
    for c in cnpjs:
        raw = clean_cnpj(c)
        if not raw: continue
        candidate_map[raw] = c
        candidate_map[raw.zfill(14)] = c
        trimmed = raw.lstrip('0')
        if trimmed:
            candidate_map[trimmed] = c

    candidates = list(candidate_map.keys())
    if not candidates:
        return {}

    # Format CNPJs for SQL IN clause
    in_clause = "', '".join(candidates)
    
    # Query all 4 CNPJ fields, including CRD7 for TaxId0/TaxId4
    query = f"""
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
                card_code = item.get('CardCode', '')
                stats = {
                    'CardCode': card_code,
                    'CardName': item.get('CardName'),
                    'GroupName': item.get('GroupName')
                }
                
                # Check ALL 4 fields to find which candidate matched
                matched_originals = set()
                fields_to_check = [
                    item.get('CardFName', ''),
                    item.get('LicTradNum', ''),
                    item.get('TaxId0', ''),
                    item.get('TaxId4', '')
                ]
                for field in fields_to_check:
                    clean = clean_cnpj(field)
                    for variant in [clean, clean.zfill(14), clean.lstrip('0')]:
                        if variant and variant in candidate_map:
                            matched_originals.add(candidate_map[variant])

                # Priority: prefer CardCodes starting with 'C' (clients) over vendors
                is_new_client = card_code.upper().startswith('C')
                for original in matched_originals:
                    existing = enrichment_map.get(original, {})
                    already_has_client = existing.get('CardCode', '').upper().startswith('C')
                    if original not in enrichment_map or (is_new_client and not already_has_client):
                        enrichment_map[original] = stats

            return enrichment_map
            
    except Exception as e:
        print(f"Erro ao consultar SAP: {e}")
        
    return {}

def get_api_data(cnpj):
    """
    Queries BrasilAPI for CNPJ data with caching and headers.
    """
    if cnpj in _cnpj_cache:
        return _cnpj_cache[cnpj]
        
    url = f"https://brasilapi.com.br/api/cnpj/v1/{cnpj}"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        print(f"Buscando CNPJ {cnpj} na BrasilAPI...")
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                name = data.get('razao_social') or data.get('nome_fantasia')
                if name:
                    _cnpj_cache[cnpj] = name
                    save_cache()
                    return name
    except Exception as e:
        print(f"Erro ao consultar API ({cnpj}): {e}")
        
    return None

def get_remote_log_file(client, target_date=None):
    """
    Connects via SFTP and returns an open file object for the requested log.
    If target_date is None, finds the most recent .log file.
    Returns: (file_object, filename) or (None, None)
    """
    try:
        sftp = client.open_sftp()
        
        if target_date:
            filename = f"{target_date}.log"
            filepath = f"{REMOTE_LOG_DIR}/{filename}"
            print(f"Tentando abrir arquivo remoto: {filepath}")
            try:
                return sftp.open(filepath, 'r'), filename
            except FileNotFoundError:
                print(f"Arquivo {filename} não encontrado no servidor.")
                return None, None
        else:
            print(f"Listando arquivos em {REMOTE_LOG_DIR} para encontrar o mais recente...")
            files = sftp.listdir_attr(REMOTE_LOG_DIR)
            # Filter for .log files
            log_files = [f for f in files if f.filename.endswith('.log')]
            
            if not log_files:
                print("Nenhum arquivo .log encontrado no diretório remoto.")
                return None, None
                
            # Sort by modification time (st_mtime), descending
            log_files.sort(key=lambda x: x.st_mtime, reverse=True)
            latest = log_files[0]
            
            filename = latest.filename
            filepath = f"{REMOTE_LOG_DIR}/{filename}"
            print(f"Abrindo arquivo mais recente: {filepath}")
            return sftp.open(filepath, 'r'), filename

    except Exception as e:
        print(f"Erro no acesso SFTP: {e}")
        return None, None

def analyze_logs(target_date=None):
    if target_date is None:
        target_date = datetime.now().strftime("%Y-%m-%d")
        
    print(f"Iniciando conexão SSH com {SSH_HOST}...")
    
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh_client.connect(SSH_HOST, username=SSH_USER, password=SSH_PASS)
        
        # Get remote file handle
        remote_file, filename = get_remote_log_file(ssh_client, target_date)
        
        if not remote_file:
            print("Não foi possível acessar o arquivo de log remoto.")
            return

        print(f"Processando arquivo: {filename}")
        
        seen_errors = set() 
        cnpj_stats = {} 
        success_list = []
        error_list = []
        
        total_processed = 0
        total_raw_errors = 0
        
        # Process the file stream directly
        try:
            # SFTP file is compatible with iteration
            for line in remote_file:
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
                            cnpj_stats[cnpj] = {
                                'success': 0, 
                                'error': 0, 
                                'name': 'Desconhecido', 
                                'code': '', 
                                'group': 'Não Identificado', 
                                'errors': {}, 
                                'error_orders': [],
                                'success_orders': []
                            }

                        if status == "Sucesso":
                            success_list.append(row)
                            cnpj_stats[cnpj]['success'] += 1
                            # Track success order number
                            if nf and nf not in cnpj_stats[cnpj]['success_orders']:
                                cnpj_stats[cnpj]['success_orders'].append(nf)
                        elif status == "Erro":
                            total_raw_errors += 1
                            error_key = (cnpj, nf)
                            if error_key not in seen_errors:
                                seen_errors.add(error_key)
                                error_list.append(row)
                                cnpj_stats[cnpj]['error'] += 1
                                
                                # Track Error Type
                                clean_msg = error_msg.replace('"', '').replace("'", "")
                                short_msg = (clean_msg[:50] + '..') if len(clean_msg) > 50 else clean_msg
                                if short_msg not in cnpj_stats[cnpj]['errors']:
                                    cnpj_stats[cnpj]['errors'][short_msg] = 0
                                cnpj_stats[cnpj]['errors'][short_msg] += 1
                                # Track error order number
                                if nf and nf not in cnpj_stats[cnpj]['error_orders']:
                                    cnpj_stats[cnpj]['error_orders'].append(nf)
                            
                        total_processed += 1
                        
                    except json.JSONDecodeError:
                        pass
        finally:
            remote_file.close()
            ssh_client.close()
            
    except Exception as e:
        print(f"Erro crítico na conexão ou processamento: {e}")
        return

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
    
    # Post-process: Adjust error counts for corrected orders
    # Corrected orders should ONLY count as success, not as error
    print("Ajustando contagens para pedidos corrigidos...")
    for cnpj, stats in cnpj_stats.items():
        error_orders_set = set(stats.get('error_orders', []))
        success_orders_set = set(stats.get('success_orders', []))
        corrected_orders = error_orders_set & success_orders_set
        
        if corrected_orders:
            # For each corrected order, decrement the error count
            # We need to track which errors to remove from error_list for accurate deduplication
            stats['error'] -= len(corrected_orders)
            
            # Remove corrected orders from error count (they stay in error_orders for display)
            # We'll keep them in the lists for visualization, but adjust the numeric counts
            
            # Note: We can't easily adjust error_types counts without tracking which error
            # message belongs to which order, so we'll keep error_types as-is for now
            # The important part is the total error count is correct
 

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
                'error_types': {},
                'success_orders': [],
                'error_orders': [],
                'corrected_orders': []
            }
        
        client = group_stats[grp]['clients'][code]
        client['success'] += stats['success']
        client['error'] += stats['error']
        
        for msg, count in stats['errors'].items():
            if msg not in client['error_types']:
                client['error_types'][msg] = 0
            client['error_types'][msg] += count
        
        # Detect corrected orders (orders that appear in both error and success lists)
        error_orders_set = set(stats.get('error_orders', []))
        success_orders_set = set(stats.get('success_orders', []))
        corrected = list(error_orders_set & success_orders_set)
        
        # Add orders to client, separating by category
        for order in stats.get('success_orders', []):
            if order not in corrected:  # Only pure successes
                if order not in client['success_orders']:
                    client['success_orders'].append(order)
        
        for order in stats.get('error_orders', []):
            if order not in corrected:  # Only pure errors
                if order not in client['error_orders']:
                    client['error_orders'].append(order)
        
        # Add corrected orders
        for order in corrected:
            if order not in client['corrected_orders']:
                client['corrected_orders'].append(order)
            
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
    generate_html_accordion(len(success_list), len(error_list), total_raw_errors, group_stats, target_date)

def generate_html_accordion(success_count, error_count, raw_error_count, group_stats, target_date):
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
        /* Header Style Updates */
        .header {{ text-align: center; margin-bottom: 30px; position: relative; }}
        .header h1 {{ margin: 0; color: #333; }}
        .header .report-date {{ font-size: 18px; color: #666; margin-top: 10px; font-weight: 500; }}
        
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
        <div class="report-date">Análise Referente a: {target_date}</div>
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
                                        
                                        // Display corrected orders in success tooltip too
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
    import sys
    load_cache()
    date_arg = sys.argv[1] if len(sys.argv) > 1 else None
    analyze_logs(date_arg)
