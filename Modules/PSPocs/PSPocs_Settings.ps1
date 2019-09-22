# ===========================================================================
#   PSPocs_Settings.ps1 -----------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------

# get existing literature and document libraries from general config file
. $(ActivateVirtualEnvAutocompletion)

# validates an existing papis environment and repair it, if needed.
Repair-PocsPapis

# update content of literature and document file 
Update-PocsLibrary
