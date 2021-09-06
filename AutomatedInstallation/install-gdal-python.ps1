Param(
    [Switch] $OnlyDownload
)

. "./AutomatedInstallation/utils.ps1"

# Downloading GDAL for Python
$id = 'GDAL for Python - 3.3.1 - p3.7'
$msi_gdal_python = Join-Path -Path $temp_path -ChildPath "gdal-py-3.3.1-p3.7.msi"
$url_gdal_python = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-3-1-mapserver-7-6-4/GDAL-3.3.1.win-amd64-py3.7.msi' # GDAL-3.2.3

$result = getInstaller -Path $msi_gdal_python -Url $url_gdal_python -Identifier $id
if (-not $OnlyDownload -and -not $result) { . $msi_gdal_python }

# Downloading GDAL for Python
$id = 'GDAL for Python - 3.3.1 - p3.9'
$msi_gdal_python = Join-Path -Path $temp_path -ChildPath "gdal-py-3.3.1-p3.9.msi"
$url_gdal_python = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-3-1-mapserver-7-6-4/GDAL-3.3.1.win-amd64-py3.9.msi' # GDAL-3.2.3

$result = getInstaller -Path $msi_gdal_python -Url $url_gdal_python -Identifier $id
# if ($env:AutoInstall -and -not $result) { . $msi_gdal_python }

# $url_gdal_python = 'https://download.gisinternals.com/sdk/downloads/release-1928-x64-gdal-3-2-3-mapserver-7-6-3/GDAL-3.2.3.win-amd64-py3.7.msi' # GDAL-3.2.3
# $url_gdal_python = 'http://download.gisinternals.com/sdk/downloads/release-1900-x64-gdal-3-1-3-mapserver-7-6-1/GDAL-3.1.3.win-amd64-py3.7.msi' # GDAL-3.1.3

# https://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal
