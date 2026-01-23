$query = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RAL_LOGS_ERRO_EDI_PWA'"
$results = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`"" | ConvertFrom-Json
$results | Select-Object COLUMN_NAME | Format-Table -AutoSize
