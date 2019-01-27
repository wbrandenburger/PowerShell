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

# =============================================================================
#    Class Progress
# =============================================================================
Class Progress
{
    [System.String] $Activity
    [System.String] $Status
    [System.Int32] $Num_Ops
    [System.Int32] $Idx_Ops
    
    Progress(
        [System.String] $Activity,
        [System.String] $Status,
        [System.Int32] $Num_Ops
    )
    {
        $This.Activity = $Activity
        $This.Status = $Status
        $This.Num_Ops = $Num_Ops
        $This.Idx_Ops = 0;
    }

    [Void] ShowProgress()
    {
        Write-Progress -Activity $This.Activity -Status $This.Status -PercentComplete ($This.Idx_Ops/$This.Num_Ops*100)
        $This.Idx_Ops++
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

Enum PackageTask {
    Install
    Update
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
    #   GetManagedPackages
    #---------------------------------------------------------------------------
    [Void] GetManagedPackages()
    {
        # Read the profile config file
        $ProfileConfig = $This.ReadProfileConfig()

        # Get installed Module
        $InstalledPackages = Get-InstalledModule;


        # Loop through all elements with the defined tag
        $TempPackages = ForEach ($_ in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Deactivated='false']").Node) 
            {
                $InstalledPackage = $InstalledPackages | Where-Object -Property Name -contains $_.Name

                [PSCustomObject]@{
                    Version = $InstalledPackage.Version
                    Installed =  $InstalledPackage -ne $Null 
                    Name = $_.Name
                    Repository = $_.Repository
                    Description = $_.Description}
            } 

        $This.Packages = $TempPackages| Sort-Object -Property @{Expression = "Repository"; Descending = $True}, @{Expression = "Name"; Descending = $False} 
    }
 
    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [System.Object] PackageManager() 
    {   
        Return $This.PackageManager($False)
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [System.Object] PackageManager(
        [Bool] $UpDate
    ) 
    {   
        If ($UpDate) {
            $Progress = [Progress]::New("Search online for packages", "Progress:", ($This.Packages | Where-Object {$_.Repository -match "PSGallery" -and  $_.Installed}).Count)
        }

        Return  $This.Packages | ForEach-Object {
            $Color = "0"; $Task = ""
            If ($_.Repository -match "PSGallery" -and (-not $_.Installed))
            {$Color = "31"; $Task = [PackageTask]::Install}
            ElseIf ($_.Repository -match "LocalRepository")
            {$Color = "36";}
            ElseIf ($UpDate){
                $Progress.ShowProgress()
                If(-not ($_.Version -match (Find-Module -Name $_.Name).Version))
                {$Color = "95"; $Task = [PackageTask]::UpDate}
            }
            [PSCustomObject] @{
                Name = $_.Name
                Task = $Task
                Expression = "$([Char]27)[${Color}m$($_.Name)$([Char]27)[0m"
            }
        } 
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages() 
    {
        # Show the lists of profiles
        Return $This.ShowPackages($False)
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages(
        [Bool] $UpDate
    ) 
    {
        Return $This.ShowPackages($This.PackageManager($UpDate))
    }
    
    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages(
        [System.Object] $PackageManager
    ) 
    {
        # Show the lists of profiles
        Return $This.Packages | Format-Table @{
            Label = "Task"
            Expression = {
                $Value = ($PackageManager[$This.Packages.IndexOf($_)]).Task
                "$([Char]27)[93m$Value$([Char]27)[0m"}
            },
            @{Label = "Name"
            Expression = {
                ($PackageManager[$This.Packages.IndexOf($_)]).Expression}
            },Version,Repository,Description
    }

    #---------------------------------------------------------------------------
    #   CheckPackages
    #---------------------------------------------------------------------------
    [System.Object] CheckPackages() 
    {
        # Show the lists of profiles
        Return $This.CheckPackages($False)
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] CheckPackages(
        [Bool] $UpDate
    ) 
    {
        $PackageManager = $This.PackageManager($UpDate)

        If (-not (($PackageManager.Task -contains [PackageTask]::Install) -or ($PackageManager.Task -contains [PackageTask]::UpDate)))
        {
          Write-Host "All required PowerShell packages are available." -ForeGroundColor "DarKGreen"
        }
        Else 
        {
            Write-Warning "Some required PowerShell are not installed or uptodate."
        }

        Return $This.ShowPackages($PackageManager)
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
        [System.String] $FilePathProfileConfig
    ) 
    {
        # Read the profile config file
        Return ([System.Xml.XmlDocument] (Get-Content -Path $FilePathProfileConfig))
    }

    #---------------------------------------------------------------------------
    #   InstallManager
    #---------------------------------------------------------------------------
    [Void] InstallManager()
    {
        $This.InstallManager($This.PackageManager())
    }

    #---------------------------------------------------------------------------
    #   InstallManager
    #---------------------------------------------------------------------------
    [Void] InstallManager(
        [System.Object] $PackageManager
    )
    {
        ###### WORKING
        $PackagesToBeInstalled = $PackageManager | Where-Object {$_.Task -match [PackageTask]::Install}
        Write-Host "$(($PackagesToBeInstalled).Count) Packages have to be installed:" -ForeGroundColor "Yellow"
        $PackagesToBeInstalled | ForEach {
            Write-Host "    Package: $($_.Expression)"
        }




        $UserInput = [UserInput]::New("Install all packages in a joint operation?")
        $UserInput.SetPredefinedOptions("Binary")
        Write-Host $UserInput.PromptQuery()

        # $PackagesToBeInstalled | ForEach {
        #     Write-Host "Do you want to install $($_.Expression)?"
        #     Write-Host ("[Y] Yes" + " (Default)" + "  ") -ForeGroundColor "Yellow" -NoNewLine
        #     Write-Host ("[N] No" + "  ") -NoNewLine
        #     Write-Host ("[?] Help" + ":") -NoNewLine
        #     $Input_Host = Read-Host 
        # }
    }


    #---------------------------------------------------------------------------
    #   ImportProfile
    #---------------------------------------------------------------------------
    [Void] ImportProfile(
        [System.String[]] $UserProfile
    )
    {
        $This.ImportProfile($UserProfile, $False)
    }

    #---------------------------------------------------------------------------
    #   ImportProfile
    #---------------------------------------------------------------------------
    [Void] ImportProfile(
        [System.String[]] $UserProfile,
        [Bool] $Bool_ForceRemove
    )
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
        [System.String[]] $UserProfile
    )
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
    #   ConvertConfigToObject
    #---------------------------------------------------------------------------
    [Void] ConvertConfigToObject()
    {
        # Read the profile config file
        $ProfileConfig = $This.ReadProfileConfig()
        
        # Initialize a hashtable to store specific profiles
        $HashTable_Profiles = [HashTableList]::New()

        # Loop through all elements with the defined tag
        ForEach ($_ in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Deactivated='false']").Node) 
        {
            # Array for storing required packages
            $Array = [System.Collections.Arraylist]::New()
            [Void] $Array.Add($_.Name);

            # Recursive search to get required packages
            $This.RecursiveSearchProfile($ProfileConfig, $Array, $_)

            # Add the profile groups to the hashtable
            ForEach ($Loop_SubItem in (Select-Xml -Xml $_ -XPath ".//UserProfile").Node) 
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
        [System.Xml.XmlElement] $Element
    )
    {
        # !!!!!!!!!!!!!!!!!!!! Task: Effiency if programming a hash
        # 
        ForEach ($__1 in (Select-Xml -Xml $Element -XPath ".//RequiredPackages").Node)
        {   
            ForEach ($__2 in (Select-Xml -Xml $ProfileConfig -XPath "//Package[Name='$($__1.InnerText)' and Deactivated='false']").Node)
            {
                If ( -not ($Array -contains $__2.Name)) 
                {
                    [Void] $Array.Add($__2.Name)
                    $This.RecursiveSearchProfile($ProfileConfig, $Array, $__2)
                }
            }
        }
    }
}

# =============================================================================
#    ReadHost
# =============================================================================





# =============================================================================
#    UserInput
# =============================================================================
Class UserInput
{
    [System.String] $HelpOption
    [System.String] $HelpValue
    [System.String] $EndQuery
    [System.String] $Delimiter
    
    [System.String] $Query
    [System.String[]] $Options    

    UserInput()
    {
        $This.UserInputInitialization()
    }

    UserInput(
        [System.String] $Query
    )
    {
        $This.Query = $Query

        $This.UserInputInitialization()
    }

    UserInput(
        [System.String] $Query,
        [System.String[]] $Options
    )
    {
        $This.Query = $Query
        $This.Options =  $Options

        $This.UserInputInitialization()
    }

    [Void] UserInputInitialization()
    {
        $This.HelpOption = "[%s] Help"
        $This.HelpValue = "?"
        $This.EndQuery = ":"
        $This.Delimiter = "  "
    }

    [Void] SetPredefinedOptions(
        [System.String] $PredefinedOption
    )
    {
        [System.Collections.Hashtable ]$PredefinedOptions = @{
            Binary = ("Yes","No")
        }
        
        $This.Options = $PredefinedOptions[$PredefinedOption]
    }

    [System.String] PromptQuery()
    { 
        Return $This.PromptQuery($This.Query, $This.Options)
    }

    [System.String] PromptQuery(
        [System.String] $Query,
        [System.String[]] $Options
    )
    {   
        $TestResult = [TestResult]::New()     
        Do {
            $This.PrintQuery([System.String] $Query, [System.String[]] $Options)
            $Input_Query = Read-Host

            If (($This.TestHelpValue($Input_Query, $This.HelpValue)).Success)
            {
                # Help
                Continue
            }

            $TestResult = $This.ValidateValue($Input_Query, $Options)

            If (-not $TestResult.Success)
            {
                Write-Warning "The input is not an approved object."
            }
        } 
        While (-not $TestResult.Success)
       
        Return $TestResult.Value
    }
    
    [Void] PrintQuery(
        [System.String] $Query,
        [System.String[]] $Options
    )
    {
        For($LoopIdx_Options = 0; $LoopIdx_Options -lt $Options.Length; $LoopIdx_Options++)
        {
            Write-Host ("[$LoopIdx_Options] " + $Options[$LoopIdx_Options] + "$($This.Delimiter)") -NoNewLine
        }
        Write-Host ([Regex]::Replace($This.HelpOption,"%s", $This.HelpValue) + $This.EndQuery) -NoNewLine
    }

    [TestResult] ValidateValue(
        [System.String] $Value,
        [System.String[]] $Array)
    {
        #$TestResults = [System.Collections.Generic.List[PSCustomObject]]::New()
        $TestResult = [TestResult]::New()

        $TestResult.SetTestResult($This.TestValueIsIndexOf($Value, $Array))
        If ($TestResult.Success)
        {
            Return $TestResult
        }

        $TestResult.SetTestResult($This.TestArrayContainsValue($Value, $Array))
        If ($TestResult.Success)
        {
            Return $TestResult
        }

        Return $TestResult
    }

    [TestResult] TestHelpValue(
        [System.String] $Value,
        [System.String] $HelpValue
    )
    {
        $TestResult = [TestResult]::New()

        # Replace HelpValue
        If (([Regex]::Match($Value,"^\?$")).Success)
        {
            $TestResult.SetTestResult($True, "-1") 
        }

        Return $TestResult
    }

    [TestResult] TestValueIsIndexOf(
        [System.String] $Value,
        [System.String[]] $Array
    )
    {
            $TestResult = [TestResult]::New()

            # Check whether input consists only of digits
            $Regex_Digit = [Regex]::Match($Value,"^[0-9]+$")
            If ($Regex_Digit.Success)
            {
                # Check whether digits are in between indices of the array
                If (($Regex_Digit.Value -ge 0) -and ($Regex_Digit.Value -lt $Array.Count))
                {
                    $TestResult.SetTestResult($True, $Value) 
                }
            }

            Return $TestResult
    }

    [TestResult] TestArrayContainsValue(
        [System.String] $Value,
        [System.String[]] $Array
    )
    {
        Return  $This.TestArrayContainsValue($Value,$Array,1)
    } 

    [TestResult] TestArrayContainsValue(
        [System.String] $Value,
        [System.String[]] $Array,
        [System.ValueType] $Bool_Insensitive
    )
    {
        $TestResult = [TestResult]::New()

        If (-not [Regex]::Match($Value,"[^a-z0-9]",$Bool_Insensitive).Success)
        {
            For ($LoopIdx_Array = 0; $LoopIdx_Array -lt $Array.Count; $LoopIdx_Array++) 
            {
                # Check whether Value match a element of the array 
                $Regex_Contains = [Regex]::Match($Array[$LoopIdx_Array],"^$Value$",$Bool_Insensitive)
                If ($Regex_Contains.Success)
                {
                    $TestResult.SetTestResult($True, $LoopIdx_Array) 
                }
            }
        }
        Return $TestResult
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

    # Check available packages
        $UserProfile.CheckPackages()

    # Clear Variables
        Remove-Variable -Name PSModulePath