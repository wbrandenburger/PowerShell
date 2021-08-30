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

function Open-History {
    $file_path = (Get-PSReadlineOption).HistorySavePath
    code -n $file_path
}
