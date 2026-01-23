$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT 
    CASE 
        WHEN ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1 THEN ISNULL(JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador'), 'CNPJ N/A')
        ELSE 'JSON INVALIDO/VAZIO'
    END AS CNPJ,
    DESCR_ERRO,
    COUNT(*) AS Quantidade
FROM [dbo].[SPS_LOG_EDI]
WHERE STATUS = 'Erro'
AND TRY_CONVERT(datetime, DATA_IMPORTACAO) >= '2025-12-01 00:00:00'
AND TRY_CONVERT(datetime, DATA_IMPORTACAO) <= '2026-01-20 23:59:59'
GROUP BY 
    CASE 
        WHEN ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1 THEN ISNULL(JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador'), 'CNPJ N/A')
        ELSE 'JSON INVALIDO/VAZIO'
    END,
    DESCR_ERRO
ORDER BY Quantidade DESC
"@

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()
    
    # Increase timeout just in case
    $command.CommandTimeout = 120 

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataset) > $null
    
    $connection.Close()

    if ($dataset.Tables.Count -gt 0) {
        $outputFile = "c:\PERSONAL\BANCO_DE_DADOS\errors_report_20251201_20260120.csv"
        $dataset.Tables[0] | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported to $outputFile"
        
        # Display top 20
        $dataset.Tables[0] | Select-Object -First 20 | Format-Table -AutoSize
    }
    else {
        Write-Host "No errors found in the specified date range."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
