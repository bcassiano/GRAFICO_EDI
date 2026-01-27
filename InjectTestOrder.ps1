param (
    [string]$JsonFile = "sample_payload_45543915026903.json"
)

$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

if (-not (Test-Path $JsonFile)) {
    Write-Error "File $JsonFile not found!"
    exit
}

$jsonContent = Get-Content -Path $JsonFile -Raw
# Escape single quotes for SQL
$escapedJson = $jsonContent.Replace("'", "''")

$query = "INSERT INTO [dbo].[SPS_LOG_EDI] (TIPO_DOCUMENTO, STATUS, DESCR_ERRO, DATA_IMPORTACAO, ARQUIVO) VALUES (5, 'TESTE_INJECAO', 'Injeção Manual de Teste', GETDATE(), '$escapedJson')"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()
    $command.ExecuteNonQuery()
    $connection.Close()
    Write-Output "Successfully injected test order from $JsonFile"
}
catch {
    Write-Error "Database injection failed: $_"
}
