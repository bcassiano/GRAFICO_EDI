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
SELECT TOP 20
    JSON_VALUE(ARQUIVO, '$.cabecalho.cnpjComprador') AS CNPJ,
    COUNT(*) AS ErroCount
FROM [dbo].[SPS_LOG_EDI]
WHERE STATUS = 'Erro'
GROUP BY JSON_VALUE(ARQUIVO, '$.cabecalho.cnpjComprador')
ORDER BY COUNT(*) DESC
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
