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

# Add-Type -Path "A:\OneDrive\Projects\PSModules\PSProfile\TestResult.cs" 

# =============================================================================
#    Define Global Variables
# =============================================================================

    # Set Modules Path
    $PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    $PSModulePath += ";$env:Home\PSModules"
    [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath)

# # Import ProfileManagement module
#     Import-Module PSProfile

# # Initialize object of class profile
#     $Global:UserProfile = New-Profile -Path $PSScriptRoot

# # Check available packages
#     $UserProfile.CheckPackages()

# Clear Variables
    Remove-Variable -Name PSModulePath


# =============================================================================
#    PowerShell Cmdlets
# =============================================================================

#------------------------------------------------------------------------------
#   Open-Profile
#------------------------------------------------------------------------------
Function Global:Show-HostColors
{
    $Colors = [Enum]::GetValues([System.ConsoleColor])
    Foreach ($BgColor in $Colors)
    {
        Foreach ($FgColor in $Colors) 
        { 
            Write-Host "$FgColor|"  -ForegroundColor $FgColor -BackgroundColor $BgColor -NoNewLine 
        }
        Write-Host " on $BgColor"
    }
}



#------------------------------------------------------------------------------
#   Test-Verb
#------------------------------------------------------------------------------
Function Global:Test-Verb
{
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]
    
    Param
    (
        [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True,HelpMessage="Verb which will be tested being a member of approved PowerShell verbs")]
        [Alias("Verb")]
        [String] $Input_Verb   
    )
    
    Process
    {
        Return Get-Verb | Where-Object {$_.Verb -eq $Input_Verb }
    }
    
}

#------------------------------------------------------------------------------
#   Test-Bool
#------------------------------------------------------------------------------
Function Global:Test-Bool
{
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Bool])]
    
    Param
    (
        [Parameter(Position=0, Mandatory=$True, HelpMessage="String which will be tested having a boolean value")]
        [Alias("Value")]
        [String] $Input_Value,

        [Parameter(Position=1, Mandatory=$False, HelpMessage="Switch - Checking whether the testted string has the value false.")]
        [Alias("TestFalse")]
        [Switch] $Switch_TestFalse = $True
    )

    Process
    {
        Return ($Switch_False -eq [Regex]::IsMatch($Input_Value,"^1$")) -or ($Switch_False -eq [Regex]::IsMatch($Input_Value,"true",1))
    }
}

Write-Host "AAARSCh"