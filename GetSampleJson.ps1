$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$query = @"
SELECT TOP 1 CAST(ARQUIVO AS NVARCHAR(MAX)) AS JsonContent 
FROM [dbo].[SPS_LOG_EDI] 
WHERE STATUS = 'Erro' 
AND CAST(ARQUIVO AS NVARCHAR(MAX)) LIKE '%45543915026903%'
AND CAST(ARQUIVO AS NVARCHAR(MAX)) LIKE '%00000000000000%'
ORDER BY ID DESC
"@

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $connection.Open()

    $result = $command.ExecuteScalar()
    $connection.Close()

    if ($result) {
        $result | Out-File "c:\PERSONAL\BANCO_DE_DADOS\sample_payload_45543915026903.json" -Encoding UTF8
        Write-Host "Sample JSON saved."
    }
    else {
        Write-Host "No matching JSON found."
    }
}
catch {
    Write-Error "Database query failed: $_"
}
