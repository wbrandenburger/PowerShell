# ==============================================================================
#   Profile.ps1 ----------------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # load all sets of public and private functions into the module scope
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Functions") -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }

    # set variables which are necessary for repository tools
    Update-PSConfig -File (Join-Path -Path $PSScriptRoot -ChildPath ".config\profile.config.json" ) | ForEach-Object {
        . $_
    }

#   aliases --------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # define aliases for specific function
    $Script:PSAlias = Get-Content (Join-Path -Path $PSScriptRoot -ChildPath ".config\profile.alias.json") | ConvertFrom-Json
    
    $Script:PSAlias | ForEach-Object {
        Set-Alias -Name $_.Name -Value $_.Value
    }

#   import ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
    $Void = Import-PSModule -Profile User
    if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
        $Void = Import-PSModule -Profile Admin
    }
    Clear-Variable -Name Void
    Get-Module

#   import ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
