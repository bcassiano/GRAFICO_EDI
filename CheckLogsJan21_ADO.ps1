$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connectionString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);TrustServerCertificate=True"

$query = "SELECT COUNT(*) as CountJan21 FROM [dbo].[SPS_LOG_EDI] WHERE CONVERT(DATE, DATA_IMPORTACAO) = '2026-01-21'"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $query
$result = $command.ExecuteScalar()
$connection.Close()

Write-Output "CountJan21: $result"
