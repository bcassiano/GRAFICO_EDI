# Read the missing products CSV
$inputFile = "missing_products_45543915022231.csv"
$csvData = Import-Csv -Path $inputFile -Encoding UTF8

$mappingResults = @()

foreach ($row in $csvData) {
    # Extract the code from the "Detalhes..." column. Format is "CODE | DESC | ... "
    $rawField = $row.'Detalhes (Codigo | Descricao | Header)'
    if ($rawField -match "^(\d+)\s*\|") {
        $dunCode = $matches[1]
        
        # Query SAP for this specific DUN, looking for ACTIVE items first
        # We prioritize ValidFor='Y' and FrozenFor='N'
        $query = "SELECT TOP 1 ItemCode, ItemName FROM OITM WHERE CodeBars = '$dunCode' AND ValidFor = 'Y' AND FrozenFor = 'N'"
        
        # Execute Query
        try {
            # Note: We use existing ExecQuery logic. Assuming it returns JSON array text.
            $jsonResult = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`""
            $sapItem = $jsonResult | ConvertFrom-Json
            
            if ($sapItem -and $sapItem.ItemCode) {
                $mappingResults += [PSCustomObject]@{
                    'Codigo Neogrid (DUN)' = $dunCode
                    'Item SAP Sugerido'    = $sapItem.ItemCode
                    'Descricao SAP'        = $sapItem.ItemName
                    'Status SAP'           = "ATIVO"
                }
            }
            else {
                # Try finding ANY item even if inactive, just to show existence
                $queryAny = "SELECT TOP 1 ItemCode, ItemName, FrozenFor, ValidFor FROM OITM WHERE CodeBars = '$dunCode'"
                $jsonResultAny = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$queryAny`""
                $sapItemAny = $jsonResultAny | ConvertFrom-Json
                
                if ($sapItemAny -and $sapItemAny.ItemCode) {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Item SAP Sugerido'    = $sapItemAny.ItemCode
                        'Descricao SAP'        = $sapItemAny.ItemName
                        'Status SAP'           = "INATIVO/CONGELADO"
                    }
                }
                else {
                    $mappingResults += [PSCustomObject]@{
                        'Codigo Neogrid (DUN)' = $dunCode
                        'Item SAP Sugerido'    = "NAO ENCONTRADO"
                        'Descricao SAP'        = "-"
                        'Status SAP'           = "-"
                    }
                }
            }
        }
        catch {
            Write-Host "Error processing DUN $dunCode : $_"
        }
    }
}

$mappingResults | Export-Csv -Path "suggested_mapping.csv" -NoTypeInformation -Encoding UTF8
$mappingResults | Format-Table -AutoSize
