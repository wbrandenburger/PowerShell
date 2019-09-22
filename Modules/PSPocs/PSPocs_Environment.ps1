# ===========================================================================
#   PSPocs_Environment.ps1 --------------------------------------------------
# ===========================================================================

#   environment -------------------------------------------------------------
# ---------------------------------------------------------------------------
@(
    @{  # document and bibliography management environment variable
        Name="ProjectEnv"
        Value="$($PSPocs.Name.ToUpper())_PROJECT"
    }
    @{  # backup of document and bibliography management environment variable
        Name="ProjectEnvOld"
        Value="$($PSPocs.Name.ToUpper())_PROJECT_OLD"
    }
) | ForEach-Object {
    $PSPocs | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
}
