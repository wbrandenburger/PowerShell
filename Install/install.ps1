# ===========================================================================
#   InstallProfile.ps1 ------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$settings_file = Join-Path -Path $path -ChildPath "sciprofile.json"
$refresh_cmd = Join-Path -Path $path -ChildPath "RefreshEnv.cmd"
$settings = Get-Content -Path $settings_file | ConvertFrom-Json

#   environment -------------------------------------------------------------
# ---------------------------------------------------------------------------
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $settings.XDG_CONFIG_HOME , "User")
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$($settings.XDG_CONFIG_DIRS);", "User")

Start-Process -FilePath $refresh_cmd -Wait -NoNewWindow

#   install -----------------------------------------------------------------
# ---------------------------------------------------------------------------
Install-Module SciProfile -Scope CurrentUser -AllowClobber -Force
