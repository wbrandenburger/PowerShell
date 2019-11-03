# ===========================================================================
#   New-PocsLibrary.ps1 -----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function  New-PocsLibrary {

    <#
    .DESCRIPTION
        Add a literature and document library and store it in package's configuration file.

    .PARAMETER Name

    .PARAMETER VirtualEnv

    .PARAMETER Identifier

    .INPUTS
        Name.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(

        [Parameter(Position=1, Mandatory, ValueFromPipeline, HelpMessage="Name of document and bibliography library.")]
        [System.String] $Name,

        [ValidateSet("default", "docs", "paper", "work")]
        [Parameter(Position=2, HelpMessage="Type of document and bibliography library.")]
        [System.String] $Type="default",

        [ValidateSet([ValidateVirtualEnv])]
        [Parameter(Position=3, HelpMessage="Name of virtual environment with required packages for opening document and bibliography library.")]
        [System.String] $VirtualEnv = $PSPocs.VirtualEnv,

        [Parameter(HelpMessage="Extension identifier of document and bibliography library.")]
        [System.String] $Identifier = ""
    )
    
    Process {

        # update existing literature and document libraries
        Update-PocsLibrary

        if ($(ValidatePocsConfigSection) -contains $Name) {
            Write-FormattedError -Message "Document and bibliography library does exist. Abort Operation." -Module $PSPocs.Name -Space

            return
        }

        # create structure for subsitution of placeholders in default library
        $object = @{
            NAME = $Name
            VIRTUALENV = $VirtualEnv
            ID = $Identifier
            IDBOOL = if ($Identifier) {"true"} else {"false"}
        }

        # replace placeholders in default library with spcified parameters
        $library = @{$Name = [Ordered] @{}}
        $PSPocs.LibraryDefault | ForEach-Object {
            $key = Get-FormattedString -String $_["key"] -Object $object
            $value = Get-FormattedString -String $_["value"] -Object $object
            $condition = Get-FormattedString -String $_["condition"] -Object $object

            if ($condition) {
                $library[$Name] += @{ $key = $value }
            }
        }

        # create structure of library
        $library_structure = @( 
            [PSCustomObject] @{ 
                "Key" = @($Name) 
                "Path" = $PSPocs.PapisConfig
                "Library" = $library
                "Source"= $PSPocs.PapisConfigContent 
            }
        )

         # get type specific file
         if ($type) {
            $type_path = Get-ChildItem -Path $PSPocs.ConfigDir -Filter "*$($type)*" | Select-Object -ExpandProperty FullName
            $config_file = Join-Path -Path $PSPocs.PapisLibDir -ChildPath "$name.ini"
            if (Test-Path -Path $type_path) {
                $local_library = Get-IniContent -FilePath $type_path
                $library += $local_library
                
                # create structure of library
                $library_structure += [PSCustomObject] @{ 
                    "Key" = @($local_library.Keys)
                    "Path" = $config_file
                    "Library" = $local_library
                    "Source" = $local_library
                }
            }
        }

        # # get specified library and create structure fur further processing
        $temp_file = New-TemporaryConfig -Library $library -Open

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
        #$library_structure = Add-LibraryStructure -Library $( Get-IniContent -FilePath $temp_file -IgnoreComments) -Structure $library_structure
        $library_structure += Update-LibraryStructure -Library $(Get-IniContent -FilePath $temp_file -IgnoreComments) -Structure $library_structure     
        # add key to literature and document configuration settings and update module structures
        Update-PocsLibraryFromInput -Structure $library_structure -Action "add"
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-FormattedString {

    Param(
        [Parameter(HelpMessage="Search string.")]
        [System.String] $String,

        [Parameter(HelpMessage="Object with elements for substitution.")]
        [System.Object] $Object
    )

    # settings
    $pattern = "\%\(([a-z-_]+)\)s"
    $result = $String
    $keys = $Object.Keys

    # if there are matches each result will be further evaluated
    [Regex]::Matches($String, $Pattern, "IgnoreCase").Groups | Where-Object { $_.Name -eq 1} | Select-Object -ExpandProperty Value | ForEach-Object {
        # replace the pattern in given field as well as return formatted string
        if ($Keys -contains $_){
            $result = [Regex]::Replace($result, "\%\(($_)\)s", $Object[$_], "IgnoreCase")
        }
    }

    return $result
}
