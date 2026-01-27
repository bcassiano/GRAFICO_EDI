param (
    [string]$SQLQuery,
    [switch]$Raw
)

# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

$connString = "Server=$($config.DB_SERVER);Database=$($config.DB_NAME);User Id=$($config.DB_USER);Password=$($config.DB_PASS);Encrypt=False;TrustServerCertificate=True;"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
    $command = New-Object System.Data.SqlClient.SqlCommand($SQLQuery, $connection)
    $connection.Open()

    if ($Raw) {
        $result = $command.ExecuteScalar()
        if ($result -ne $null) {
            Write-Output $result.ToString()
        }
    }
    else {
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) > $null
        if ($dataset.Tables.Count -gt 0 -and $dataset.Tables[0].Rows.Count -gt 0) {
            $dataset.Tables[0] | ConvertTo-Json -Depth 2 -Compress
        }
        else {
            Write-Output "[]"
        }
    }
    $connection.Close()
}
catch {
    Write-Error "Erro: $_"
}
