# ===========================================================================
#   expmgmt.ps1 -------------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Get-ExpmgmtProject{
    return Get-EnvVariable -Name "EXPMGMT_PROJECT"
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Set-ExpmgmtProject{
    Param(
        [System.String ]$Value
    )
    Set-EnvVariable -Name "EXPMGMT_PROJECT" -Value $Value
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Remove-ExpmgmtTemp{
    
    Get-ChildItem -Path ([System.Environment]::GetEnvironmentVariable("TEMP")) | Where-Object {($_.name -match "expmgmt") -or ($_.name -match "shdw")} | Remove-Item -Force

}