# ===========================================================================
#   Write-PocsLibStatus.ps1 -------------------------------------------------
# ===========================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Write-PocsLibStatus {

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param ()
    
    Process{

        $pocs_lib = [System.Environment]::GetEnvironmentVariable($PSPocs.ProjectEnv, "process")
        Write-PromptModuleStatus -Module "Pocs" -Value $pocs_lib
    }
}
