# ===========================================================================
#   Edit-SciProfileConfig.ps1 ----------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Edit-SciProfileConfig {

   <#
    .SYNOPSIS
        Edit the content of module's configuration files.

    .DESCRIPTION
        Edit the content of module's configuration files in defined editor. All available configuration files can be accessed by autocompletion.

    .PARAMETER Name

    .EXAMPLE
        PS C:\> Edit-SciProfileConfig -Name config.ini

        -----------
        Description
        Open the content of module's configuration files 'config.ini' in defined editor. for editing. All available configuration files can be accessed by autocompletion.

    .INPUTS
        None.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(
        [ValidateSet([ValidateSciProfileConfigFiles])]
        [Parameter(Position=1, HelpMessage="File name of a configuration file.")]
        [System.String] $Name = "config.ini"
    )

    Process {

        foreach($config_file in $SciProfile.ConfigFileList){
            if ($config_file -match $Name){
                $file = $config_file
            }
        }

        $editor_args = $($SciProfile.EditorArgs + " " + $file)
        
        # open existing requirement file
        if (Test-Path -Path $file){
            Start-Process -Path $SciProfile.Editor -NoNewWindow -Args $editor_args
        }
    }
}
