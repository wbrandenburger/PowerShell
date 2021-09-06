Param(
    [Switch] $DockerDesktop,
    [Switch] $LinuxKernel,
    [Switch] $OnlyDownload
)

if ($DockerDesktop) {
    choco install docker-desktop --confirm
}

if ($LinuxKernel){
    # Downloading TCP IP Manager
    
    . "./AutomatedInstallation/utils.ps1"

    $id = 'Linux Kernel'
    $msi_tcp_ip = Join-Path -Path $temp_path -ChildPath "linux-kernel.msi"
    $url_tcp_ip = 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'

    $result = getInstaller -Path $msi_tcp_ip -Url $url_tcp_ip -Identifier $id
    if (-not $OnlyDownload -and -not $result) { . $msi_tcp_ip }
}
