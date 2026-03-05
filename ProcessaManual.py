import os
import sys

# Adicionar o diretório atual e a subpasta server-agent ao path para importar lib
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)
sys.path.append(os.path.join(current_dir, 'server-agent'))

from log_worker import process_logs, db, firestore

start_date = "04-03-2026"
end_date = "05-03-2026"
print(f"Iniciando processamento manual (MÉTODO DIRETO) para: {start_date} até {end_date}")

# A função process_logs já retorna o dicionário completo com 'groups' e 'metrics'
final_result = process_logs(start_date, end_date)

# Salva no cache da Coleção Correta (search_cache)
cache_id = f"{start_date}_{end_date}"
db.collection('search_cache').document(cache_id).set({
    'result_data': final_result,
    'cached_at': firestore.SERVER_TIMESTAMP,
    'query_params': {
        'start_date': start_date,
        'end_date': end_date
    }
})

print(f"Sucesso! Cache {cache_id} atualizado MANUALMENTE com a estrutura correta.")
