$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

$fixSql = Get-Content -Path "SBO_SP_TransactionNotification_Fixed.sql" -Raw

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($fixSql, $connection)
    $connection.Open()
    $command.ExecuteNonQuery()
    $connection.Close()
    Write-Output "Fix Applied Successfully"
}
catch {
    Write-Error "Database update failed: $_"
}
