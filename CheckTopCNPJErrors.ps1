$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT TOP 5 ID, DESCR_ERRO
FROM [dbo].[SPS_LOG_EDI]
WHERE STATUS = 'Erro' 
AND ISJSON(CAST(ARQUIVO AS NVARCHAR(MAX))) = 1
AND JSON_VALUE(CAST(ARQUIVO AS NVARCHAR(MAX)), '$.cabecalho.cnpjComprador') = '45543915026903'
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
        $dataset.Tables[0] | Format-Table -AutoSize
    }
}
catch {
    Write-Error "Database query failed: $_"
}
