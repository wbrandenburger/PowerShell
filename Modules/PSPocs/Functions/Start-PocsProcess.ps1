# ===========================================================================
#   Start-PocsProcess.ps1 ---------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Start-PocsProcess {

    <#
    .DESCRIPTION
        Starts a literature and document manager session with papis.

    .INPUTS
        System.String. ArgumentList

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(  
        [ValidateSet([ValidatePocsLibStrict])]     
        [Parameter(ValueFromPipeline, HelpMessage="Name of document and bibliography library, which should be started.")]
        [System.String] $Name,

        [Parameter(HelpMessage="Specifies parameters or parameter values to use when this cmdlet starts the process. If parameters or parameter values contain a space, they need surrounded with escaped double quotes.")]
        [System.String[]] $ArgumentList,

        [ValidateSet("Open", "Update")]     
        [Parameter(HelpMessage="Predefined parameter for control the action, when calling papis.")]
        [System.String] $Action = "Open"
    )

    Process {

        # check whether a document and bibliography session is running
        if ($Name) {
            Set-PocsLibrary -Name $Name
        }

        if (-not $(Get-ActivePocsLib)) {
            Write-FormattedSuccess -Message "No document and bibliography library is running." -Module $PSPocsLib.Name -Space
            return
        }
        elseif (-not $(Get-ActiveVirtualEnv)) {
            Write-FormattedSuccess -Message "No virtual environment is running." -Module $PSPocsLib.Name -Space
            return
        }

        $cmd = "& {papis -l $(Get-ActivePocsLib) open}"
        if (-not  $ArgumentList){
            if ($Action -eq "Update") {
                $cmd = "& {papis -l $(Get-ActivePocsLib) --update-lib}"
            }
        }

        Start-Process -FilePath pwsh -ArgumentList "-NoLogo", "-NoExit", "-NoProfile", "-Command", $cmd

        Restore-PocsLibrary -VirtualEnv
    }
}
