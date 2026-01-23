$query = "SELECT TOP 5 ID, DESCR_ERRO FROM [dbo].[SPS_LOG_EDI] WHERE DESCR_ERRO LIKE '%timeout%' ORDER BY ID DESC"
$results = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`"" | ConvertFrom-Json
$results | Select-Object ID, DESCR_ERRO | Format-Table -AutoSize
