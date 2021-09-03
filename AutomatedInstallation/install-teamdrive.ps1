. "./AutomatedInstallation/utils.ps1"

# Downloading TCP IP Manager

$id = 'TeamDrive - 4.7.1'
$msi_tcp_ip = Join-Path -Path $temp_path -ChildPath "teamdrive-4.7.1.exe"
$url_tcp_ip = 'https://download.teamdrive.net/4.7.1.3011/TMDR/win-x64/Install-TeamDrive-4.7.1.3011_TMDR.exe'

$result = getInstaller -Path $msi_tcp_ip -Url $url_tcp_ip -Identifier $id
if ($env:AutoInstall -and -not $result) { . $msi_tcp_ip }
