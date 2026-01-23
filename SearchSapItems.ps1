$ErrorActionPreference = "Stop"

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

$queries = @(
    "SELECT ItemCode, ItemName FROM OITM WHERE ItemName LIKE '%ARROZ%FANTASTICO%' AND ValidFor = 'Y'",
    "SELECT ItemCode, ItemName FROM OITM WHERE ItemName LIKE '%FEIJAO%FANTASTICO%' AND ValidFor = 'Y'",
    "SELECT ItemCode, ItemName FROM OITM WHERE ItemName LIKE '%SABOR%CARIOCA%'"
)

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $connection.Open()

    foreach ($q in $queries) {
        Write-Host "Executing: $q"
        $command = New-Object System.Data.SqlClient.SqlCommand($q, $connection)
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) > $null
        
        if ($dataset.Tables.Count -gt 0) {
            $dataset.Tables[0] | Format-Table -AutoSize
        }
    }
    
    $connection.Close()
}
catch {
    Write-Error "Database query failed: $_"
}
