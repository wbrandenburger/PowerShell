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

# =============================================================================
#    PowerShell Cmdlets
# =============================================================================

#------------------------------------------------------------------------------
#   Start-Profile
#------------------------------------------------------------------------------
Function Global:Start-Profile
{

    Param
    (
    )

    $UserProfile.StartProfile()
}

#------------------------------------------------------------------------------
#   Open-Profile
#------------------------------------------------------------------------------
Function Global:Open-Profile
{

    Param
    (
    )

    $UserProfile.OpenProfile()
}

# [Inherit HashTable](https://www.hernanjlarrea.com/index.php/extending-hashtables-functionalities-in-powershell-by-using-classes/)
# [PowerShell Classes I](https://overpoweredshell.com/Introduction-to-PowerShell-Classes/)
# [PowerShell Classes II](https://www.sapien.com/blog/2016/03/16/inheritance-in-powershell-classes/)
######GENERAL CLASS!!!!
# =============================================================================
#    Class HashTableList : System.Collections.HashTable
# =============================================================================
Class HashTableList : System.Collections.HashTable
{

    [Void] ExtAdd ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values)
    {
        $This.ExtAdd( $Input_Keys, $Input_Values, $True)
    }

    [Void] ExtAdd ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values, [Bool] $Strict)
    {
        ForEach ($Input_Keys_Item in $Input_Keys)    
        {
            If( -not ($This.Keys -contains $Input_Keys_Item) ) {
                $This.Add($Input_Keys_Item,[System.Collections.ArrayList]::New())
            }

            ForEach ($Input_Values_Item in $Input_Values) 
            {
                If ( ($This[$Input_Keys_Item] -contains $Input_Values_Item) -and $Strict) 
                {
                    Continue
                }
                $This[$Input_Keys_Item].Add($Input_Values_Item)
            }
        }
    }

    [Void] ExtRemove ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values)
    {
        ForEach ($Input_Keys_Item in $Input_Keys)    
        {
            If ($This.Keys -contains $Input_Keys_Item) 
            {
                ForEach ($Input_Values_Item in $Input_Values) 
                {
                    Do 
                    {
                        $This[$Input_Keys_Item].Remove($Input_Values_Item)
                    }
                    While ($This[$Input_Keys_Item] -contains $Input_Values_Item)
                }
                If ($This[$Input_Keys_Item].Count -eq 0) 
                {
                    $This.Remove($Input_Keys_Item)
                }
            }
        }
    }

    [System.Object] ConvertToObject()
    {
        Return ($This.Keys | ForEach-Object { [PSCustomObject] @{
                    GroupProfile = $_
                    Package = $This[$_]
                }})
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

# =============================================================================
#    Class Profile
# =============================================================================
Class Profile 
{   
    # Location of local powershell settings
    # !!!!!!!!!!!!!!!!!!!! Task: Programmaing Path and FilePath as PSObject
    [System.String] $PathLocal
    [System.String] $FilePathProfile
    [System.String] $PathConfig
    [System.String] $FilePathProfileConfig
    
    [System.Object] $Profiles
    [System.Object] $Packages

    #---------------------------------------------------------------------------
    #   Constructor
    #---------------------------------------------------------------------------
    Profile()
    {
        # Location of local powershell settings
        $This.PathLocal = $PSScriptRoot
        $This.FilePathProfile = Join-Path -Path $PSScriptRoot -ChildPath "profile.ps1"
        $This.PathConfig = Join-Path -Path $PSScriptRoot -ChildPath ".config"
        $This.FilePathProfileConfig = Join-Path -Path $PSScriptRoot -ChildPath ".config\profile.xml"

        $This.ConvertConfigToObject()
        $This.GetManagedPackages()
    }

    #---------------------------------------------------------------------------
    #   Open Profile
    #---------------------------------------------------------------------------
    [Void] OpenProfile()
    {
        Start-Process -FilePath $This.FilePathProfile
    }

    #---------------------------------------------------------------------------
    #   Start Profile
    #---------------------------------------------------------------------------
    [Void] StartProfile()
    {
        . $This.FilePathProfile
    }

    #---------------------------------------------------------------------------
    #   Set-DirHome
    #---------------------------------------------------------------------------
    [Void] SetPathHome()
    {
        Set-Location -Path $env:Home
    }

    #---------------------------------------------------------------------------
    #   Set-DirLocal
    #---------------------------------------------------------------------------
    [Void] SetPathLocal()
    {
        Set-Location -Path $This.PSLocal
    }

    #---------------------------------------------------------------------------
    #   Update
    #---------------------------------------------------------------------------
    [Void] Update()
    {
        $This.ConvertConfigToObject()
        $This.GetManagedPackages()
    }

    #---------------------------------------------------------------------------
    #   GetProfile
    #---------------------------------------------------------------------------
    [System.Object] GetProfile() 
    {
        # Convert hashtablelist to system.object
        Return $This.Profiles.ConvertToObject()
    }

    #---------------------------------------------------------------------------
    #   GetProfile
    #---------------------------------------------------------------------------
    [System.Collections.ArrayList] GetProfile(
        [System.String] $UserProfile) 
    {
        # Return a profile list
        Return $This.Profiles[$UserProfile]
    }

    #---------------------------------------------------------------------------
    #   GetProfile
    #---------------------------------------------------------------------------
    [System.Collections.ArrayList] GetProfileKeys() 
    {
        # Return a profile list
        Return $This.Profiles.Keys
    }

    #---------------------------------------------------------------------------
    #   ShowProfile
    #---------------------------------------------------------------------------
    [System.Object] ShowProfile() 
    {
        # Show the lists of profiles
        Return $This.Profiles.ConvertToObject() | Format-List
    }

    #---------------------------------------------------------------------------
    #   GetPackages
    #---------------------------------------------------------------------------
    [System.Object] GetPackages() 
    {
        # Return a profile list
        Return $This.Packages
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages() 
    {
        # Show the lists of profiles
        Return $This.Packages | Format-Table
    }

    #---------------------------------------------------------------------------
    #   ReadProfileConfig
    #---------------------------------------------------------------------------
    [System.Xml.XmlDocument] ReadProfileConfig() 
    {
        # Read the profile config file
        Return ([System.Xml.XmlDocument] (Get-Content -Path $This.FilePathProfileConfig))
    }

    #---------------------------------------------------------------------------
    #   ReadProfileConfig
    #---------------------------------------------------------------------------
    [System.Xml.XmlDocument] ReadProfileConfig(
        [System.String] $FilePathProfileConfig) 
    {
        # Read the profile config file
        Return ([System.Xml.XmlDocument] (Get-Content -Path $FilePathProfileConfig))
    }
    #---------------------------------------------------------------------------
    #   ImportProfile
    #---------------------------------------------------------------------------
    [Void] ImportProfile(
        [System.String[]] $UserProfile)
    {
        $This.ImportProfile($UserProfile, $False)
    }

    #---------------------------------------------------------------------------
    #   ImportProfile
    #---------------------------------------------------------------------------
    [Void] ImportProfile(
        [System.String[]] $UserProfile,
        [Bool] $Bool_ForceRemove)
    {
        # Get imported Module
        $LoadedModule = Get-Module;

        # Loop through all elements with the defined tag
        ForEach ($Loop_UserProfile in $UserProfile) 
        {
            $Loop_UserProfile
            ForEach ($Loop_Package in $This.GetProfile($Loop_UserProfile) ) 
            {
                $Bool_ModuleExists = $False;
                If (($LoadedModule | Where-Object { $_.Name -Eq $Loop_Package}))
                {
                    $Bool_ModuleExists = $True;
                    If ($Bool_ForceRemove)
                    {
                        Remove-Module -Name $Loop_Package -Force
                    }
                }

                If (-not $Bool_ModuleExists -or $Bool_ForceRemove) 
                {
                    
                    # If ($Package.Import) 
                    # {
                    #     $ArgumentList = [Regex]::Replace($Package.Import.Text,$Package.Import.Pattern, (Get-Variable -Name $Package.Import.Type).Value)
                    # }
                    #     Import-Module -Name $Package.Name -ArgumentList $ArgumentList -Verbose:($False)
                    Import-Module -Name $Loop_Package -Verbose:($False)
                }
            }
        }
    }

    #---------------------------------------------------------------------------
    #   RemoveProfile
    #---------------------------------------------------------------------------
    [Void] RemoveProfile(
        [System.String[]] $UserProfile)
    {
        # Get imported Module
        $LoadedModule = Get-Module;

        # Loop through all elements with the defined tag
        ForEach ($Loop_UserProfile in $UserProfile) 
        {
            ForEach ($Loop_Package in $This.GetProfile($Loop_UserProfile) ) 
            {
                If (($LoadedModule | Where-Object { $_.Name -Eq $Loop_Package}))
                {
                    Remove-Module -Name $Loop_Package -Force
                }
            }
        }
    }

    # #---------------------------------------------------------------------------
    # #   RemoveProfile
    # #---------------------------------------------------------------------------
    # [Void] RemoveProfile(
    #     [Bool] $Bool_ForceAll)
    # {

    #     $ProfileKeys = GetProfileKeys()

    #     ForEach ($Loop_UserProfile in $UserProfile) 
    #     {      
    #         # Loop through all elements with the defined tag
    #         ForEach ($Loop_Package in $This.GetProfile($Loop_UserProfile) ) 
    #         {
    #             If (($LoadedModule | Where-Object { $_.Name -Eq $Loop_Package}))
    #             {
    #                 Remove-Module -Name $Loop_Package -Force
    #             }
    #         }
    #     }
    # }

    #---------------------------------------------------------------------------
    #   IsInstalled()
    #---------------------------------------------------------------------------
    [System.Object] IsInstalled()
    {
        Return $This.Packages | Where-Object { 
            $_.Repository -match "PSGallery" -and $_.Installed -eq $True }
    }

    #---------------------------------------------------------------------------
    #   NotInstalled()
    #---------------------------------------------------------------------------
    [System.Object] IsntInstalled()
    {
        Return $This.Packages | Where-Object { 
            $_.Repository -match "PSGallery" -and $_.Installed -eq $False }
    }

    #---------------------------------------------------------------------------
    #   ShowInstalled()
    #---------------------------------------------------------------------------
    [System.Object] ShowInstalled()
    {
        Return $This.Packages | Where-Object { 
            $_.Repository -match "PSGallery" -and $_.Installed -eq $True }
    }
    #---------------------------------------------------------------------------
    #   IsInstalled()
    #---------------------------------------------------------------------------
    [System.Object] ShowIsntInstalled()
    {
        Return $This.Packages | Where-Object { 
            $_.Repository -match "PSGallery" -and $_.Installed -eq $False } | Format-Table
    }


    #---------------------------------------------------------------------------
    #   GetManagedPackages
    #---------------------------------------------------------------------------
    [Void] GetManagedPackages()
    {
        # Read the profile config file
        $ProfileConfig = $This.ReadProfileConfig()

        # Get installed Module
        $InstalledPackages = Get-InstalledModule;


        # Loop through all elements with the defined tag
        $TempPackages = ForEach ($Loop_Item in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Deactivated='false']").Node) 
            {
                $InstalledPackage = $InstalledPackages | Where-Object -Property Name -contains $Loop_Item.Name

                [PSCustomObject]@{
                    Version = $InstalledPackage.Version
                    Installed =  $InstalledPackage -ne $Null 
                    Name = $Loop_Item.Name
                    Repository = $Loop_Item.Repository
                    Description = $Loop_Item.Description}
            } 

        $This.Packages = $TempPackages| Sort-Object -Property @{Expression = "Repository"; Descending = $True}, @{Expression = "Name"; Descending = $False} 
    }

    #---------------------------------------------------------------------------
    #   GetVersionUpDate()
    #---------------------------------------------------------------------------
    [System.Object] GetVersionUpDates()
    {
        $LocalPackages = $This.Packages

        ForEach ($Loop_Item in ($LocalPackages | Where-Object {$_.Repository -match "PSGallery" -and $_.Installed -eq $True}))
        {
            $Loop_Item.UpToDate = $Loop_Item.Version -match (Find-Module -Name $Loop_Item.Name).Version
        }

        Return $LocalPackages
    }

        
    #---------------------------------------------------------------------------
    #   ShowUpDateManager
    #---------------------------------------------------------------------------
    [Void] ShowUpDateManager()
    {
        # $This.Update()
        # $This.GetVersionsUpdates()







        Write-PSObject  $This.Packages -MatchMethod Match -Column Installed -Value $False -ValueForeColor White -ValueBackColor Blue;












        #     $Expression =
        #     {
        #         If( ($_.Repository -match "PSGallery") -and (-not $_.Installed))
        #         {
        #             $color = "93"
        #         } 
        #         ElseIf( $_.Repository -match "PSGallery" -and -not $_.UpToDate) {
        #             $color = "32"
        #         }
        #         Else {
        #             $color = "0" 
        #         }
        #         $e = [char]27
        #        "$e[${color}m$($_.Name)${e}[0m" ############### HEERERERERERE LABEL
        #     }
        


        # Return $This.Packages | Format-Table @{
        #     Label = "Version"
        #     Expression = $Expression },
        #     @{Label = "Installed"
        #     Expression = $Expression },
        #     @{Label = "Name"
        #     Expression = $Expression },
        #     @{Label = "Repository"
        #     Expression = $Expression },
        #     @{Label = "Description"
        #     Expression = $Expression }

        # dir -Exclude *.xml $pshome | Format-Table Mode,@{
        #     Label = "Name"
        #     Expression =
        #     {
        #         switch ($_.Extension)
        #         {
        #             '.exe' { $color = "93"; break }
        #             '.ps1xml' { $color = '32'; break }
        #             '.dll' { $color = "35"; break }
        #            default { $color = "0" }
        #         }
        #         $e = [char]27
        #        "$e[${color}m$($_.Name)${e}[0m"
        #     }
        #  },Length
    }


    #---------------------------------------------------------------------------
    #   ConvertConfigToObject
    #---------------------------------------------------------------------------
    [Void] ConvertConfigToObject()
    {
        # Read the profile config file
        $ProfileConfig = $This.ReadProfileConfig()
        
        # Initialize a hashtable to store specific profiles
        $HashTable_Profiles = [HashTableList]::New()

        # Loop through all elements with the defined tag
        ForEach ($Loop_Item in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Deactivated='false']").Node) 
        {
            # Array for storing required packages
            $Array = [System.Collections.Arraylist]::New()
            [Void] $Array.Add($Loop_Item.Name);

            # Recursive search to get required packages
            $This.RecursiveSearchProfile($ProfileConfig, $Array, $Loop_Item)

            # Add the profile groups to the hashtable
            ForEach ($Loop_SubItem in (Select-Xml -Xml $Loop_Item -XPath ".//UserProfile").Node) 
            { 
                $HashTable_Profiles.ExtAdd($Loop_SubItem.InnerText,$Array)
            }
        }
        # $UserProfiles
         $This.Profiles = $HashTable_Profiles
    }

    #---------------------------------------------------------------------------
    #   RecursiveSearchProfile
    #---------------------------------------------------------------------------
    # Search for required packages and insert them into the related array
    [Void] RecursiveSearchProfile(
        [System.Xml.XmlDocument] $ProfileConfig,     
        [System.Collections.Arraylist] $Array,
        [System.Xml.XmlElement] $Element)
    {
        # !!!!!!!!!!!!!!!!!!!! Task: Effiency if programming a hash
        # 
        ForEach ($Loop_Item_1 in (Select-Xml -Xml $Element -XPath ".//RequiredPackages").Node)
        {   
            ForEach ($Loop_Item_2 in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Name='$($Loop_Item_1.InnerText)' and Deactivated='false']").Node)
            {
                If ( -not ($Array -contains $Loop_Item_2.Name)) 
                {
                    [Void] $Array.Add($Loop_Item_2.Name)
                    $This.RecursiveSearchProfile($ProfileConfig, $Array, $Loop_Item_2)
                }
            }
        }
    }
}

# =============================================================================
#    Define Global Variables
# =============================================================================

    # Set Modules Path
        $PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
        $PSModulePath += ";$env:Home\PSModules"
        [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath)

    # Initialize object of class profile
        $Global:UserProfile = [Profile]::New()

    # Set location to %Home%
        $UserProfile.SetPathHome()

    # Clear Variables
        Remove-Variable -Name PSModulePath