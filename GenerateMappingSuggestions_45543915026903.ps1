# Read the missing products CSV
$inputFile = "missing_products_45543915026903.csv"
$outputFile = "suggested_mapping_45543915026903.csv"

if (-not (Test-Path $inputFile)) {
    Write-Error "Input file $inputFile not found."
    exit 1
}

$csvData = Import-Csv -Path $inputFile -Encoding UTF8

$mappingResults = @()

foreach ($row in $csvData) {
    # Extract the code from the "Detalhes..." column. Format is "CODE | DESC | ... "
    $rawField = $row.'Detalhes (Codigo | Descricao | Header)'
    
    if ($rawField -match "^(.*?)\s*\|\s*(.*?)\s*\|") {
        $dunCode = $matches[1]
        $desc = $matches[2]
        
        if ($dunCode -eq "00000000000000") {
            # Try to map by description since code is useless
            # Simple heuristic: Replace spaces with % for LIKE search
            $searchTerm = $desc -replace ' ', '%'
            $query = "SELECT TOP 1 ItemCode, ItemName FROM OITM WHERE ItemName LIKE '%$searchTerm%' AND ValidFor = 'Y'"
            
            try {
                $jsonResult = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`""
                $sapItem = $jsonResult | ConvertFrom-Json
                
                if ($sapItem -and $sapItem.ItemCode) {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Descricao Neogrid'    = $desc
                        'Item SAP Sugerido'    = $sapItem.ItemCode
                        'Descricao SAP'        = $sapItem.ItemName
                        'Metodo'               = "Por Descricao"
                    }
                }
                else {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Descricao Neogrid'    = $desc
                        'Item SAP Sugerido'    = "NAO ENCONTRADO"
                        'Descricao SAP'        = "-"
                        'Metodo'               = "Falha na busca"
                    }
                }
            }
            catch {
                $e = $_
                Write-Host "Error searching for $desc : $e"
            }
        
        }
        else {
            # Standard DUN search
            $query = "SELECT TOP 1 ItemCode, ItemName FROM OITM WHERE CodeBars = '$dunCode' AND ValidFor = 'Y'"
            try {
                $jsonResult = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`""
                $sapItem = $jsonResult | ConvertFrom-Json
                
                if ($sapItem -and $sapItem.ItemCode) {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Descricao Neogrid'    = $desc
                        'Item SAP Sugerido'    = $sapItem.ItemCode
                        'Descricao SAP'        = $sapItem.ItemName
                        'Metodo'               = "Por EAN/DUN"
                    }
                }
                else {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Descricao Neogrid'    = $desc
                        'Item SAP Sugerido'    = "NAO ENCONTRADO"
                        'Descricao SAP'        = "-"
                        'Metodo'               = "-"
                    }
                }
            }
            catch {
                $e = $_
                Write-Host "Error searching for $dunCode - $e"
            }
        }
    }
}

$mappingResults | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8
$mappingResults | Format-Table -AutoSize
Write-Host "Sugestões de mapeamento exportadas para $outputFile"
