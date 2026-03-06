import firebase_admin
from firebase_admin import credentials, firestore
import pymssql
import re
import json
import traceback

def clean_cnpj(c):
    return re.sub(r'[^0-9]', '', str(c))

# 1. Fetch CNPJs from Firebase cache
try:
    cred = credentials.Certificate('c:/PERSONAL/BANCO_DE_DADOS/server-agent/firebase-service-account.json')
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()
doc = db.collection('search_cache').document('11-02-2026_23-02-2026').get()
data = doc.to_dict().get('result_data', {}).get('groups', {})

unique_cnpjs = set()
for grp_data in data.values():
    for cli_code in grp_data.get('clients', {}).keys():
        unique_cnpjs.add(cli_code)

print(f"Found {len(unique_cnpjs)} unique CNPJs in Firebase for the period.")

# 2. Query SAP
candidate_map = {}
for c in unique_cnpjs:
    raw = clean_cnpj(c)
    if not raw: continue
    candidate_map[raw] = c
    candidate_map[raw.zfill(14)] = c
    trimmed = raw.lstrip('0')
    if trimmed: candidate_map[trimmed] = c

candidates = list(candidate_map.keys())
chunk_size = 50
chunks = [candidates[i:i + chunk_size] for i in range(0, len(candidates), chunk_size)]
mapping = {}

import os

try:
    conn = pymssql.connect(
        server=os.environ.get('DB_SRV', '192.168.1.85:1433'),
        user=os.environ.get('DB_USER', 'powerbi'),
        password=os.environ.get('DB_PASS', ''),
        database=os.environ.get('DB_NAME', 'RUSTON_PRODUCAO'),
        charset='UTF-8'
    )
    cursor = conn.cursor(as_dict=True)
    
    for chunk in chunks:
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
        cursor.execute(query)
        results = cursor.fetchall()
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
                clean = clean_cnpj(field)
                for variant in [clean, clean.zfill(14), clean.lstrip('0')]:
                    if variant and variant in candidate_map:
                        matched_originals.add(candidate_map[variant])
            is_new_client = card_code.upper().startswith('C')
            for original in matched_originals:
                existing = mapping.get(original, {})
                already_has_client = existing.get('CardCode', '').upper().startswith('C')
                if original not in mapping or (is_new_client and not already_has_client):
                    mapping[original] = stats
    conn.close()
    
    # Save the mapping
    with open('sap_mapping.json', 'w', encoding='utf-8') as f:
        json.dump(mapping, f, ensure_ascii=False, indent=4)
        print("Successfully generated sap_mapping.json with SAP mapping for HTML.")

except Exception as e:
    print(f"Error querying SAP: {e}")
    traceback.print_exc()
