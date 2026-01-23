$cnpj = "45543915022231"
$query = "SELECT CAST(ARQUIVO AS varchar(max)) as JsonContent FROM [dbo].[SPS_LOG_EDI] WHERE CAST(ARQUIVO AS varchar(max)) LIKE '%$cnpj%'"

$results = Invoke-Expression ".\ExecQuery.ps1 -SQLQuery `"$query`"" | ConvertFrom-Json

$products = @{}

foreach ($row in $results) {
    if ($row.JsonContent) {
        try {
            $json = $row.JsonContent | ConvertFrom-Json
            # Handle array or single object for 'item'
            $items = $json.cabecalho.itens.item
            if ($null -eq $items) { $items = $json.itens.item }
            
            if ($items) {
                # Ensure array
                if ($items -isnot [System.Array]) { $items = @($items) }
                
                foreach ($item in $items) {
                    $code = $item.codigoProduto
                    $desc = $item.descricaoProduto
                    $eanForn = $json.cabecalho.eanFornecedor
                    
                    # Create a composite key to capture all info
                    $key = "$code | $desc | EAN_Header: $eanForn"
                    
                    if ($products.ContainsKey($key)) {
                        $products[$key]++
                    }
                    else {
                        $products[$key] = 1
                    }
                }
            }
        }
        catch {
            Write-Host "Error parsing JSON: $_"
        }
    }
}

$products.GetEnumerator() | Sort-Object Value -Descending | Select-Object @{N = 'Detalhes (Codigo | Descricao | Header)'; E = { $_.Name } }, @{N = 'Ocorrencias'; E = { $_.Value } } | Export-Csv -Path "missing_products_45543915022231.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Exportado para missing_products_45543915022231.csv"
