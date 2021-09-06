Param(
    [Switch] $OnlyDownload,
    [Switch] $SetEnv
)

. "./AutomatedInstallation/utils.ps1"

# https://www.gisinternals.com/release.php

# Downloading GDAL Core
$id = 'GDAL Core - 3.3.1'
$msi_gdal_core = Join-Path -Path $temp_path -ChildPath "gdal-core-3.3.1.msi"
$url_gdal_core = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-3-1-mapserver-7-6-4/gdal-303-1928-x64-core.msi' # GDAL-3.3.1

$result = getInstaller -Path $msi_gdal_core -Url $url_gdal_core -Identifier $id
if (-not $OnlyDownload -and -not $result) { . $msi_gdal_core }

# $url_gdal_core = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-3-mapserver-7-6-3/gdal-302-1928-x64-core.msi' # GDAL-3.2.3
# $url_gdal_core = 'http://download.gisinternals.com/sdk/downloads/release-1900-x64-gdal-3-1-3-mapserver-7-6-1/gdal-301-1900-x64-core.msi' # GDAL-3.1.3

if ($SetEnv) {
    if (-not (Get-EnvVariable -Name Path).Name.Contains("C:\Program Files\GDAL")){
        Set-EnvPath -Path "C:\Program Files\GDAL" -Scope "user"
    }

    Set-EnvVariable "GDAL_DATA" -Value "C:\Program Files\GDAL\gdal-data" -Scope "user"
    Set-EnvVariable "PROJ_LIB" -Value "C:\Program Files\GDAL\projlib" -Scope "user"
    # Set-EnvVariable "GDAL_DATA" -Value "C:\Program Files\PostgreSQL\13\gdal-data" -Scope "user"
    # Set-EnvVariable "PROJ_LIB" C:\Program Files\PostgreSQL\13\share\contrib\postgis-3.1\proj -Scope "user"
    
    Set-EnvVariable "GDAL_DRIVER_PATH" -Value "C:\Program Files\GDAL\gdalplugins" -Scope "user" 
    Set-EnvVariable "GDAL_VERSION" -Value "3.3.1" -Scope "user"

    refreshenv
}
