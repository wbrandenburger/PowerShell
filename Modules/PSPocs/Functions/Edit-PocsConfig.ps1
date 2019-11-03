# ===========================================================================
#   Edit-PocsConfig.ps1 -----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Edit-PocsConfig {

   <#
    .SYNOPSIS
        Edit the content of module's configuration file.

    .DESCRIPTION
        Edit the content of module's configuration file in defined editor.

    .EXAMPLE
        PS C:\> Edit-PocsConfig 

        -----------
        Description
        Open the content of module's configuration file in defined editor. for editing.

    .INPUTS
        None.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(
        [ValidateSet([ValidatePocsConfigFiles])]
        [Parameter(Position=1, HelpMessage="File name of a configuration file.")]
        [System.String] $Name = "config.ini"
    )

    Process {

        # get existing requirement file 
        $file = Join-Path -Path $PSPocs.WorkDir -ChildPath $Name

        $editor_args = $($PSPocs.EditorArgs + " " +  $file)
        
        # open existing requirement file
        if (Test-Path -Path $Module.Config){
            Start-Process -Path $PSPocs.Editor -NoNewWindow -Args $editor_args
        }
    }
}
