$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

$query = "SELECT TOP 1 ARQUIVO FROM [dbo].[SPS_LOG_EDI] WHERE ARQUIVO IS NOT NULL AND ARQUIVO <> '{}' ORDER BY ID DESC"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()
    $result = $command.ExecuteScalar()
    $connection.Close()

    if ($result) {
        $result | Out-File "sample.json" -Encoding UTF8
        Write-Output "Sample JSON saved to sample.json"
    } else {
        Write-Output "No JSON found."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
