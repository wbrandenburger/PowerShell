. "./AutomatedInstallation/utils.ps1"

# Downloading TCP IP Manager

$id = 'TCP IP Manager - 4.1.1.29'
$msi_tcp_ip = Join-Path -Path $temp_path -ChildPath "tcp-ip-manager-4.1.1.29.exe"
$url_tcp_ip= 'http://downloads.sourceforge.net/tcpipmanager/TCP_IP_Manager_v4.1.1.29_x64_Setup.exe'

$result = getInstaller -Path $msi_tcp_ip -Url $url_tcp_ip -Identifier $id
if ($env:AutoInstall -and -not $result) { . $msi_tcp_ip }
