$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand("SELECT OBJECT_DEFINITION(OBJECT_ID('SBO_SP_TransactionNotification'))", $connection)
    $connection.Open()
    $result = $command.ExecuteScalar()
    $connection.Close()

    if ($result -ne $null) {
        $result | Out-File -FilePath "SBO_SP_TransactionNotification.sql" -Encoding UTF8
        Write-Output "Procedure dumped to SBO_SP_TransactionNotification.sql"
    }
    else {
        Write-Error "Procedure definition returned null."
    }
}
catch {
    Write-Error "Erro: $_"
}
