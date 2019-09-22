# ===========================================================================
#   New-PocsLibrary.ps1 -----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function  New-PocsLibrary {

    <#
    .DESCRIPTION
        Add a literature and document library and store it in package's configuration file.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param()
    
    Process {

        # update existing literature and document libraries
        Update-PocsLibrary

        # get specified library and create structure fur further processing
        $temp_file = New-TemporaryConfig -Library $PSPocs.LibraryDefault -Open
        $library_structure = Get-LibraryStructure

        # user input for updating or cancelling editing document and bibliography libraries
        $message  = "Add file to document and bibliography database"
        $question = "Do you want to add the library to document and bibliography database?"
        $choices = "&Add", "&Quit"
        $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)

        # quit if chosen
        if ($decision -eq 1) {
            return
        }

        # get modified document and bibliography libraries
        $library_structure = Add-LibraryStructure -Library $( Get-IniContent -FilePath $temp_file -IgnoreComments) -Structure $library_structure

        # add key to literature and document configuration settings and update module structures
        Update-PocsLibraryFromInput -Structure $library_structure -Action "add"
    }
}