# ===========================================================================
#   SciProfile_Settings.ps1 -------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
@( 
    @{Field="Format"; Value=@("Name", "Alias", "Type", "Description", "Folder", "Url")}
    @{Field="ConfigFileList"; Value=@($Module.Config, $SciProfile.ImportFile, $SciProfile.ProjectFile)}
) | ForEach-Object {
    $SciProfile  | Add-Member -MemberType NoteProperty -Name $_.Field -Value  $_.Value
}


