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

#   default -----------------------------------------------------------------
# ---------------------------------------------------------------------------
$PSPocs | Add-Member -MemberType NoteProperty -Name LibraryDefault -Value @(
        @{ key = "name"; value = "%(NAME)s"; condition = $True}
        @{ key = "virtual-env"; value = "%(VIRTUALENV)s"; condition = $True}
        @{ key = "description"; value = "description"; condition =$True}
        @{ key = "dir"; value = "path"; condition = $True}
        @{ key = "url"; value =  "url"; condition = $True}
        @{ key = "papis-dir"; value = $PSPocs.PapisConfigHome; condition = $True}
        @{ key = "local-config-file"; value = "%(papis-dir)s\libraries\%(NAME)s.ini"; condition = $True}
        @{ key = "cache-dir"; value = "%(papis-dir)s\cache\%(NAME)s"; condition = $True}
        @{ key = "use-shared-folders"; value = "%(IDBOOL)s"; condition = $True}
        @{ key = "shared-library-list"; value = "['%(ID)s']"; condition = $True}
        @{ key = "library-%(ID)s"; value = "path"; condition = "%(ID)s"}
        @{ key = "extension-%(ID)s"; value =  "['*.pdf']"; condition = "%(ID)s"}
)