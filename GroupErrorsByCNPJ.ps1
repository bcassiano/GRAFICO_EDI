$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT 
    CASE 
        WHEN ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1 THEN ISNULL(JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador'), 'No CNPJ Found')
        ELSE 'INVALID JSON'
    END AS CNPJ,
    COUNT(*) AS Quantidade_Erros
FROM (
    SELECT TOP 10000 ARQUIVO 
    FROM [dbo].[SPS_LOG_EDI] 
    WHERE STATUS = 'Erro' 
    ORDER BY ID DESC
) AS RecentErrors
GROUP BY 
    CASE 
        WHEN ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1 THEN ISNULL(JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador'), 'No CNPJ Found')
        ELSE 'INVALID JSON'
    END
ORDER BY Quantidade_Erros DESC
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
        $dataset.Tables[0] | Format-Table -AutoSize | Out-String | Set-Content "c:\PERSONAL\BANCO_DE_DADOS\output.txt"
        $dataset.Tables[0] | Export-Csv -Path "c:\PERSONAL\BANCO_DE_DADOS\errors_by_cnpj.csv" -NoTypeInformation -Encoding UTF8
    }
    else {
        "No data found." | Set-Content "c:\PERSONAL\BANCO_DE_DADOS\output.txt"
    }
}
catch {
    $e = $_.Exception
    $msg = "Message: " + $e.Message
    $stack = "StackTrace: " + $e.StackTrace
    "$msg`n$stack" | Set-Content "c:\PERSONAL\BANCO_DE_DADOS\error.txt"
    Write-Error $_
}
