# ===========================================================================
#   PSPocs_Default.ps1 ------------------------------------------------------
# ===========================================================================

#   default -----------------------------------------------------------------
# ---------------------------------------------------------------------------

$default_library = @{ 
    "name-of-library" =  @{
        "type" = "type"
        "name" = "name"
        "description" = "description"
        "dir" = "path-to-library"
        "library-x" = "path-to-library-x"
        "use-shared-folders" = "true"
        "shared-library-list" = "['lfs']"
        "extension-x" = "['*.pdf']"
        "papis-dir" = $(Get-ConfigProjectDir -Name 'papis')
        "local-config-file" = "%(papis-dir)s\name-of-library\name-of-library.ini"
        "cache-dir" = "%(papis-dir)s\name-of-library"
        "url" = "url"
    }
}