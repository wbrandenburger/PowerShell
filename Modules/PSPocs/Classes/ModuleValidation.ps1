# ===========================================================================
#   ModuleValidation.ps1 ----------------------------------------------------
# ===========================================================================

#   import ------------------------------------------------------------------
# ---------------------------------------------------------------------------
using namespace System.Management.Automation

#   validation --------------------------------------------------------------
# ---------------------------------------------------------------------------
Class ValidatePocsLibStrict : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidatePocsLibrary)
    }
}

#   validation --------------------------------------------------------------
# ---------------------------------------------------------------------------
Class ValidatePocsLib : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((ValidatePocsLibrary) + "")
    }
}

#   validation --------------------------------------------------------------
# ---------------------------------------------------------------------------
Class ValidatePocsSectionStrict : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidatePocsConfigSection)
    }
}

#   validation --------------------------------------------------------------
# ---------------------------------------------------------------------------
Class ValidatePocsSection : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((ValidatePocsConfigSection) + "")
    }
}
#   validation --------------------------------------------------------------
# ---------------------------------------------------------------------------
Class ValidatePocsConfigFiles : IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (ValidatePocsConfigFiles)
    }
}


