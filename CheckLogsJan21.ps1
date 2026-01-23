Import-Module SqlServer
$connectionString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$@pRus70n#;TrustServerCertificate=True"

$query = "
SELECT COUNT(*) as CountJan21
FROM [dbo].[SPS_LOG_EDI]
WHERE CONVERT(DATE, DATA_IMPORTACAO) = '2026-01-21'
"

Invoke-Sqlcmd -Query $query -ConnectionString $connectionString
