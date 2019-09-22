# ===========================================================================
#   Get-PocsConfig.ps1 ------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-PocsConfig {

    <#
    .SYNOPSIS
        Get the content of module's configuration file.

    .DESCRIPTION
        Displays the content of module's configuration file in powershell.
    
    .PARAMETER Unformatted

    .EXAMPLE
        PS C:\> Get-PocsConfig 

        Name                           Value
        ----                           -----
        default-editor                 code
        editor-arguments               --new-window --disable-gpu
        virtual-env                    papis-env
        papis-packages                 papis

        -----------
        Description
        Displays the content of module's configuration file in powershell.

    .INPUTS
        None.

    .OUTPUTS
        System.Object. Content of module's configuration file.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object])]

    Param(
        [Parameter(HelpMessage="Return information not as readable table with additional details.")]
        [Switch] $Unformatted
    )

    Process {

        $config_content = Get-IniContent -FilePath $Module.Config -IgnoreComments
        $config_content = Format-IniContent -Content $config_content -Substitution $PSPocs 
        
        $result = @()
        $config_content.Keys | ForEach-Object {
            $result += $config_content[$_] 
        }

        if ($Unformatted) {
            return $result
        }
        return $result | Format-Table
    }

}
