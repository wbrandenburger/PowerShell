# ===========================================================================
#   PSPocs_Alias.ps1 --------------------------------------------------------
# ===========================================================================

#   aliases -----------------------------------------------------------------
# ---------------------------------------------------------------------------

@(
    @{ Name = "activate-pocs"; Value = "ActivatePocsAutocompletion"}
    @{ Name = "ed-pocs"; Value = "Edit-PocsLibrary"}
    @{ Name = "log-pocs"; Value = "Get-PocsLibraryLog"}
    @{ Name = "ls-pocs"; Value = "Get-PocsLibrary"}
    @{ Name = "n-pocs"; Value = "New-PocsLibrary"}
    @{ Name = "rm-pocs"; Value = "Remove-PocsLibrary"}
    @{ Name = "rp-pocs"; Value = "Repair-PocsLibrary"}
    @{ Name = "rp-papis"; Value = "Repair-PocsPapis"}
    @{ Name = "sa-lib"; Value = "Start-PocsProcess"}
    @{ Name = "sa-pocs"; Value = "Start-PocsLibrary"}
    @{ Name = "sp-pocs"; Value = "Stop-PocsLibrary"}
    @{ Name = "sp-pocs-venv"; Value = "Stop-PocsLibraryVirtualEnv"}
    @{ Name = "ud-pocs"; Value = "Update-PocsLibrary"}

) | ForEach-Object {
    Set-Alias -Name $_.Name -Value $_.Value
}