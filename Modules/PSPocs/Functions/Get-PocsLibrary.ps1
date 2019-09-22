# ===========================================================================
#   Get-PocsLibrary.ps1 -----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-PocsLibrary {

    <#
    .DESCRIPTION
        Get existing literature and document libraries.

    .PARAMETER Name

    .INPUTS
        System.String. Name
    
    .OUTPUTS
        System.object[]. literature and document libraries
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([System.Object])]

    Param(
        [ValidateSet([ValidatePocsSection])]     
        [Parameter(Position=1, ValueFromPipeline, HelpMessage="Name of document and bibliography library.")]
        [System.String] $Name,

        [Parameter(ValueFromPipeline, HelpMessage="Existing property of document and bibliography library.")]
        [System.String] $Property,

        [Parameter(HelpMessage="Return information not as readable table with additional details.")]
        [Switch] $Unformatted
    )

    Process{

        # update existing literature and document libraries
        Update-PocsLibrary

        if ($Name){
            # get specific document and bibliography library
            return $PSPocs.Library | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty "Content" | Format-Table
        }
        else {
            # get all existing document and bibliography libraries
            if ($Unformatted) {
                return $PSPocs.Library
            } else {
                return $PSPocs.Library | Format-Table -Property Name, Library, @{
                    Label = "Path"
                    Expression = {if ($_.Library){$_.Content["dir"]} else {$Null}}
                }, @{
                    Label = "Content"
                    Expression = {
                        if ($Property) {
                            if ($_.Library){
                                $_.Content[$Property]
                            } else {
                                $Null
                            }
                        } else {
                            $_.Content
                        }
                    }
                }
            }
        }
    }
}