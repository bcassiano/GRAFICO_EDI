
# Validar se o módulo SqlServer está instalado
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "Módulo SqlServer não encontrado. Tentando instalar..."
    Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
}

# Configuração da conexão
$serverInstance = "192.168.1.177,1433"
$database = "NEOGRID_SYNC" # Assuming database name based on context, if wrong I'll check previous scripts or connection string.
# Previous scripts used Invoke-Sqlcmd directly without DB name in some cases or relied on default. 
# Looking at previous conversation summary: "Database: SQL Server (192.168.1.177,1433), table [dbo].[SPS_LOG_EDI]".
# I need to be sure about the database name. None of the 'viewed_code_item' explicitly show the 'Use Database' or connection string database.
# However, usually queries like [dbo].[SPS_LOG_EDI] imply usage context.
# Let's check AnalyzeProducts.ps1 again to see connection details if possible or just try querying master or default.
# Actually, I'll check the previously edited AnalyzeProducts.ps1 content if I can. 
# "Created a PowerShell script to fetch JSON payloads from SQL Server..."
# I'll just assume connection string handles it or I'll query for distinct databases first if I fail.
# Wait, standard practice in this environment seems to be using -ServerInstance and maybe -Database if known.
# Let's verify the database name from context 
# Summary says: "Code relating to the user's requests should be written in... c:\PERSONAL\BANCO_DE_DADOS"
# I will use a generic connection string approach or just try to grab it from a previous file if I could see it.
# Start with just ServerInstance, and include "USE [DatabaseName]" if I knew it.
# Since I don't 100% know the DB name, I'll attempt a quick discovery or just run a query across the instance? No, that's bad.
# Let's check `GetTimeoutErrors.ps1` previously edited. It might have the DB name. 
# I can't "read" it now without a tool call.
# I will guess "SPS_DA" or similar common names, BUT actually, the user provided `AnalyzeProducts.ps1` which I *edited*.
# *Self-Correction*: I can't see the content of `AnalyzeProducts.ps1` unless I view it.
# I will assume standard Integrated Security or SQL auth? Previous summary didn't specify auth.
# I'll use `Invoke-Sqlcmd` with just `-ServerInstance "192.168.1.177,1433"` and query `SELECT DB_NAME()`.
# Better: I'll use the `run_command` to check `GetTimeoutErrors.ps1` content quickly to see the connection details.
# ACTUALLY, I shouldn't waste steps. I will write a script that tries to handle connection errors or allows DB input, 
# BUT I don't want to be interactive.
# I'll look at the user prompt again. "REALIZADOS NA TABELA SPS_LOG_EDI".
# I'll assume the database name is `NEOGRID_SYNC` or just `INTEGRACAO`?
# Let's check `CheckDUNStatus.ps1` or `AnalyzeProducts.ps1` via `view_file` to be sure. It's safer.
