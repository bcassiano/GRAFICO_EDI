import firebase_admin
from firebase_admin import credentials, firestore
import threading
import time
import os
import sys
import json
import re
from datetime import datetime, timedelta

# Inicializar Firebase
current_dir = os.path.dirname(os.path.abspath(__file__))
cred = credentials.Certificate(os.path.join(current_dir, 'firebase-service-account.json'))
firebase_admin.initialize_app(cred)
db = firestore.client()

LOG_DIR = "/SPS/PRD/integracao_neogrid/logs"

# Importar API tools e pymssql para a Query SAP real
import urllib.request
try:
    import pymssql
    HAS_PYMSSQL = True
except ImportError:
    print("AVISO: pymssql não instalado. SAP resolver desativado. Instale com: pip install pymssql")
    HAS_PYMSSQL = False

_cnpj_cache = {}
CNPJ_CACHE_FILE = os.path.join(current_dir, 'cnpj_cache.json')

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

def get_api_data(cnpj):
    global _cnpj_cache
    clean_cnpj = re.sub(r'[^0-9]', '', cnpj)
    if clean_cnpj in _cnpj_cache:
        return _cnpj_cache[clean_cnpj]
        
    try:
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
    candidate_map = {}
    for c in cnpj_list:
        raw = re.sub(r'[^0-9]', '', str(c))
        if not raw: continue
        candidate_map[raw] = c
        candidate_map[raw.zfill(14)] = c
        trimmed = raw.lstrip('0')
        if trimmed: candidate_map[trimmed] = c

    candidates = list(candidate_map.keys())
    if not candidates: return {}
        
    chunk_size = 50
    chunks = [candidates[i:i + chunk_size] for i in range(0, len(candidates), chunk_size)]
    mapping = {}
    
    for chunk in chunks:
        try:
            in_clause = "', '".join(chunk)
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
            
            conn = pymssql.connect(server='192.168.1.85:1433', user='powerbi', password='P0w3rB1@25', database='RUSTON_PRODUCAO', charset='UTF-8')
            cursor = conn.cursor(as_dict=True)
            cursor.execute(query)
            results = cursor.fetchall()
            conn.close()
            
            if not results: continue
            for row in results:
                card_code = row.get('CardCode', '')
                stats = {
                    'CardName': row.get('CardName'),
                    'CardCode': card_code,
                    'GroupName': row.get('GroupName')
                }
                matched_originals = set()
                fields_to_check = [row.get('CardFName', ''), row.get('LicTradNum', ''), row.get('TaxId0', ''), row.get('TaxId4', '')]
                for field in fields_to_check:
                    clean = re.sub(r'[^0-9]', '', str(field))
                    for variant in [clean, clean.zfill(14), clean.lstrip('0')]:
                        if variant and variant in candidate_map:
                            matched_originals.add(candidate_map[variant])
                is_new_client = card_code.upper().startswith('C')
                for original in matched_originals:
                    existing = mapping.get(original, {})
                    already_has_client = existing.get('CardCode', '').upper().startswith('C')
                    if original not in mapping or (is_new_client and not already_has_client):
                        mapping[original] = stats
        except Exception as e:
            print(f"Erro no chunk SAP: {e}")
    return mapping

def parse_date(date_str):
    if not date_str or len(date_str) < 12:
        return date_str
    try:
        dt = datetime.strptime(date_str[:12], "%d%m%Y%H%M")
        return dt.strftime("%Y-%m-%d %H:%M")
    except ValueError:
        return date_str

