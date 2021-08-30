. "./AutomatedInstallation/utils.ps1"

# Downloading GDAL Core
$id = 'GDAL Core - 3.2.3'
$msi_gdal_core = Join-Path -Path $temp_path -ChildPath "gdal-core-3.2.3.msi"
$url_gdal_core = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-3-mapserver-7-6-3/gdal-302-1928-x64-core.msi' # GDAL-3.2.3

$result = getInstaller -Path $msi_gdal_core -Url $url_gdal_core -Identifier $id
if ($env:AutoInstall -and -not $result) { . $msi_gdal_core }

# $url_gdal_core = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-2-mapserver-7-6-2/gdal-302-1928-x64-core.msi' # GDAL-3.2.2
# $url_gdal_core = 'http://download.gisinternals.com/sdk/downloads/release-1900-x64-gdal-3-1-3-mapserver-7-6-1/gdal-301-1900-x64-core.msi' # GDAL-3.1.3

# Downloading GDAL for Python
$id = 'GDAL for Python - 3.2.3'
$msi_gdal_python = Join-Path -Path $temp_path -ChildPath "gdal-py-3.2.3.msi"
$url_gdal_python = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-3-mapserver-7-6-3/GDAL-3.2.3.win-amd64-py3.7.msi' # GDAL-3.2.3

$result = getInstaller -Path $msi_gdal_python -Url $url_gdal_python -Identifier $id
if ($env:AutoInstall -and -not $result) { . $msi_gdal_python }

# $url_gdal_python = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-2-mapserver-7-6-2/GDAL-3.2.2.win-amd64-py3.7.msi' # GDAL-3.2.2
# $url_gdal_python = 'http://download.gisinternals.com/sdk/downloads/release-1900-x64-gdal-3-1-3-mapserver-7-6-1/GDAL-3.1.3.win-amd64-py3.7.msi' # GDAL-3.1.3

if ($env:AutoSetEnvironment){
    Set-EnvPath -Path "C:\Program Files\GDAL" -Scope "user"

    Set-EnvVariable "GDAL_DATA" -Value "C:\Program Files\GDAL\gdal-data" -Scope "user"
    Set-EnvVariable "PROJ_LIB" -Value "C:\Program Files\GDAL\projlib" -Scope "user"
    # Set-EnvVariable "GDAL_DATA" -Value "C:\Program Files\PostgreSQL\13\gdal-data" -Scope "user"
    # Set-EnvVariable "PROJ_LIB" C:\Program Files\PostgreSQL\13\share\contrib\postgis-3.1\proj -Scope "user"
    
    Set-EnvVariable "GDAL_DRIVER_PATH" -Value "C:\Program Files\GDAL\gdalplugins" -Scope "user" 
    Set-EnvVariable "GDAL_VERSION" -Value "3.2.3" -Scope "user"
}
