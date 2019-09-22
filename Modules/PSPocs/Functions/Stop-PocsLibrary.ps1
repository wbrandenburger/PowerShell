# ===========================================================================
#   Stop-PocsLibrary.ps1 ----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Stop-PocsLibrary {

    <#
    .SYNOPSIS
        Stops current running literature and document manager session.

    .DESCRIPTION
        Stops current running literature and document manager session.

    .PARAMETER VirtualEnv

    .PARAMETER Silent
    
    .EXAMPLE
        [venv] PS C:\> Stop-PocsLibrary

        [PSPocs]::SUCCESS: Document and bibliography session with library 'pocs' was stopped.

        -----------
        Description
        Stops current literature and document manager session. 

    .EXAMPLE
        [venv] PS C:\> sp-pocs

        [PSPocs]::SUCCESS: Document and bibliography session with library 'pocs' was stopped.

        -----------
        Description
        Stops current literature and document manager session with predefined alias of command.

    .INPUTS
        None.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(
        [Parameter(HelpMessage="Possible running virtual environment will be stopped.")]
        [Switch] $VirtualEnv,

        [Parameter(HelpMessage="If switch 'silent' is true no output will written to host.")]
        [Switch] $Silent
    )

    Process { 

        # get a running document and bibliography session
        $pocs_lib_old = Get-ActivePocsLib
        if (-not $pocs_lib_old){
            if (-not $Silent) {
                Write-FormattedWarning -Message "There was no document and bibiography session found." -Module $PSPocs.Name -Space
            }
            return
        }

        # deactivation of a running document and bibliography session
        Restore-PocsLibrary -VirtualEnv:$VirtualEnv

        # if the environment variable is not empty, deactivation failed
        if (-not $Silent) {
            if ($pocs_lib_old -and $pocs_lib_old -eq $(Get-ActivePocsLib)) {
                Write-FormattedError -Message "Document and bibliography session with library '$pocs_lib_old' could not be stopped." -Module $PSPocs.Name -Space
            }         
            else{
                Write-FormattedSuccess -Message "Document and bibliography session with library '$pocs_lib_old' was stopped." -Module $PSPocs.Name -Space
            }
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Stop-PocsLibraryVirtualEnv {

    <#
    .SYNOPSIS
        Stops current running literature and document manager session, as well as running virtual environment.

    .DESCRIPTION
        Stops current running literature and document manager session, as well as running virtual environment.

    .PARAMETER Silent

    .EXAMPLE
        [venv] PS C:\> Stop-PocsLibraryVirtualEnv

        [PSPocs]::SUCCESS: Document and bibliography session with library 'pocs' was stopped.

        -----------
        Description
        Stops current literature and document manager session as well as running virtual environment.

    .INPUTS
        None.

    .OUTPUTS
        None.
    #>
    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(
        [Parameter(HelpMessage="If switch 'silent' is true no output will written to host.")]
        [Switch] $Silent
    )

    Process { 
        Stop-PocsLibrary -VirtualEnv -Silent:$Silent
    }
}