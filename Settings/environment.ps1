# ===========================================================================
#   environment.ps1 ---------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
$python_home = "C:\Python\Python37"
[System.Environment]::SetEnvironmentVariable("PYTHONHOME", $python_home, "User")

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
$xdg_config = Join-Path -Path $Env:USERPROFILE -ChildPath ".config"
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $xdg_config, "User")
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_DIRS", $xdg_config + ";", "User")

if (-not $(Test-Path -Path $xdg_config)){
    New-Item -Path $xdg_config -Directory
}

[System.Environment]::SetEnvironmentVariable("PSVIRTUALENV_OFFLINE", "TRUE", "User") 


