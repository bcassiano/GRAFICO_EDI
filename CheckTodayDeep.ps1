$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT TOP 5
    ID,
    DATA_IMPORTACAO,
    DESCR_ERRO
FROM [dbo].[SPS_LOG_EDI]
ORDER BY ID DESC
"@

$queryToday = @"
SELECT count(*) as CountToday
FROM [dbo].[SPS_LOG_EDI]
WHERE DATA_IMPORTACAO LIKE '%Jan 20 2026%' 
   OR DATA_IMPORTACAO LIKE '%2026-01-20%'
"@

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $connection.Open()

    # Get Top 5 Latest
    Write-Host "--- Latest 5 Records ---"
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) > $null
    $dataset.Tables[0] | Format-Table -AutoSize

    # Check specifically for today's date strings
    Write-Host "--- Count for Today (Jan 20) ---"
    $command2 = New-Object System.Data.SqlClient.SqlCommand($queryToday, $connection)
    $result = $command2.ExecuteScalar()
    Write-Host "Records found for today: $result"
    
    $connection.Close()
}
catch {
    Write-Error "Database query failed: $_"
}
