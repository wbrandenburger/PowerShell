# ===========================================================================
#   Profile.ps1 -------------------------------------------------------------
# ===========================================================================

#   import ------------------------------------------------------------------
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable | Where-Object {$_.Name -eq "SciProfile"}){
    # import main module
    Import-Module SciProfile

    # import user defined module
    Write-Host
    Import-PSMModule

    # import user defined functions
    Import-PSMFunction

    # activate autocompletion
    . (activate-sci)
}

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit # 'alt+F' or 'alt+space c'
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -BellStyle None

function Open-History {
    # Get-Content (Get-PSReadlineOption).HistorySavePath
    $file_path = (Get-PSReadlineOption).HistorySavePath
    code -n $file_path
}

function Start-DEMShell{
  Start-Process pwsh -ArgumentList '-noexit -command "
    cd A:\Repositories\EvalObjD;
    . .\init.ps1
  "'
}
function Start-DEMDevelopment {
  Start-DEMShell
  Start-DEMShell
  Start-Process code -ArgumentList 'A:\Repositories\EvalObjD'
}