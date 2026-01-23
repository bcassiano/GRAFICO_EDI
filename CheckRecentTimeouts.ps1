$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

# Check for timeouts today (2026-01-20)
# We expect formats like 'Jan 20 2026...' or '2026-01-20...'
# We will pull all timeouts for today and sort by recent.

$currentDate = Get-Date -Format "yyyy-MM-dd"
Write-Host "Checking for timeouts on or after: $currentDate"

$query = @"
SELECT TOP 50
    ID,
    DATA_IMPORTACAO,
    DESCR_ERRO,
    CASE 
        WHEN ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1 THEN ISNULL(JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador'), 'CNPJ N/A')
        ELSE 'JSON INVALIDO'
    END AS CNPJ
FROM [dbo].[SPS_LOG_EDI]
WHERE STATUS = 'Erro'
AND DESCR_ERRO LIKE '%timeout%'
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
        
        # Filter for "last hour" in PowerShell if needed, or just show the most recent ones.
        # User asked "if in the last hour there were timeout errors again".
        # Current time assumed ~15:26. So look for > 14:26.
        # Note: Data comes as string usually from the DB adapter if not typed strongly, but let's check.
        
        $data | Format-Table -AutoSize
        
        Write-Host "`nTotal Timeouts Today: $($data.Rows.Count)"
    }
    else {
        Write-Host "No timeout errors found for today ($currentDate)."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
