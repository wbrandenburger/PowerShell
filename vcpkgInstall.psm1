# @ToDo VCPKG DSC RESOURCE
# https://github.com/Microsoft/vcpkg
Function Install-vcpkg
{
    [CmdletBinding()]
    
    [OutputType([Void])]

    Param()

    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    $CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole(     [Security.Principal.WindowsBuiltinRole]::Administrator)
    If (-not $CheckAs){
        Write-Error "Installing of vcpkg needs administrative access to system."
        Return
    }

    $vcpkg = "vcpkg"
    $vcpkgposh = "posh-vcpkg"

    $vcpkgPath = (Join-Path -Path $env:Repositories -ChildPath $vcpkg)
    $vcpkgExecutable = (Join-Path -Path $vcpkgPath -ChildPath "vcpkg.exe")
    $vcpkgBootstrap = (Join-Path -Path $vcpkgPath -ChildPath "bootstrap-vcpkg")
    $vcpkgPoshModule =  (Join-Path -Path $vcpkgPath -ChildPath "scripts\$vcpkgposh")
    $vcpkgBin = (Join-Path -Path $vcpkgPath -ChildPath "\installed\x64-windows")

    $vcpkgRepository = "https://github.com/Microsoft/vcpkg"
    

    # Clone repository
    Start-Process -FilePath sh.exe -ArgumentList "GitCloneRepository.sh $vcpkgRepository $vcpkgPath" -Wait -NoNewWindow
    Start-Process -FilePath $vcpkgBootstrap -Wait -NoNewWindow

    # Hook up user-wide integration
    Start-Process -FilePath $vcpkgExecutable -ArgumentList "integrate install" -Wait -NoNewWindow

    # Move tab-completion module to powershell shared module path
    $PoshSharedModule = (Join-Path -Path $env:PoshSharedModule -ChildPath $vcpkgposh)
    If(Test-Path -Path $PoshSharedModule ) {
        Write-Verbose "Path $PoshSharedModule exists. Module $vcpkgposh will not be moved to" 
    }
    Else {
        Copy-Item -Path $vcpkgPoshModule -Destination $PoshSharedModule -Recurse -Force
        Write-Verbose "Path $PoshSharedModule does not exists and will be copied from source."
    }

    # Set envinronment
    $EnvPath = [System.Environment]::GetEnvironmentVariable("Path","User")
    $EnvPath += ";$vcpkgPath"

    $EnvPath += ";$vcpkgBin\bin"
    $EnvPath += ";$vcpkgBin\debug\bin"
    [System.Environment]::SetEnvironmentVariable("Path", $EnvPath, "User")
    Write-Verbose "Added binary folders to environment variable path"

    [System.Environment]::SetEnvironmentVariable("vcpkg", $vcpkgBin, "User")
    Write-Verbose "Set environment variable vcpkg to $vcpkgBin"
}

Export-ModuleMember -Function "Install-vcpkg"