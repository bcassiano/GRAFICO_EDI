$configPath = Join-Path $PSScriptRoot "config.json"
if (Test-Path $configPath) {
    Get-Content $configPath -Raw | ConvertFrom-Json
} else {
    Write-Error "Configuration file config.json not found in $PSScriptRoot."
    exit 1
}
