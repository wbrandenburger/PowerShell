# ===========================================================================
#   InstallProfile.ps1 ------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$pwsh_path = Split-Path -Path $path  -Parent

$settings_file = Join-Path -Path $path -ChildPath "sciprofile.json"
$import_file = Join-Path -Path $path -ChildPath "import.json"
$refresh_cmd = Join-Path -Path $path -ChildPath "RefreshEnv.cmd"
$settings = Get-Content -Path $settings_file | ConvertFrom-Json

$sciprofile_path = Join-Path -Path $pwsh_path -ChildPath "SciProfile"
$modules_path = Join-Path -Path $pwsh_path -ChildPath "Modules"
$sciprofile_config_file = Join-Path -Path $settings.XDG_CONFIG_HOME -ChildPath "sciprofile\config.ini"
$sciprofile_import_file = Join-Path -Path $settings.XDG_CONFIG_HOME -ChildPath "sciprofile\config\import.json"

#   environment -------------------------------------------------------------
# ---------------------------------------------------------------------------
$env_module_path = [System.Environment]::GetEnvironmentVariable("PSModulePath", "process")
if (-not $($env_module_path -match $($modules_path -replace "\\", "\\"))){
    [System.Environment]::SetEnvironmentVariable("PSModulePath", $env_module_path + ";" + $modules_path, "User")
}

[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $settings.XDG_CONFIG_HOME, "User")
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_DIRS", "$($settings.XDG_CONFIG_HOME);", "User")

if (-not $(Test-Path -Path $settings.XDG_CONFIG_HOME)) {
    New-Item -Path $settings.XDG_CONFIG_HOME -ItemType Directory
}

Start-Process -FilePath $refresh_cmd -Wait -NoNewWindow

#   install -----------------------------------------------------------------
# ---------------------------------------------------------------------------
Install-Module SciProfile -Scope CurrentUser -AllowClobber -Force

Start-Process -FilePath pwsh -Wait -NoNewWindow

#   configuration -----------------------------------------------------------
# ---------------------------------------------------------------------------
Get-IniContent -FilePath $sciprofile_config_file | Set-IniContent -NameValuePairs @{"module-dir"=$modules_path} -Sections "sciprofile" |  Set-IniContent -NameValuePairs @{"scripts-dir"=$sciprofile_path } -Sections "user" | Out-IniFile $sciprofile_config_file -Force -Pretty -Loose

if (-not $(Test-Path -Path $sciprofile_import_file )) {
    Copy-Item -Path $import_file -Destination $sciprofile_import_file -Force
}

Start-Process -FilePath pwsh -Wait -NoNewWindow
