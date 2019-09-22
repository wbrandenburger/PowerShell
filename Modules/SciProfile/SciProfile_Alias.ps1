# ===========================================================================
#   SciProfile_Alias.ps1 ---------------------------------------------------
# ===========================================================================

#   aliases -----------------------------------------------------------------
# ---------------------------------------------------------------------------

# define aliases for specific function
@(
    @{ Name = "activate-sci";   Value = "ActivateSciProfileAutocompletion"}
    @{ Name = "cdx";            Value = "Set-ProjectLocation"}
    @{ Name = "exx";            Value = "Open-ProjectFileExplorer"}
    @{ Name = "dirx";           Value = "Get-ProjectLocation"}
    @{ Name = "fox";            Value = "Open-ProjectBrowser"}    
    @{ Name = "ls-env";         Value = "Get-EnvVariable"}
    @{ Name = "lsx";            Value = "Get-ProjectChildItem"} 
    @{ Name = "sx";             Value = "Set-ProfileProjectList"}
    @{ Name = "s-env";          Value = "Set-EnvVariable"}
    @{ Name = "t-env";          Value = "Test-EnvPath"}
    @{ Name = "vsx";            Value = "Open-ProjectWorkspace"}
    @{ Name = "webx";           Value = "Get-WebLocation"}

) | ForEach-Object {
    New-Alias -Name $_.Name -Value $_.Value
}
    