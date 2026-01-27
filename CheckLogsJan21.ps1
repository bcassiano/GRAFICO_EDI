$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connectionString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);TrustServerCertificate=True"

$query = "SELECT * FROM [dbo].[SPS_LOG_EDI] WHERE CONVERT(DATE, DATA_IMPORTACAO) = '2026-01-21' ORDER BY ID DESC"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) > $null

    $connection.Close()

    if ($dataset.Tables.Count -gt 0) {
        $dataset.Tables[0] | Format-Table -AutoSize
    }
    else {
        Write-Host "No logs found for Jan 21, 2026."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
