# ===========================================================================
#   preparation.ps1 ---------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
[System.Environment]::SetEnvironmentVariable("PSVIRTUALENV_OFFLINE", "TRUE", "User") 

$pwsh_path = Join-Path -Path  $Env:USERPROFILE -ChildPath "Documents\PowerShell"

if ($(Test-Path -Path $pwsh_path)){
    Remove-Item -Path $pwsh_path  -Force -Recurse
}

@(
    @{Name="PowerShell"; Url="https://github.com/wbrandenburger/PowerShell"}
) | ForEach-Object {
    
    Start-Process -FilePath "git" -Args "clone", $_["Url"], $pwsh_path -NoNewWindow -Wait
}

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
# $xdg_repo = Join-Path -Path  $Env:USERPROFILE -ChildPath "Repository"

# if (-not $(Test-Path -Path $xdg_repo)){
#     New-Item -Path $xdg_repo -ItemType "Directory"
# }

# @(
#     @{Name="SciProfile"; Url="https://github.com/wbrandenburger/SciProfile"}
#     @{Name="PSPocs"; Url="https://github.com/wbrandenburger/PSPocs"}
#     @{Name="PSVirtualEnv"; Url="https://github.com/wbrandenburger/PSVirtualEnv"}
#     @{Name="PyVirtualEnv"; Url="https://github.com/wbrandenburger/PyVirtualEnv"}
# ) | ForEach-Object {
    
#     Start-Process -FilePath "git" -Args "clone", $_["Url"], $(Join-Path -Path $xdg_repo -ChildPath $_["Name"]) -NoNewWindow -Wait
# }

