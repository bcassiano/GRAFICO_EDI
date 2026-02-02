import paramiko
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv

load_dotenv()

# Configuration
SSH_HOST = os.getenv("SSH_HOST", "192.168.1.244")
SSH_USER = os.getenv("SSH_USER", "root")
SSH_PASS = os.getenv("SSH_PASS", "Rust0n@2023@")
REMOTE_LOG_DIR = "/SPS/PRD/integracao_neogrid/logs/"
LOCAL_LOG_DIR = r"c:\PERSONAL\BANCO_DE_DADOS\LOGS_EDI"

def sync_logs(days_back=7):
    if not os.path.exists(LOCAL_LOG_DIR):
        os.makedirs(LOCAL_LOG_DIR)

    print(f"Conectando a {SSH_HOST}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        client.connect(SSH_HOST, username=SSH_USER, password=SSH_PASS, timeout=10)
        sftp = client.open_sftp()
        
        print(f"Listando arquivos em {REMOTE_LOG_DIR}...")
        files = sftp.listdir(REMOTE_LOG_DIR)
        
        # Filter files by date (YYYY-MM-DD.log)
        today = datetime.now()
        target_dates = [(today - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(days_back)]
        
        download_count = 0
        for filename in files:
            if filename.endswith(".log"):
                date_part = filename.replace(".log", "")
                if date_part in target_dates:
                    remote_file = os.path.join(REMOTE_LOG_DIR, filename).replace('\\', '/')
                    local_file = os.path.join(LOCAL_LOG_DIR, filename)
                    
                    # Check if file already exists locally
                    if not os.path.exists(local_file):
                        print(f"Baixando {filename}...")
                        sftp.get(remote_file, local_file)
                        download_count += 1
                    else:
                        # Optional: check size if we want to update partially written files
                        remote_stat = sftp.stat(remote_file)
                        local_stat = os.stat(local_file)
                        if remote_stat.st_size > local_stat.st_size:
                            print(f"Atualizando {filename} ({local_stat.st_size} -> {remote_stat.st_size} bytes)...")
                            sftp.get(remote_file, local_file)
                            download_count += 1

        print(f"Sincronização concluída. {download_count} arquivos baixados/atualizados.")
        sftp.close()
    except Exception as e:
        print(f"Erro durante a sincronização: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    sync_logs()
