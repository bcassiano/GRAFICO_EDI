$connectionString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$@pRus70n#;TrustServerCertificate=True"
$query = "INSERT INTO [dbo].[SPS_LOG_EDI] (DATA_IMPORTACAO, TIPO, DESCR_ERRO, ID_PEDIDO, ARQUIVO) VALUES ('2026-01-21 12:00:00', 'Teste', 'Log de teste do Agente', '0', '{}')"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.ExecuteNonQuery()
$connection.Close()

Write-Output "Write Test Completed"
