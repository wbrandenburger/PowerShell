# ===========================================================================
#   InstallProfile.ps1 ------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$pwsh_path = Split-Path -Path $path  -Parent

$import_file = Join-Path -Path $path -ChildPath "import.json"
$XDG_CONFIG_HOME = [System.Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME")

$sciprofile_path = Join-Path -Path $pwsh_path -ChildPath "SciProfile"
$modules_path = Join-Path -Path $pwsh_path -ChildPath "Modules"
$sciprofile_config_file = Join-Path -Path $XDG_CONFIG_HOME -ChildPath "sciprofile\config.ini"
$sciprofile_import_file = Join-Path -Path $XDG_CONFIG_HOME -ChildPath "sciprofile\config\import.json"

#   environment -------------------------------------------------------------
# ---------------------------------------------------------------------------
# @todo[to change]: check environment variables, abort if they do not exist. prompt user to set variables
# $env_module_path = [System.Environment]::GetEnvironmentVariable("PSModulePath", "process")
# if (-not $($env_module_path -match $($modules_path -replace "\\", "\\"))){
#     [System.Environment]::SetEnvironmentVariable("PSModulePath", $env_module_path + ";" + $modules_path, "User")
# }

if (-not $(Test-Path -Path )) {
    New-Item -Path $XDG_CONFIG_HOME -ItemType Directory
}

#   install -----------------------------------------------------------------
# ---------------------------------------------------------------------------
# @todo[to change]: install module only if it is not available, instead update module
# $module = Get-Module -ListAvailable
# $module_list = 
# if ($module)

Install-Module SciProfile -Scope CurrentUser -AllowClobber -Force

Start-Process -FilePath pwsh -Wait -NoNewWindow

#   configuration -----------------------------------------------------------
# ---------------------------------------------------------------------------
Get-IniContent -FilePath $sciprofile_config_file | Set-IniContent -NameValuePairs @{"module-dir"=$modules_path} -Sections "sciprofile" |  Set-IniContent -NameValuePairs @{"scripts-dir"=$sciprofile_path } -Sections "user" | Out-IniFile $sciprofile_config_file -Force -Pretty -Loose

if (-not $(Test-Path -Path $sciprofile_import_file )) {
    Copy-Item -Path $import_file -Destination $sciprofile_import_file -Force
}

Start-Process -FilePath pwsh -Wait -NoNewWindow
