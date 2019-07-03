# @ToDo VCPKG DSC RESOURCE
# https://github.com/Microsoft/vcpkg
[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="Medium")]

[OutputType([Void])]

Param()

If (-not $PSCmdlet.ShouldProcess("Should vcpkg get built and environment varibles get cahnged?")){
    return
}

$User = [Security.Principal.WindowsIdentity]::GetCurrent();
$CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole(     [Security.Principal.WindowsBuiltinRole]::Administrator)
If (-not $CheckAs){
    Write-Error "Installing of vcpkg needs administrative access to system."

    Start-Process -FilePath PowerShell.exe -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command . $PSCommandPath" 

    Return
}

$vcpkg = "vcpkg"
$vcpkgposh = "posh-vcpkg"

$vcpkgPath = (Join-Path -Path $env:LOCAL_REPO -ChildPath $vcpkg)
$vcpkgExecutable = (Join-Path -Path $vcpkgPath -ChildPath "vcpkg.exe")
$vcpkgBootstrap = (Join-Path -Path $vcpkgPath -ChildPath "bootstrap-vcpkg")
$vcpkgPoshModule =  (Join-Path -Path $vcpkgPath -ChildPath "scripts\$vcpkgposh")
$vcpkgMUploader =  (Join-Path -Path $vcpkgPath -ChildPath "scripts\vcpkgmetricsuploader.exe")
$vcpkgBin = (Join-Path -Path $vcpkgPath -ChildPath "\installed\x64-windows")
$vcpkgEnv = "VCPKG_ROOT"
$vcpkg64Env = "VCPKG_X64_ROOT"

$vcpkgRepository = "https://github.com/Microsoft/vcpkg"


# Clone repository
Start-Process -FilePath sh.exe -ArgumentList "GitCloneRepository.sh $vcpkgRepository $vcpkgPath" -Wait -NoNewWindow

# Build vcpkg and placing vcpkg.exe in the correct location
If (Test-Path "$vcpkgExecutable") {
    Remove-Item "$vcpkgExecutable" -Force -ErrorAction SilentlyContinue -Verbose
}
If (Test-Path "$vcpkgMUploader") {
    Remove-Item "$vcpkgMUploader" -Force -ErrorAction SilentlyContinue -Verbose
}
Start-Process -FilePath $vcpkgBootstrap -ArgumentList "-win64 -Verbose" -Wait -NoNewWindow

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

# @ToDo Move cmake toolchain file to system path 
# Set envinronment

Write-Verbose "Add folders with binaries to environment variable %PATH%"

$EnvPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")

If (-not [Regex]::Match($EnvPath,[Regex]::Replace("$vcpkgPath;|$vcpkgPath$","\\","\\")).Success) {
    $EnvPath += ";$vcpkgPath"
    Write-Verbose "Add $vcpkgPath"
}
If (-not [Regex]::Match($EnvPath,[Regex]::Replace("$vcpkgBin\bin;|$vcpkgBin\bin$","\\","\\")).Success) {
    $EnvPath += ";$vcpkgBin\bin"
    Write-Verbose "Add $vcpkgPath\bin"
}
If (-not [Regex]::Match($EnvPath,[Regex]::Replace("$vcpkgBin\debug\bin;|$vcpkgBin\debug\bin$","\\","\\")).Success) {
    $EnvPath += ";$vcpkgBin\debug\bin"
    Write-Verbose "Add $vcpkgPath\debug\bin"
}

[System.Environment]::SetEnvironmentVariable("Path", $EnvPath, "Machine")


# Variable vcpkg is deprecated
If ($Env:vcpkg)
{
    Remove-Item $Env:vcpkg
}

Write-Verbose "Set environment variable %$vcpkgEnv%"
$CurrentvcpkgEnv = [System.Environment]::GetEnvironmentVariable("$vcpkgEnv", "Machine")
If (-not [Regex]::Match($CurrentvcpkgEnv,[Regex]::Replace("$vcpkgPath","\\","\\")).Success) {
    [System.Environment]::SetEnvironmentVariable("$vcpkgEnv", $vcpkgPath, "Machine")
    Write-Verbose "Add $vcpkgPath"
}

Write-Verbose "Set environment variable %$vcpkg64Env%"
$Currentvcpkg64Env = [System.Environment]::GetEnvironmentVariable("$vcpkg64Env", "User")
If (-not [Regex]::Match($Currentvcpkg64Env,[Regex]::Replace("$vcpkgBin","\\","\\")).Success) {
    [System.Environment]::SetEnvironmentVariable("$vcpkg64Env", $vcpkgBin, "User")
    Write-Verbose "Add $vcpkgBin"
}

Start-Process -FilePath RefreshEnv.cmd -Wait -NoNewWindow
# # Clean
# Start-Process -FilePath $vcpkgExecutable -ArgumentList "remove install" -Wait -NoNewWindow
# Remove-Item "$PoshSharedModule" -Force -Recurse -ErrorAction SilentlyContinue
# in System the cmake files of vcpkg