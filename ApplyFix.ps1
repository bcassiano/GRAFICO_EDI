$pass = '$@pRus70n#'
$connString = "Server=192.168.1.177,1433;Database=RUST0N_PRODUCAO;User Id=sa;Password=$pass;Encrypt=False;TrustServerCertificate=True;"
$inputFile = "SBO_SP_TransactionNotification.sql"
$outputFile = "SBO_SP_TransactionNotification_Fixed.sql"

try {
    # Read file content
    $content = [System.IO.File]::ReadAllText($inputFile, [System.Text.Encoding]::UTF8)

    # Ensure it's ALTER
    $content = $content -replace "(?i)CREATE\s+(PROCEDURE|PROC)\s+", "ALTER PROCEDURE "


    # Define the fix logic
    $fixLogic = "
                -- FIX: Zerar frete para Fantastico (F001051)
                IF @U_Transportadora = 'F001051'
                BEGIN
                    SET @U_Valor_Frete = 0
                    SET @U_Valor_Seguro = 0
                    SET @U_TotalTaxaEntrega = 0
                    SET @U_Valor_Total_Frete = 0
                END
"

    # Find insertion point (after assignments)
    # Looking for a known assignment line near the update
    # Based on previous analysis: SET @U_TotalTaxaEntrega = ...
    
    # We use Regex to matches the line effectively
    $pattern = "(SET @U_TotalTaxaEntrega\s*=\s*\(SELECT\s*.*?\))"
    
    if ($content -match $pattern) {
        $content = $content -replace $pattern, "`$1$fixLogic"
        Write-Output "Fix logic inserted."
    }
    else {
        # Fallback: try finding SET @U_Valor_Frete = ... lines and append after the block
        # Maybe search for the UPDATE statement start
        $updatePattern = "(UPDATE \[@BIM_ORDEMCARGA\])"
        if ($content -match $updatePattern) {
            # Insert BEFORE the Update
            $content = $content -replace $updatePattern, "$fixLogic`n`$1"
            Write-Output "Fix logic inserted before UPDATE."
        }
        else {
            Write-Error "Could not find insertion point."
            exit 1
        }
    }

    # Save fixed file
    [System.IO.File]::WriteAllText($outputFile, $content, [System.Text.Encoding]::UTF8)
    Write-Output "Fixed SQL saved to $outputFile"

    # Execute the SQL
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $connection.Open()
    
    # Using SMO or just Split by GO?
    # Simple T-SQL usually works if it's just ALTER PROCEDURE without multiple batches.
    # PROCEDURE definition often contains GO. We need to handle that.
    # We'll just execute the whole string, assuming it's one batch (Procedure def usually is)
    # But usually SBO_SP has SET ANSI_NULLS ON etc before it.
    
    # Simple split by "GO" for safety
    $batches = $content -split "(?m)^\s*GO\s*$"
    
    foreach ($batch in $batches) {
        if (-not [string]::IsNullOrWhiteSpace($batch)) {
            $command = New-Object System.Data.SqlClient.SqlCommand($batch, $connection)
            $command.ExecuteNonQuery()
        }
    }
    
    $connection.Close()
    Write-Output "Procedure updated successfully."

}
catch {
    Write-Error "Erro: $_"
}
