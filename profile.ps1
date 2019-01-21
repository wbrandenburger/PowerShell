# =============================================================================
# =============================================================================
# Script      : profile.ps1
# Date        : 01/07/2018 
# Author      : Wolfgang Brandenburger
# Email       : w.brandenburger@unibw.de
# 
# Description : Combined Profile for the Windows PowerShell ISE and Console. Profiles are PowerShell scripts that run at startup, and once you have understood where they are and when each is used, they have a whole range of uses that make using PowerShell a lot more convenient.
# =============================================================================
# =============================================================================

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

# =============================================================================
#    PowerShell Cmdlets
# =============================================================================

#------------------------------------------------------------------------------
#    Get-PSSettings
#------------------------------------------------------------------------------
Function Get-PSSettings 
{
    Param 
    (
        [Parameter(Position=0, Mandatory=$True, HelpMessage="Path to where the file is/shall be stored")]
        [ValidateNotNullorEmpty()]
        [String] $Path
    )
    
    [XML] $XmlPSSettings = Get-Content -Path $Path;
    $XmlSettings =  $XmlPSSettings.SourceCode.PowerShell;

    Return $XmlSettings;
}

#------------------------------------------------------------------------------
#   Open-Profile
#------------------------------------------------------------------------------
Function global:Open-Profile 
{

    Param
    (
        [Parameter(Position=0, Mandatory=$False, HelpMessage="Path to where the file is/shall be stored")]
        [ValidateNotNullorEmpty()]
        [Switch] $Xml = $False
    )

    $File = $PSProfile;
    If ($Xml) {
        $File = $File + ' ' + $PSProfileXml;
    }
    
    Start-Process -FilePath Code -ArgumentList $File;
}

#------------------------------------------------------------------------------
#   Set-Home
#------------------------------------------------------------------------------
Function global:Set-Home
{
    Param
    (
    )

    Set-Location -Path $env:Home
}

# =============================================================================
#   Determine needed Settings 
# =============================================================================
		
    # Get the user specifications 
        $XmlSettings    = Get-PSSettings -Path $PSProfileXml;

# =============================================================================
#    Define Global Variables
# =============================================================================

    # Variables used in this Script
        $FlagVerbose    = $XmlSettings.Verbose

    # Global Variable
        # $PSUser = $XmlSettings.Path.PSUser;
        Set-Home

    # Set Modules Path
        $PSModulePath   = [Environment]::GetEnvironmentVariable("PSModulePath");
        $PSModulePath   += ";" + ($XmlSettings.Path.PSModules);
        [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath);
        
        Remove-Variable -Name PSModulePath
        
	# Set predefined alias of user 	
		# . .\Scripts\PSTools\Alias.ps1;
		# Set-AliasUser;
		
    # Global temp Variable
            
# =============================================================================
#    Import Modules, Themes and Settings
# =============================================================================

    # Get imported Module
        $ImportedModule = Get-Module;

    # Import modules which are frequently used in general
        ForEach ($Module in $XmlSettings.Module) {
            If ($ImportedModule | Where-Object { $_.Name -Eq $Module.Name}) {
             Remove-Module $Module.Name;
            }
           
            Import-Module $Module.Name -Verbose:($FlagVerbose -Eq 1) -ArgumentList $Module.ArgumentList;
        } 

        Remove-Variable ImportedModule;

# =============================================================================
#    Clear Variables
# =============================================================================
    Remove-Variable -Name XmlSettings;

    Remove-Variable -Name FlagVerbose;