. "./AutomatedInstallation/utils.ps1"

# Downloading TCP IP Manager

$id = 'Linux Kernel'
$msi_tcp_ip = Join-Path -Path $temp_path -ChildPath "linux-kernel.msi"
$url_tcp_ip = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'

$result = getInstaller -Path $msi_tcp_ip -Url $url_tcp_ip -Identifier $id
if ($env:AutoInstall -and -not $result) { . $msi_tcp_ip }
