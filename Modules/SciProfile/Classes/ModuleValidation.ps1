# ===========================================================================
#   ModuleValidation.ps1 ----------------------------------------------------
# ===========================================================================

#   import ------------------------------------------------------------------
# ---------------------------------------------------------------------------
using namespace System.Management.Automation

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePapisProject: IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidateSciProfileProjectType -Type "Papis")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateRepositoryProject: IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidateSciProfileProjectType -Type "Repository")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePSModuleProject: IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidateSciProfileProjectType -Type "PSModule")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateProjectAlias: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((ValidateSciProfileProjectType) + "")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateSystemEnv: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((Get-ChildItem -Path "Env:" | Select-Object -ExpandProperty "Name") + "")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateSciProfileConfigFiles: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidateSciProfileConfigFiles)
    }
}