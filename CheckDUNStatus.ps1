$duns = @(
    '17896584300014',
    '17896584301394',
    '17896584301301',
    '27896584301407',
    '17896584301325',
    '17896584300595',
    '17896584300359',
    '27896584300042',
    '17896584300076',
    '17896584300038',
    '27896584300103',
    '17896584301349',
    '17896584300274',
    '17896584300267',
    '17896584301332'
)

$dunsList = "'" + ($duns -join "','") + "'"

$query = "
SELECT 'OITM' as Source, ItemCode, ItemName, CodeBars as Code, FrozenFor, ValidFor 
FROM OITM 
WHERE CodeBars IN ($dunsList)

UNION ALL

SELECT 'OSCN' as Source, ItemCode, '' as ItemName, Substitute as Code, '' as FrozenFor, '' as ValidFor
FROM OSCN
WHERE Substitute IN ($dunsList) AND CardCode = 'C003612'
"

Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`"" | ConvertFrom-Json | Select-Object Source, ItemCode, Code, FrozenFor, ValidFor | Format-Table -AutoSize
