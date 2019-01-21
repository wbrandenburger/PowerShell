<#
 ===============================================================================
 ===============================================================================
 Script    : Microsoft.PowerShell_profile.ps1
 Date      : 01/07/2018 
 Author    : Wolfgang Brandenburger
 Email     : w.brandenburger@unibw.de
 
 Description : Profile for the Windows PowerShell ISE. Profiles are PowerShell 
               scripts that run at startup, and once 0you have understood where 
               they are and when each is used, they have a whole range of uses 
               that make using PowerShell a lot more convenient.
 ===============================================================================
 ===============================================================================
#>

#------------------------------------------------------------------------------
#   Start-Profile
#------------------------------------------------------------------------------
Function Start-Profile 
{

    Param
    (
    )

    Invoke-Expression -Command $PSProfile
}

# Start combined profile powershell script

    # Location of local powershell settings
        $PSProfile = Join-Path -Path $PSScriptRoot -ChildPath "profile.ps1"
        $PSProfileXml = Join-Path -Path $PSScriptRoot -ChildPath "profile.xml"

    # Start combined profile powershell script
        Start-Profile