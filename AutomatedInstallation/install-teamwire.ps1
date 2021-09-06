Param(
    [Switch] $OnlyDownload
)

. "./AutomatedInstallation/utils.ps1"

# Downloading TCP IP Manager

$id = 'Teamwire'
$msi_tcp_ip = Join-Path -Path $temp_path -ChildPath "teamwire.exe"
$url_tcp_ip = 'https://desktop.teamwire.eu/download.php?platform=win32&lang=de'

$result = getInstaller -Path $msi_tcp_ip -Url $url_tcp_ip -Identifier $id
if (-not $OnlyDownload -and -not $result) { . $msi_tcp_ip }
