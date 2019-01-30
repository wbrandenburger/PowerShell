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
#    Define Global Variables
# =============================================================================

    # Set Modules Path
    $PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
    $PSModulePath += ";$env:Home\PSModules"
    [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath)

    # Import ProfileManagement module
    Import-Module "A:\OneDrive\Projects\PSModules\PSProfile\bin\Debug\net472\PSProfile.dll"

    # Initialize object of class profile
    $Global:UserProfile = [Profile]::New($PSScriptRoot)

    # Clear Variables
    Remove-Variable -Name PSModulePath


# =============================================================================
#    PowerShell Cmdlets
# =============================================================================

#------------------------------------------------------------------------------
#   Show-HostColors
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
    [System.Object] $PackageMgr

    #---------------------------------------------------------------------------
    #   Constructor
    #---------------------------------------------------------------------------
    Profile($Path_Home)
    {
        # Location of local powershell settings
        $This.PathLocal = $Path_Home
        $This.FilePathProfile = Join-Path -Path $Path_Home -ChildPath "profile.ps1"
        $This.PathConfig = Join-Path -Path $Path_Home -ChildPath ".config"
        $This.FilePathProfileConfig = Join-Path -Path $Path_Home -ChildPath ".config\profile.xml"

        $This.ConvertConfigToObject()
    }

    #---------------------------------------------------------------------------
    #   Update
    #---------------------------------------------------------------------------
    [Void] Update()
    {
        $This.ConvertConfigToObject()
    }

    #---------------------------------------------------------------------------
    #   ShowProfiles
    #---------------------------------------------------------------------------
    [System.Object] ShowProfiles() 
    {
        Return $This.Profiles | Format-Table
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages() 
    {
        Return $This.Packages | Format-Table Deactivated, Name, Repository, Scope, UserProfile, Description 
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackageManager() 
    {
        If ($This.PackageMgr -eq $Null)
        {
            $This.PackageManager() 
        }
        
        Return $This.PackageMgr | Format-Table ColoredTask, Version, ColoredName, Repository, Description
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfilesPackages(
        [System.String[]] $GroupProfiles) 
    {
        # Return a profile list
        Return ($GroupProfiles | ForEach { $GroupProfile = $_; $This.Profiles | Where-Object {$_.GroupProfile -contains $GroupProfile}}).Packages | Sort -Unique | ForEach {[PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfiles() 
    {
        # Return a profile list
        Return $This.Profiles | Select-Object -Property GroupProfile | Sort
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfilesPackages() 
    {
        # Return a profile list
        Return $This.Profiles.Packages | Sort -Unique | ForEach {
            [PSCustomObject] @{ Packages = $_ }}
    }

    [System.String] GetVTSequence(
        [System.String] $Value,
        [System.ValueType] $Color
    )
    {
        Return "$([Char]27)[${Color}m$Value$([Char]27)[0m"
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [Void] PackageManager()  
    {
        # Get installed Module
        $PckgsInst = Get-InstalledModule;

        # Loop through all elements with the defined tag
        $This.PackageMgr = ForEach ($Loop_Pckgs in ($This.Packages | Where { $_.Deactivated -match "false"})) {
                Write-Host $Loop_Pckgs.Name
                $Name = $Loop_Pckgs.Name; $Task = $Null
                $Color = 0; $Repo = $Loop_Pckgs.Repository
                $Version = ($PckgsInst | Where {$_.Name -eq $Loop_Pckgs.Name}).Version
                If ( $PckgsInst.Name -contains $Loop_Pckgs.Name) {
                    If ( -not ($Version -eq (Find-Module $Loop_Pckgs.Name).Version)){
                        $Task = "Update";  $Color = 36
                    }
                }
                ElseIf ($Repo -match "PSGallery" ) {
                    $Task = "Install"; $Color = 31;
                }
                $ColoredTask = $This.GetVTSequence($Task, $Color)
                $ColoredName = $This.GetVTSequence($Loop_Pckgs.Name, $Color)

                [PSCustomObject]@{
                    Name = $Loop_Pckgs.Name; Version = $Version; Task = $Task
                    ColoredTask = $ColoredTask 
                    ColoredName = $ColoredName
                    Repository = $Repo; Description = $Loop_Pckgs.Description
                }
            }
    }

    #---------------------------------------------------------------------------
    #   InstallManager
    #---------------------------------------------------------------------------
    [Void] InstallManager() 
    {
        If ($This.PackageMgr -eq $Null)
        {
            $This.PackageManager() 
        }

        $Options = [System.Collections.ArrayList]::New()
        $This.PackageMgr | Where {$_.Task -match "Install"} | ForEach {
            [Void] $Options.Add($_.Name)
        }

        If ($Options.Count -gt 0 )
        {
            $Question = "Which packages should be get installed?"

            Do {
                $Cancle = $This.ChangePackages($This.ChangeQuery($Question,$Options),$Options, "Install")
            } While ($Options.Count -gt 0 -and $Cancle)

            Write-Warning "Installing of packages completed."

            $This.PackageManager()  
        }
        Else {
            Write-Warning "There are no packages which have to be installed."
        }
    }

    #---------------------------------------------------------------------------
    #   UpdateManager
    #---------------------------------------------------------------------------
    [Void] UpdateManager() 
    {
        If ($This.PackageMgr -eq $Null)
        {
            $This.PackageManager() 
        }

        $Options = [System.Collections.ArrayList]::New()
        $This.PackageMgr | Where {$_.Task -match "Update"} | ForEach {
            [Void] $Options.Add($_.Name)
        }

        If ($Options.Count -gt 0 )
        {
            $Question = "Which packages should be get updated?"

            Do {
                $Cancle = $This.ChangePackages($This.ChangeQuery($Question,$Options),$Options, "Update")
            } While ($Options.Count -gt 0 -and $Cancle)

            Write-Warning "Updating of packages completed."

            $This.PackageManager()  
        }
        Else {
            Write-Warning "There are no packages which have to be updated."
        }
    }

    #---------------------------------------------------------------------------
    #   ChangeQuery
    #---------------------------------------------------------------------------
    [Int] ChangeQuery(
        [System.String] $Question,
        [System.Collections.ArrayList] $Options 
    ) 
    {
        $CLQuery = New-CLQuery -Question $Question -Options $Options -PredefinedOptions "List"
        Return $CLQuery.PromptQuery().Index
    }

    #---------------------------------------------------------------------------
    #   ChangePackages
    #---------------------------------------------------------------------------

    [Bool] ChangePackages(
        [Int] $UserInput,
        [System.Collections.ArrayList] $Options,
        [System.String] $Task
    )
    {
        If ($Options.Count -eq $UserInput) {
            $ChangePckg = [System.Collections.ArrayList]::New($Options)
        }
        ElseIf ($UserInput -lt $Options.Count) {
            $ChangePckg = [System.Collections.ArrayList]::New()
            $ChangePckg.Add($Options[$UserInput])
        }
        Else{
            Return $False
        }

        For ($LoopIdx_Pckg = 0;
                $LoopIdx_Pckg -lt  $ChangePckg.Count;
                $LoopIdx_Pckg++) 
        {
            $ChangeProperties = $This.Packages | Where {$_.Name -match $ChangePckg[$LoopIdx_Pckg]} | Select -Property Name, Scope

            Switch ($Task) {
                "Install" {
                    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command Find-Module -Name $($ChangeProperties.Name) | Install-Module -Scope $($ChangeProperties.Scope)" -Verb RunAs
                    Break;}
                "Update" { 
                        Update-Module $ChangeProperties.Name
                        Break;}
            }   

            $Options.RemoveAt(0)
        }

        Return $True
    }

    #---------------------------------------------------------------------------
    #   ImportGroupProfile
    #---------------------------------------------------------------------------
    [System.Object] ImportGroupProfile(
        [System.String[]] $GroupProfiles
    )
    {
       Return $This.ImportGroupProfile($GroupProfiles, $True)
    }

    #---------------------------------------------------------------------------
    #   ImportGroupProfile
    #---------------------------------------------------------------------------
    [System.Object] ImportGroupProfile(
        [System.String[]] $GroupProfiles,
        [Bool] $Bool_ForceRemove
    )
    {
        # Get imported Module
        $LoadedModule = Get-Module;

        $GroupProfilesPackages = $This.GetGroupProfilesPackages($GroupProfiles).Packages

        $Progress = [Progress]::New("Import packages", "Progress:", $GroupProfilesPackages.Count)

        # Loop through all elements with the defined tag
        ForEach ($Lop_Packages in $GroupProfilesPackages)
        {
            $Progress.ShowProgress()
            If (($LoadedModule | Where-Object { $_.Name -Eq $Lop_Packages}))
            {
                Remove-Module -Name $Lop_Packages -Force:($Bool_ForceRemove) -Verbose:($False)
            }

            # If ($Package.Import){ $ArgumentList = [Regex]::Replace($Package.Import.Text,$Package.Import.Pattern, (Get-Variable -Name $Package.Import.Type).Value)}
            #  Import-Module -Name $Package.Name -ArgumentList $ArgumentList -Verbose:($False)
            Import-Module -Name $Lop_Packages -Verbose:($False)
        }

        Return Get-Module;
    }

    #---------------------------------------------------------------------------
    #   RemoveGroupProfile
    #---------------------------------------------------------------------------
    [System.Object] RemoveGroupProfile(
        [System.String[]] $GroupProfiles
    )
    {
        Return $This.RemoveGroupProfile($GroupProfiles, $True) 
    }
    #---------------------------------------------------------------------------
    #   RemoveGroupProfile
    #---------------------------------------------------------------------------
    [System.Object] RemoveGroupProfile(
        [System.String[]] $GroupProfiles,
        [Bool] $Bool_ForceRemove
    )
    {
        # Get imported Module
        $LoadedModule = Get-Module;

        $GroupProfilesPackages = $This.GetGroupProfilesPackages($GroupProfiles).Packages

        $Progress = [Progress]::New("Import packages", "Progress:", $GroupProfilesPackages.Count)

        # Loop through all elements with the defined tag
        ForEach ($Lop_Packages in $GroupProfilesPackages) 
        {
            $Progress.ShowProgress()
            If (($LoadedModule | Where-Object { $_.Name -Eq $Lop_Packages}))
            {
                Remove-Module -Name $Lop_Packages -Force:($Bool_ForceRemove) -Verbose:($False)
            }
        }

        Return Get-Module;
    }

    #---------------------------------------------------------------------------
    #   RemoveGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] RemoveGroupProfiles()
    {
        # Get imported Module
        $LoadedModule = Get-Module;

        $GroupProfilesPackages = $This.GetGroupProfilesPackages().Packages

        $Progress = [Progress]::New("Import packages", "Progress:", $GroupProfilesPackages.Count)

        ForEach ($Lop_Packages in $GroupProfilesPackages) 
        {      
            $Progress.ShowProgress()
            If (($LoadedModule | Where-Object { $_.Name -Eq $Lop_Packages}))
            {
                Remove-Module -Name $Lop_Packages -Force:($True)
            }
        }

        Return Get-Module;
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
    #   ConvertConfigToObject
    #---------------------------------------------------------------------------
    [Void] ConvertConfigToObject()
    {
        # Read the profile config file
        $ProfileConfig = $This.ReadProfileConfig()
        
        # Initialize a hashtable to store specific profiles
        $UniqueHashTableList = [System.Collections.Generic.Dictionary[[System.String],[System.Collections.Generic.HashSet[System.String]]]]::New()
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
                If (-not $UniqueHashTableList.ContainsKey($Loop_SubItem.InnerText))
                {
                    $UniqueHashTableList.Add($Loop_SubItem.InnerText,[System.Collections.Generic.HashSet[System.String]]::New())
                }
                ForEach ($LopItem_Array in $Array) {
                    [Void] $UniqueHashTableList[$Loop_SubItem.InnerText].Add($LopItem_Array)
                }
            }
        }

        $This.Profiles =  $UniqueHashTableList.Keys | ForEach-Object { 
            $Array = [System.String[]]::New($UniqueHashTableList[$_].Count)
            $UniqueHashTableList[$_].CopyTo($Array)
            [PSCustomObject] @{
                                GroupProfile = $_
                                Packages = $Array
                            }
                        }
        $This.Packages = (Select-Xml -Xml $ProfileConfig -XPath "//Package").Node
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



# $UrlPath = "https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.%s?view=pscore-6.0.0"

# [Regex]::Replace($UrlPath,"%s", $Query)

# scope=.NET
# nuget
# pscore-6.0.0
