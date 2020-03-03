# ===========================================================================
#   alias.ps1 ---------------------------------------------------------------
# ===========================================================================

@(
    @{ Name = "ls-exp";  Value = "Get-ExpmgmtProject"}
    @{ Name = "ls-rep";  Value = "Get-Repository"}
    @{ Name = "ed-exp";  Value = "Set-ExpmgmtProject"}

) | ForEach-Object {
    Set-Alias -Name $_.Name -Value $_.Value -Scope Global
}
