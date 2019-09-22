# ===========================================================================
#   BuildManagement.ps1 -----------------------------------------------------
# ===========================================================================

# ValidateRepositoryProject

# from https://sqldbawithabeard.com/2017/09/09/automatically-updating-the-version-number-in-a-powershell-module-how-i-do-regex/
# $manifest = Import-PowerShellDataFile .\BeardAnalysis.psd1 
# [version]$version = $Manifest.ModuleVersion
# # Add one to the build of the version number
# [version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
# # Update the manifest file
# Update-ModuleManifest -Path .\BeardAnalysis.psd1 -ModuleVersion $NewVersion

# from https://powershellexplained.com/2017-10-14-Powershell-module-semantic-version/
# $ManifestPath = '.\MyModule.psd1'
# Step-ModuleVersion -Path $ManifestPath -By Patch