# ===========================================================================
#   SciProfile_Scripts.psm1 -----------------------------------------------
# ===========================================================================

#   import ------------------------------------------------------------------
# ---------------------------------------------------------------------------
using namespace System.Management.Automation

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePapisProject: IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (Get-ValidateProjectType -Type "Papis")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePSModuleProject: IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (Get-ValidateProjectType -Type "PSModule")
    }
}