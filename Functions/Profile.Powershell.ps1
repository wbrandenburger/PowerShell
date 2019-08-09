# ==============================================================================
#   Profile.PowerShell.ps1 -----------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Update-PSConfig {

    [CmdletBinding()]

    [OutputType([System.String[]])]

    Param (

        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File

    )

    Process {

        $PSConfig =  Get-Content $File | ConvertFrom-Json

        # module configuration
        $moduleConfigFile = $PSConfig | Select-Object -ExpandProperty "powershell-module-config-file"
        $PSProfile = $PSConfig | Select-Object -ExpandProperty "powershell-module-import-file"
        $PSModulePath = $PSConfig | Select-Object -ExpandProperty "powershell-module-path"

        Set-PSModuleConfiguration -File $moduleConfigFile -Profile $PSProfile -PSModulePath $PSModulePath 

        # repository configuration
        $repositoryConfigFile = $PSConfig | Select-Object -ExpandProperty "repository-config-file"

        Set-RepositoryConfiguration -File $repositoryConfigFile
        
        # papis-configuration
        $papisConfigFile = $PSConfig | Select-Object - -ExpandProperty "papis-config-file"

        Set-PapisConfiguration -File $papisConfigFile

        # workspace configuration
        $workspaceConfigFile = $PSConfig | Select-Object -ExpandProperty "workspace-config-file"

        # project configuration
        $projectConfigFile = $PSConfig | Select-Object -ExpandProperty "project-config-file"

        $projectFiles = @(
            [PSCustomObject] @{Path=$moduleConfigFile; Tag="PSModule"}
            [PSCustomObject] @{Path=$repositoryConfigFile; Tag="Repository"}
            [PSCustomObject] @{Path=$workspaceConfigFile; Tag="Workspace"}
            [PSCustomObject] @{Path=$papisConfigFile; Tag="Papis"}
        )

        Set-ProjectConfiguration -File $projectConfigFile -Files $projectFiles

        # additional powershell functions
        $powershellFunctions = $PSConfig | Select-Object -ExpandProperty "powershell-functions"

        return $powershellFunctions

    }
}

#   functions ------------------------------------------------------------------
# ------------------------------------------------------------------------------
    function Get-PSAlias{

        [CmdletBinding(PositionalBinding=$True)]

        [OutputType([PSCustomObject])]

        Param(
            [Parameter(Position=1)]
            [ValidateSet("Project", "Repository", "Common", "PSModule", "Papis")]
            [System.String[]] $Tag = @("Project", "Repository", "Common", "Module", "Papis")
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
            
            return $PSAliasTag | Sort-Object -Property Name |Format-Table
        }
    }