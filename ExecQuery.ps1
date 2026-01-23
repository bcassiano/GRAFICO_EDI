param (
    [string]$SQLQuery,
    [switch]$Raw
)

$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($SQLQuery, $connection)
    $connection.Open()

    if ($Raw) {
        $result = $command.ExecuteScalar()
        if ($result -ne $null) {
            Write-Output $result.ToString()
        }
    }
    else {
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) > $null
        if ($dataset.Tables.Count -gt 0 -and $dataset.Tables[0].Rows.Count -gt 0) {
            $dataset.Tables[0] | ConvertTo-Json -Depth 2 -Compress
        }
        else {
            Write-Output "[]"
        }
    }
    $connection.Close()
}
catch {
    Write-Error "Erro: $_"
}
