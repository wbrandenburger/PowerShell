# ===========================================================================
#   Edit-PocsLibrary.ps1 ----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Edit-PocsLibrary {

    <#
    .DESCRIPTION
        Edit existing literature and document libraries.

    .PARAMETER Name

    .INPUTS
        System.String. Name        

    .OUTPUTS
       None.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [ValidateSet([ValidatePocsSection])]     
        [Parameter(Position=1, ValueFromPipeline, HelpMessage="Name of document and bibliography library.")]
        [System.String] $Name
    )

    Process{

        # update existing literature and document libraries
        Update-PocsLibrary

        # get specified library and create structure fur further processing
        $library_structure = Get-LibraryStructure -Name $Name
        $library = @{}
        $library_structure  | ForEach-Object {
            $library += $_.Library
        }

        # create temporary config file, write specified information to this file, and open it for editing
        $temp_file = New-TemporaryConfig -Library $library -Open

        # user input for updating or cancelling editing document and bibliography libraries
        $message  = "Edit document and bibliography libraries"
        $question = "Do you want to update your changes, or create a new object from library?"
        $choices = "&Update", "&Wait/Update", "&Quit"
        
        $decision = 1
        while ($decision -eq 1) {
            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)

            # quit if chosen
            if ($decision -eq 2) {
                return
            }

            # get modified document and bibliography libraries
            $library_structure = Update-LibraryStructure -Library $(Get-IniContent -FilePath $temp_file -IgnoreComments) -Structure $library_structure

            # update keys in literature and document configuration settings and update module structures
            $action = $Name
            if (-not $Name){
                $action = "All"
            }
            Update-PocsLibraryFromInput -Structure $library_structure -Action "update:$($action)"
        }
    }
}