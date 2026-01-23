# Script to inject a test order using SqlClient to avoid escaping issues

$server = "192.168.1.177,1433"
$database = "RUST0N_PRODUCAO"
$user = "sa"
$password = '$@pRus70n#'

$testOrderId = "TESTE_" + (Get-Date -Format "HHmmss")
$cnpj = "45543915022231"

# Simple test payload
$payload = '{"cabecalho":{"funcao":"9","tipoPedido":"001","numeroPedidoComprador":"' + $testOrderId + '","cnpjComprador":"' + $cnpj + '"},"itens":{"item":[{"numeroSequencialItem":"0001","codigoProduto":"90896187","quantidadePedida":"1.00"}]}}'

$connString = "Server=$server;Database=$database;User Id=$user;Password=$password;Encrypt=False;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection $connString

try {
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "INSERT INTO [dbo].[SPS_LOG_EDI] (STATUS, TIPO_DOCUMENTO, DATA_IMPORTACAO, DOCID, NUMERO_PED_COMPRADOR, ARQUIVO) VALUES (@status, 5, GETDATE(), @docid, @orderid, @json)"
    
    $cmd.Parameters.AddWithValue("@status", "Novo") | Out-Null
    $cmd.Parameters.AddWithValue("@docid", $testOrderId) | Out-Null
    $cmd.Parameters.AddWithValue("@orderid", $testOrderId) | Out-Null
    $cmd.Parameters.AddWithValue("@json", $payload) | Out-Null
    
    $rows = $cmd.ExecuteNonQuery()
    
    Write-Host "Success! Injected $rows row(s). Test Order ID: $testOrderId"
}
catch {
    Write-Error "SQL Error: $_"
}
finally {
    if ($conn.State -eq 'Open') { $conn.Close() }
}
