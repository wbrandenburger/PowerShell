# ===========================================================================
#   Get-SciProfileConfig.ps1 -----------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-SciProfileConfig {

    <#
    .SYNOPSIS
        Get the content of module's configuration files.

    .DESCRIPTION
        Displays the content of module's configuration files in powershell. All available configuration files can be accessed by autocompletion.
    
    .PARAMETER Name

    .PARAMETER Unformatted

    .EXAMPLE
        PS C:\> Get-SciProfileConfig -Name config.ini

        Name                           Value
        ----                           -----
        work-dir                       A:\.config\SciProfile
        project-file                   A:\.config\SciProfile\config\project.json
        project-alias                  papis workspace psmodule
        import-file                    A:\.config\SciProfile\config\import.json
        default-editor                 code
        editor-arguments               --new-window --disable-gpu
        config-lib                     pocs-config
        virtual-env                    papis-dev
        module-dir                     A:\Documents\PowerShell\Modules

        -----------
        Description
        Displays the content of module's configuration files in powershell. All available configuration files can be accessed by autocompletion.

    .INPUTS
        None.

    .OUTPUTS
        System.Object. Content of module's configuration files.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object])]

    Param(
        [ValidateSet([ValidateSciProfileConfigFiles])]
        [Parameter(Position=1, HelpMessage="File name of a configuration file.")]
        [System.String] $Name = "config.ini",

        [Parameter(HelpMessage="Return information not as readable table with additional details.")]
        [Switch] $Unformatted
    )

    Process {

        foreach($config_file in $SciProfile.ConfigFileList){
            if ($config_file -match $Name){
                $file = $config_file
            }
        }

        switch ([System.IO.Path]::GetExtension($file)){
            ".ini" {
                $config_content = Get-IniContent -FilePath $file -IgnoreComments
                $config_content = Format-IniContent -Content $config_content -Substitution $SciProfile 
                
                $result = @()
                $config_content.Keys | ForEach-Object {
                    $result += $config_content[$_]
                }
                break
            }
            ".json" {
                $result = Get-Content -Path $file | ConvertFrom-Json
                break
            }
            default { 
                $result = Get-Content -Path $file
                $Unformatted = $True
                break
            }
        }

        if ($Unformatted) {
            return $result
        }
        return $result | Format-Table
    }
}
