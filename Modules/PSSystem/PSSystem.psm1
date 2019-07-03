# ==============================================================================
#   PSSystem.psm1 --------------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
    
    # get module name and directory
    $Script:moduleName = "PSSystem"
    $Script:moduleDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

    # execute file with the specific module settings
    . (Join-Path -Path $Script:moduleDir -ChildPath ($Script:moduleName + ".Module.ps1")) -Test:$Script:testModule

    # load essential functions
    . $ModuleVar.FunctionsFile

#   functions ------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # load all sets of public and private functions into the module scope
    Get-ChildItem -Path $ModuleVar.FunctionsDir -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }

#   aliases --------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # define aliases for specific function
    @(

        @{ Name = "lsenv";      Value =  "Get-EnvironmentVariable"}

    ) | ForEach-Object {
        Set-Alias -Name $_.Name -Value $_.Value
    }

return 1
