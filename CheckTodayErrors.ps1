$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$currentDate = Get-Date -Format "yyyy-MM-dd"
Write-Host "Checking for ALL errors on or after: $currentDate"

$query = @"
SELECT TOP 50
    ID,
    DATA_IMPORTACAO,
    STATUS,
    DESCR_ERRO
FROM [dbo].[SPS_LOG_EDI]
WHERE STATUS = 'Erro'
AND TRY_CONVERT(datetime, DATA_IMPORTACAO) >= '$currentDate'
ORDER BY ID DESC
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
        $data = $dataset.Tables[0]
        $data | Format-Table -AutoSize
        Write-Host "`nTotal Errors Today: $($data.Rows.Count)"
    }
    else {
        Write-Host "No errors found for today."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
