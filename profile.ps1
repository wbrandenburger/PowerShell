# ==============================================================================
#   Profile.ps1 ----------------------------------------------------------------
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

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # load all sets of public and private functions into the module scope
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Functions") -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }

    # set variables which are necessary for repository tools
    Update-PSConfig

#   import ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
    $Void = Import-PSModule -Profile User
    if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
        $Void = Import-PSModule -Profile Admin
    }
    Clear-Variable -Name Void
    Get-Module
