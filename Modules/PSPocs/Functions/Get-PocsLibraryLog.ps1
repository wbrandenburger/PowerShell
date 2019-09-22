# ===========================================================================
#   Get-PocsLibraryLog.ps1 --------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function  Get-PocsLibraryLog {

    <#
    .DESCRIPTION
        Get literature and document config logger.
    
    .OUTPUTS
        System.Object. Literature and document config logger.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([System.Object])]

    Param()

    Process{

        if (-not $PSPocs.Logger) {
            Write-FormattedWarning -Message "Nothing to return, no action has already been performed in this session." -Module $PSPocs.Name
            return
        }

        return $PSPocs.Logger | Format-Table -Property Id, Date, Action, Files
    }
}