#region - chocolately installer work arounds. Main issue is use of write-host
function global:Write-Host
{
    Param(
        [Parameter(Mandatory,Position = 0)]
        $Object,
        [Switch]
        $NoNewLine,
        [ConsoleColor]
        $ForegroundColor,
        [ConsoleColor]
        $BackgroundColor
    )
    #Redirecting Write-Host -> Write-Verbose.
    Write-Verbose $Object
}
#endregion

function Get-FileDownload {
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$url,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$file
    )
    # Set security protocol preference to avoid the download error if the machine has disabled TLS 1.0 and SSLv3
    # See: https://chocolatey.org/install (Installing With Restricted TLS section)
    # Since cChoco requires at least PowerShell 4.0, we have .NET 4.5 available, so we can use [System.Net.SecurityProtocolType] enum values by name.
    $securityProtocolSettingsOriginal = [System.Net.ServicePointManager]::SecurityProtocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls -bor [System.Net.SecurityProtocolType]::Ssl3

    Write-Verbose "Downloading $url to $file"
    $downloader = new-object -TypeName System.Net.WebClient
    $downloader.DownloadFile($url, $file)

    [System.Net.ServicePointManager]::SecurityProtocol = $securityProtocolSettingsOriginal
}

Function Install-Chocolatey {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstallDir,

        [parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1'
    )
    Write-Verbose 'Install-Chocolatey'

    #Create install directory if it does not exist
    If(-not (Test-Path -Path $InstallDir)) {
        Write-Verbose "[ChocoInstaller] Creating $InstallDir"
        New-Item -Path $InstallDir -ItemType Directory
    }

    #Set permanent EnvironmentVariable
    Write-Verbose 'Setting ChocolateyInstall environment variables'
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', $InstallDir, [EnvironmentVariableTarget]::Machine)
    $env:ChocolateyInstall = [Environment]::GetEnvironmentVariable('ChocolateyInstall','Machine')
    Write-Verbose "Env:ChocolateyInstall has $env:ChocolateyInstall"

    #Download an execute install script
    $tempPath = Join-Path -Path $env:TEMP -ChildPath ([GUID]::NewGuid().ToString())
    New-Item -Path $tempPath -ItemType Directory | Out-Null
    $file = Join-Path -Path $tempPath -ChildPath 'install.ps1'
    Get-FileDownload -url $ChocoInstallScriptUrl -file $file
    . $file

    #refresh after install
    Write-Verbose 'Adding Choco to path'
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine')
    if ($env:path -notlike "*$InstallDir*") {
        $env:Path += ";$InstallDir"
    }

    Write-Verbose "Env:Path has $env:path"
    #InstallChoco $InstallDir
    $Null = Choco
    Write-Verbose 'Finish InstallChoco'
}

Export-ModuleMember -Function *-TargetResource