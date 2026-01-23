$connectionString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$@pRus70n#;TrustServerCertificate=True"
$query = "INSERT INTO [dbo].[SPS_LOG_EDI] (TIPO_DOCUMENTO, STATUS, DESCR_ERRO, DATA_IMPORTACAO, ARQUIVO) VALUES (5, 'TESTE', 'Teste de escrita do Agente', '2026-01-21', '{}')"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $query
$command.ExecuteNonQuery()
$connection.Close()

Write-Output "Write Test Completed Successfully"
