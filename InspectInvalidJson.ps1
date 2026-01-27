$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

$query = "SELECT TOP 5 ID, ARQUIVO FROM [dbo].[SPS_LOG_EDI] WHERE STATUS='Erro' ORDER BY ID DESC"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) > $null
    
    $connection.Close()

    if ($dataset.Tables.Count -gt 0) {
        foreach ($row in $dataset.Tables[0].Rows) {
            Write-Host "--- ID: $($row.ID) ---"
            try {
                $json = $row.ARQUIVO | ConvertFrom-Json
                Write-Host "Valid JSON"
            } catch {
                Write-Host "INVALID JSON: $($_.Exception.Message)"
                Write-Host "Snippet: $($row.ARQUIVO.Substring(0, [math]::Min(50, $row.ARQUIVO.Length)))"
            }
        }
    }
}
catch {
    Write-Error "Database query failed: $_"
}
