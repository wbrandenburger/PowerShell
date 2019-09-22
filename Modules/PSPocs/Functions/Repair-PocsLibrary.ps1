# ===========================================================================
#   Repair-PocsLibrary.ps1 --------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function  Repair-PocsLibrary {

    <#
    .DESCRIPTION
        Reverse changes to literature and document libraries in current powershell session.

    .PARAMETER Index
    
    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [Parameter(HelpMessage="Restore generated document and bibliography library with specified index.")]
        [Int] $Index = $PSPocs.Logger.Length - 1
    )

    Process{

        # update existing literature and document libraries
        Update-PocsLibrary

        # if index is greater than the history array break
        if ($Index -gt $PSPocs.Logger.Length - 1) {
            return
        }
        
        # backup for restoring literature and document libraries
        $structure = @()
        $PSPocs.Logger[$Index].Files | ForEach-Object {
            $structure += @{"Path" = $_["Source"]}
        }
        New-ConfigBackup -Structure $structure -Action "restore"

        # restore literature and document config files with specified index
        $PSPocs.Logger[$Index].Files | ForEach-Object {
            $source = $_["Backup"]
            $destination = $_["Source"]
            Copy-Item -Path $source -Destination $destination -Force
            Write-FormattedSuccess -Message "[CP] $($source) to $($destination)" -Module $PSPocs.Name
        }

        # update module structures
        Update-PocsLibrary
    }
}