# ==============================================================================
#   Profile.PowerShell.ps1 -----------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Update-PSConfig {

    [CmdletBinding()]

    [OutputType([Void])]

    Param ()

    Process {

        $PSConfig =  Get-Content (Join-Path -Path $PSScriptRoot -ChildPath ".config\profile.config.json") | ConvertFrom-Json

        # module configuration
        $moduleConfigFile = $PSConfig | Select-Object -ExpandProperty "powershell-module-config-file"
        $PSProfile = $PSConfig | Select-Object -ExpandProperty "powershell-module-import-file"
        $PSModulePath = $PSConfig | Select-Object -ExpandProperty "powershell-module-path"

        Set-PSModuleConfiguration -File $moduleConfigFile -Profile $PSProfile -PSModulePath $PSModulePath 

        # repository configuration
        $repositoryConfigFile = $PSConfig | Select-Object -ExpandProperty "repository-config-file"

        Set-RepositoryConfiguration -File $repositoryConfigFile
        
        # workspace configuration
        $workspaceConfigFile = $PSConfig | Select-Object -ExpandProperty "workspace-config-file"

        # project configuration
        $projectConfigFile = $PSConfig | Select-Object -ExpandProperty "project-config-file"
        $projectFiles = @(
            [PSCustomObject] @{Path=$moduleConfigFile; Tag="Module"}
            [PSCustomObject] @{Path=$repositoryConfigFile; Tag="Repository"}
            [PSCustomObject] @{Path=$workspaceConfigFile; Tag="Workspace"}
        )

        Set-ProjectConfiguration -File $projectConfigFile -Files $projectFiles
    }
}

#   functions ------------------------------------------------------------------
# ------------------------------------------------------------------------------
    function Get-PSAlias{

        [CmdletBinding(PositionalBinding=$True)]

        [OutputType([PSCustomObject])]

        Param(
            [Parameter(Position=1)]
            [ValidateSet("Project", "Repository", "Common", "Module")]
            [System.String[]] $Tag = @("Project", "Repository", "Common", "Module")
        )

        Process {

            $PSAliasTag = @()
            $Tag | ForEach-Object {
                $tagName = $_
                $Script:PSAlias | ForEach-Object { 
                    if ($_.Tag -eq $tagName) {
                        $PSAliasTag += $_
                    }
                }
            }
            
            return $PSAliasTag | Format-Table
        }
    }