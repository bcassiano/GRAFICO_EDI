# Load config
try {
    $config = . "$PSScriptRoot\Get-Config.ps1"
} catch {
    Write-Error "Failed to load configuration: $_"
    exit 1
}

# Validar se o módulo SqlServer está instalado
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "Módulo SqlServer não encontrado. Tentando instalar..."
    # Note: Requires admin privileges usually
    # Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
    Write-Warning "Skipping Install-Module. Please install SqlServer module manually if needed."
}

# Configuração da conexão
$serverInstance = $config.DB_SERVER
$database = $config.DB_NAME
$user = $config.DB_USER
$password = $config.DB_PASS

# Note: Invoke-Sqlcmd with Username/Password requires SqlServer module
# Fallback to .NET if module missing (similar to TestDBWrite) would be better, but refactoring to use config is the goal.

Write-Host "Connecting to $serverInstance..."

# Example usage (commented out to avoid execution without module)
# Invoke-Sqlcmd -ServerInstance $serverInstance -Database $database -Username $user -Password $password -Query "SELECT 1"
