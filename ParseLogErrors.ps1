$logFile = "c:\PERSONAL\BANCO_DE_DADOS\2026-01-22.log"
$results = @()

# Read log file with Encoding Default (usually works for mixed logs) or UTF8
Get-Content $logFile -Encoding Default | Where-Object { $_ -like "*gravaLog(5,Erro*" } | ForEach-Object {
    $line = $_
    
    if ($line -match "gravaLog\(5,Erro,(.+?),,(\{.*\})") {
        $errorMsg = $matches[1]
        $jsonStr = $matches[2]
        
        try {
            $jsonObj = $jsonStr | ConvertFrom-Json
            $cnpj = $jsonObj.cabecalho.cnpjComprador
            $dataEmissao = $jsonObj.cabecalho.dataHoraEmissao
            
            # Format DataEmissao if it looks like DDMMYYYY or YYYYMMDD
            if ($dataEmissao -match "^(\d{8})") {
                # simple heuristic pass-through
            }

            $results += [PSCustomObject]@{
                CNPJ        = $cnpj
                DataEmissao = $dataEmissao
                Erro        = $errorMsg.Trim()
            }
        }
        catch {
            $results += [PSCustomObject]@{
                CNPJ        = "PARSE_ERROR"
                DataEmissao = "N/A"
                Erro        = $errorMsg.Trim()
            }
        }
    }
    elseif ($line -match "gravaLog\(5,Erro,(.+?)\)") {
        $errorMsg = $matches[1]
        $results += [PSCustomObject]@{
            CNPJ        = "SEM_PAYLOAD"
            DataEmissao = "N/A"
            Erro        = $errorMsg.Trim()
        }
    }
}

$grouped = $results | Group-Object CNPJ

Write-Host "## Relatório de Erros por CNPJ do Comprador"
foreach ($group in $grouped) {
    if ([string]::IsNullOrWhiteSpace($group.Name)) { continue }
    
    Write-Host "`n### CNPJ: $($group.Name)"
    # Using Out-String -Width 300 to prevent truncation
    $group.Group | Select-Object DataEmissao, Erro | Format-Table -AutoSize -Wrap | Out-String -Width 300 | Write-Host
}
