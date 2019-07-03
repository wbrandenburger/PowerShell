# ==============================================================================
#   Profile.Refresh.ps1 --------------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
Function Restart-PSSession {

    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None")]
    
    Param
    (
    )

    Process {
        If ($PSCmdlet.ShouldProcess("Refresh environment and start a new powershell session?")) {
            Start-Process -FilePath RefreshEnv.cmd -Wait -NoNewWindow

            Start-Process -FilePath PowerShell.exe -Wait -NoNewWindow
        }
    }
}
