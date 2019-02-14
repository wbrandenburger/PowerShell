# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-6

[CmdletBinding()]
    
[OutputType()]

Param()

$User = [Security.Principal.WindowsIdentity]::GetCurrent();
$CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole(     [Security.Principal.WindowsBuiltinRole]::Administrator)
If (-not $CheckAs){
    Write-Error "Installing of vcpkg needs administrative access to system."
    Return
}

$LocalRoot = "A:"
$SharedPrefix = "A:\OneDrive"
$SharedRoot = Join-Path -Path $SharedPrefix -ChildPath "Projects"

$EnvVarUser = [System.Collections.Hashtable]::New()
[Void] $EnvVarUser.Add("LOCAL_ROOT", $LocalRoot)
[Void] $EnvVarUser.Add("LOCAL_REPO", (Join-Path -Path $LocalRoot -ChildPath "Repositories"))
[Void] $EnvVarUser.Add("LOCAL_HOME", (Join-Path -Path $LocalRoot -ChildPath "Documents"))
[Void] $EnvVarUser.Add("LOCAL_BIN", (Join-Path -Path $LocalRoot -ChildPath "System")) # @ToDo

[Void] $EnvVarUser.Add("SHARED_BIB", (Join-Path -Path $SharedPrefix -ChildPath "Libraries"))
[Void] $EnvVarUser.Add("SHARED_TEMP", (Join-Path -Path $SharedPrefix -ChildPath "Download"))
[Void] $EnvVarUser.Add("SHARED_ROOT", $SharedRoot)
[Void] $EnvVarUser.Add("SHARED_CONFIG", (Join-Path -Path $SharedRoot -ChildPath ".config"))
[Void] $EnvVarUser.Add("SHARED_PSPKG", (Join-Path -Path $SharedRoot -ChildPath "PSPackages")) # @ToDo
[Void] $EnvVarUser.Add("SHARED_DEV", (Join-Path -Path $SharedRoot -ChildPath "dev"))
[Void] $EnvVarUser.Add("SHARED_COURSES", (Join-Path -Path $SharedRoot -ChildPath "Lecture"))
[Void] $EnvVarUser.Add("SHARED_BIN", (Join-Path -Path $SharedRoot -ChildPath "System"))

[Void] $EnvVarUser.Add("CMAKE_GENERATOR", "Visual Studio 15 2017 Win64")
# @ToDo Chocolatey, Python, VirtualEnv

# Set-Location Env:

Write-Host "Updating environment variables"-ForegroundColor Cyan

[System.Collections.IDictionaryEnumerator] $EnvVarUserEnum = $EnvVarUser.GetEnumerator();
While ($EnvVarUserEnum.MoveNext()){
    $TempEnvVar = [System.Environment]::GetEnvironmentVariable($EnvVarUserEnum.Key, "User")
    If (-not [Regex]::Match($TempEnvVar,[Regex]::Replace($EnvVarUserEnum.Value,"\\","\\")).Success) {
        [System.Environment]::SetEnvironmentVariable($EnvVarUserEnum.Key, $EnvVarUserEnum.Value, "User")
        Write-Host "Complete update $($EnvVarUserEnum.Key)" -ForegroundColor Yellow
    }
    Else{
        Write-Host "Env:$($EnvVarUserEnum.Key) up to date" -ForegroundColor Green
    }   
}


Write-Host "Add folders with binaries to environment variable %PATH%" -ForegroundColor Cyan

$EnvPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
If (-not [Regex]::Match($EnvPath,[Regex]::Replace("$($EnvVarUser["LOCAL_BIN"]);|$($EnvVarUser["LOCAL_BIN"])$","\\","\\")).Success) {
    $EnvPath += ";$($EnvVarUser["LOCAL_BIN"])"
    Write-Host "Complete update %PATH%: $($EnvVarUser["LOCAL_BIN"])" -ForegroundColor Yellow
}
Else{
    Write-Host "%PATH% up to date" -ForegroundColor Green
} 
[System.Environment]::SetEnvironmentVariable("Path", $EnvPath, "Machine")


Write-Host "Add folders with powershell modules to environment variable %PSModulePath%" -ForegroundColor Cyan

$EnvPSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
If (-not [Regex]::Match($EnvPSModulePath,[Regex]::Replace("$($EnvVarUser["SHARED_PSPKG"]);|$($EnvVarUser["SHARED_PSPKG"])$","\\","\\")).Success) {
    $EnvPSModulePath += ";$($EnvVarUser["SHARED_PSPKG"])"
    Write-Host "Complete update %PATH%: $($EnvVarUser["SHARED_PSPKG"])" -ForegroundColor Yellow
}
Else{
    Write-Host "%PSModulePath% up to date" -ForegroundColor Green
} 
[System.Environment]::SetEnvironmentVariable("PSModulePath", $EnvPSModulePath, "Machine")

Start-Process -FilePath RefreshEnv.cmd -Wait -NoNewWindow