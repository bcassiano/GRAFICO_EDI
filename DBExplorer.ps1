$ErrorActionPreference = "Stop"

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

function Execute-Query {
    param([string]$Query)
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
        $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)
        $connection.Open()
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) > $null
        $connection.Close()
        if ($dataset.Tables.Count -gt 0) {
            $dataset.Tables[0] | Format-Table -AutoSize
        } else {
            Write-Host "No results."
        }
    } catch {
        Write-Error "Error: $_"
    }
}

while ($true) {
    $inputQuery = Read-Host "SQL > "
    if ($inputQuery -eq "exit") { break }
    if ($inputQuery) {
        Execute-Query -Query $inputQuery
    }
}
