# ==============================================================================
#   Profile.ps1 ----------------------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Update-PSConfig {

    [CmdletBinding()]

    [OutputType([Void])]

    Param()

    Process {

        $PSConfig =  Get-Content (Join-Path -Path $PSScriptRoot -ChildPath ".config\profile.config.json") | ConvertFrom-Json
    
        Set-ProjectConfiguration -File ($PSConfig |Select-Object -ExpandProperty "project-config-file")

        Set-PSModuleConfiguration -File ($PSConfig |Select-Object -ExpandProperty "powershell-module-config-file") -Profile ($PSConfig |Select-Object -ExpandProperty "powershell-module-import-file") -PSModulePath ($PSConfig | Select-Object -ExpandProperty "powershell-module-path")

        Set-RepositoryConfiguration -File ($PSConfig |Select-Object -ExpandProperty "repository-config-file") 
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