def process_logs(start_date, end_date):
    """Lógica pesada para processar logs locais baseada em analyze_custom_period.py"""
    start = datetime.strptime(start_date, "%d-%m-%Y")
    end = datetime.strptime(end_date, "%d-%m-%Y")
    delta = end - start
    date_list = [(start + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(delta.days + 1)]
    
    seen_errors = set() 
    seen_successes = set()
    cnpj_stats = {} 
    
    order_to_cnpj = {}
    
    for target_date in date_list:
        filename = f"{target_date}.log"
        local_path = os.path.join(LOG_DIR, filename)
        
        # Fallback to current dir if LOG_DIR missing (for parsing local tests)
        if not os.path.exists(local_path):
            local_path = os.path.join(os.path.dirname(os.path.dirname(current_dir)), 'LOGS_EDI', filename)
            
        if not os.path.exists(local_path):
            continue
            
        try:
            with open(local_path, 'r', encoding='utf-8', errors='replace') as file_obj:
                for line in file_obj:
                    if "gravaLog(" in line:
                        if "já cadastrado no SAP" in line:
                            dup_match = re.search(r'Pedido\s+(\d+)\s+já\s+cadastrado', line)
                            if dup_match:
                                nf_exist = dup_match.group(1)
                                if nf_exist in order_to_cnpj:
                                    cnpj_exist = order_to_cnpj[nf_exist]
                                    if cnpj_exist in cnpj_stats:
                                        if nf_exist not in cnpj_stats[cnpj_exist]['success_orders']:
                                            cnpj_stats[cnpj_exist]['success'] += 1
                                            cnpj_stats[cnpj_exist]['success_orders'].append(nf_exist)
                        
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
                            
                            if nf and cnpj and cnpj != "Desconhecido":
                                order_to_cnpj[nf] = cnpj
                            
                            formatted_date = parse_date(dhe)
                            
                            # Filtro estrito: só conta pedidos cuja dataEmissao
                            # caia dentro do intervalo selecionado
                            only_date = formatted_date[:10] if formatted_date else ""
                            if only_date not in date_list:
                                continue
                            
                            if cnpj not in cnpj_stats:
                                cnpj_stats[cnpj] = {
                                    'success': 0, 'error': 0, 'name': f'CNPJ: {cnpj}', 
                                    'code': f'C-{cnpj[:5]}', 'group': 'Não Identificado',
                                    'errors': {}, 'error_orders': [], 'success_orders': [],
                                    'last_transaction_date': ''
                                }

                            if formatted_date and formatted_date > cnpj_stats[cnpj]['last_transaction_date']:
                                cnpj_stats[cnpj]['last_transaction_date'] = formatted_date

                            if status == "Sucesso":
                                success_key = (cnpj, nf) if nf else None
                                if success_key and success_key not in seen_successes:
                                    seen_successes.add(success_key)
                                    cnpj_stats[cnpj]['success'] += 1
                                    cnpj_stats[cnpj]['success_orders'].append(nf)
                                    
                            elif status == "Erro":
                                error_key = (cnpj, nf)
                                if error_key not in seen_errors:
                                    seen_errors.add(error_key)
                                    cnpj_stats[cnpj]['error'] += 1
                                    
                                    clean_msg = error_msg.replace('"', '').replace("'", "")
                                    short_msg = (clean_msg[:50] + '..') if len(clean_msg) > 50 else clean_msg
                                    if short_msg not in cnpj_stats[cnpj]['errors']:
                                        cnpj_stats[cnpj]['errors'][short_msg] = 0
                                    cnpj_stats[cnpj]['errors'][short_msg] += 1
                                    
                                    if nf and nf not in cnpj_stats[cnpj]['error_orders']:
                                        cnpj_stats[cnpj]['error_orders'].append(nf)
                        except json.JSONDecodeError:
                            pass
        except Exception as e:
            print(f"File Error: {e}")

    # --- NOVO: RESOLVER CNPJs no SAP e API ---
    load_cache()
    unique_cnpjs = list(cnpj_stats.keys())
    print(f"Resolvendo {len(unique_cnpjs)} CNPJs no SAP e formatando Atacadão...")
    sap_mapping = get_sap_data(unique_cnpjs)
    
    for cnpj in unique_cnpjs:
        # A chave no sap_mapping é o CNPJ limpo ou original dependendo do match.
        # get_sap_data retorna um mapa onde a chave é o que foi encontrado no OCRD.
        # Precisamos testar variações para garantir o match.
        raw_cnpj = re.sub(r'[^0-9]', '', str(cnpj))
        variants = [cnpj, raw_cnpj, raw_cnpj.zfill(14), raw_cnpj.lstrip('0')]
        
        sap_info = None
        for v in variants:
            if v and v in sap_mapping:
                sap_info = sap_mapping[v]
                break
        
        if sap_info:
            clean_name = sap_info['CardName']
            if sap_info['CardCode']:
                cnpj_stats[cnpj]['code'] = sap_info['CardCode']
            # Usa nome original (ex: Atacadão S/A)
            cnpj_stats[cnpj]['name'] = clean_name
            
            grp = sap_info['GroupName']
            if "Atacad" in grp or "Oeste" in grp:
                cnpj_stats[cnpj]['group'] = "Atacadistas OESTE / SP"
            elif "Alimentar" in grp or "Giro" in grp:
                cnpj_stats[cnpj]['group'] = "Alimentar e Farma"
            else:
                cnpj_stats[cnpj]['group'] = grp
        else:
            api_name = get_api_data(cnpj)
            if api_name:
                cnpj_stats[cnpj]['name'] = api_name
    # -----------------------------------------

    # Aggregação final
    group_stats = {}
    total_success_count = 0
    total_error_count = 0
    
    for cnpj, stats in cnpj_stats.items():
        grp = stats['group']
        code = stats['code']
        total_success_count += stats['success']
        total_error_count += stats['error']
        
        if grp not in group_stats:
            group_stats[grp] = {'total_success': 0, 'total_error': 0, 'clients': {}}
            
        group_stats[grp]['total_success'] += stats['success']
        group_stats[grp]['total_error'] += stats['error']
        
        if code not in group_stats[grp]['clients']:
            group_stats[grp]['clients'][code] = {
                'name': stats['name'], 'success': 0, 'error': 0, 
                'error_types': {}, 'success_orders': [], 'error_orders': [], 
                'corrected_orders': [], 'last_transaction_date': stats['last_transaction_date']
            }

        client_ref = group_stats[grp]['clients'][code]
        client_ref['success'] += stats['success']
        client_ref['error'] += stats['error']
        
        # Mantém listas únicas de pedidos ao agregar múltiplos CNPJs no mesmo CardCode SAP
        for ord_id in stats['success_orders']:
            if ord_id not in client_ref['success_orders']:
                client_ref['success_orders'].append(ord_id)
        
        for ord_id in stats['error_orders']:
            if ord_id not in client_ref['error_orders']:
                client_ref['error_orders'].append(ord_id)
        
        for e_msg, e_count in stats['errors'].items():
            client_ref['error_types'][e_msg] = client_ref['error_types'].get(e_msg, 0) + e_count
            
        if stats['last_transaction_date'] > client_ref['last_transaction_date']:
            client_ref['last_transaction_date'] = stats['last_transaction_date']

    return {
        "groups": group_stats,
        "metrics": {
            "total_calls": total_success_count + total_error_count,
            "success": total_success_count,
            "error": total_error_count
        }
    }


def process_queue_document(doc_snapshot, changes, read_time):
    """Callback triggered whenever a document is added or modified in the 'search_jobs' collection."""
    for change in changes:
        if change.type.name == 'ADDED':
            doc = change.document
            data = doc.to_dict()
            
            # Só pega quem estiver como pending
            if data and data.get('status') == 'pending':
                print(f"[JOB] Processando solicitação pendente: {doc.id}")
                
                # Marcar como 'processing' pra ninguém mais pegar
                doc.reference.update({'status': 'processing'})
                
                try:
                    query = data.get('query_params', {})
                    start_date = query.get('start_date', datetime.now().strftime("%d-%m-%Y"))
                    end_date = query.get('end_date', datetime.now().strftime("%d-%m-%Y"))
                    
                    # Roda o processamento real no Linux
                    result = process_logs(start_date, end_date)
                    
                    # Salva no cache
                    cache_id = f"{start_date}_{end_date}"
                    db.collection('search_cache').document(cache_id).set({
                        'result_data': result,
                        'cached_at': firestore.SERVER_TIMESTAMP,
                        'query_params': query
                    })

                    # Salva no firebase o payload completinho do job
                    doc.reference.update({
                        'status': 'completed',
                        'result_data': result,
                        'completed_at': firestore.SERVER_TIMESTAMP
                    })
                    print(f"[JOB] Sucesso e em Cache: {doc.id} ({cache_id})")
                    
                except Exception as e:
                    print(f"[JOB] ERRO {doc.id}: {str(e)}")
                    doc.reference.update({
                        'status': 'error',
                        'error_message': str(e),
                        'completed_at': firestore.SERVER_TIMESTAMP
                    })

if __name__ == '__main__':
    print("Iniciando Worker de Conectores NeoGrid (Linux -> Firebase)")
    
    # Criar listener na coleção
    col_query = db.collection('search_jobs')
    watch = col_query.on_snapshot(process_queue_document)
    
    # Manter o worker rodando indefinidamente
    print("Escutando fila 'search_jobs' no Firestore... Pressione Ctrl+C para sair.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Finalizando Worker.")
