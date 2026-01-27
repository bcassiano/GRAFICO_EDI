$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT 
    JSON_VALUE(ARQUIVO, '$.cabecalho.cnpjComprador') AS CNPJ,
    STATUS,
    COUNT(*) as Count
FROM [dbo].[SPS_LOG_EDI]
GROUP BY JSON_VALUE(ARQUIVO, '$.cabecalho.cnpjComprador'), STATUS
ORDER BY CNPJ
"@

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) > $null
    
    $connection.Close()

    if ($dataset.Tables.Count -gt 0) {
        $dataset.Tables[0] | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Database query failed: $_"
}
