$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connectionString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);TrustServerCertificate=True"

$query = "INSERT INTO [dbo].[SPS_LOG_EDI] (TIPO_DOCUMENTO, STATUS, DESCR_ERRO, DATA_IMPORTACAO, ARQUIVO) VALUES (5, 'TESTE', 'Teste de escrita do Agente', '2026-01-21', '{}')"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
    $connection.Close()

    Write-Output "Write Test Completed Successfully"
}
catch {
    Write-Error "Database write failed: $_"
}
