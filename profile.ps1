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


# Tasks REQUIRED  Tools - Dont Remove!!!!!
# Questions and Task Combine as Table for better 

#psd1


# $UrlPath = "https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.%s?view=pscore-6.0.0"

# [Regex]::Replace($UrlPath,"%s", $Query)

# scope=.NET
# nuget
# pscore-6.0.0

# Color Module

# Environment Path Module C#
# Windows Tools!!!

# Fill Profil XML from Find Moduel and so on!!!!


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
    [System.String] $PathLocal
    [System.String] $FilePathProfile
    [System.String] $PathConfig
    [System.String] $FilePathGroupProfiles
    
    [System.Object] $GroupProfiles
    [System.Object] $Packages
    [System.Object] $PackageStatus

    [System.Collections.ArrayList] $PackageTasks

    #---------------------------------------------------------------------------
    #   Constructor
    #---------------------------------------------------------------------------
    Profile($Path_Home)
    {
        # Location of local powershell settings
        $This.PathLocal = $Path_Home
        $This.FilePathProfile = Join-Path -Path $Path_Home -ChildPath "profile.ps1"
        $This.PathConfig = Join-Path -Path $Path_Home -ChildPath ".config"
        $This.FilePathGroupProfiles = Join-Path -Path $Path_Home -ChildPath ".config\profile.xml"

        $This.PackageTasks = [System.Collections.ArrayList]::New( @(
            "Install",
            "Uninstall",
            "Update",
            "Import",
            "Remove",
            "Import-Group",
            "Remove-Group")
        )
        
        $This.GetGroupProfileFromFile()
    }

    #---------------------------------------------------------------------------
    #   Update
    #---------------------------------------------------------------------------
    [Void] Update()
    {
        $This.GetGroupProfileFromFile()
        $This.GetPackageStatus()
    }

    #---------------------------------------------------------------------------
    #   ShowProfiles
    #---------------------------------------------------------------------------
    [System.Object] ShowProfiles() 
    {
        Return $This.GroupProfiles | Format-Table
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages() 
    {
        Return $This.Packages | Format-Table Deactivated, Name, Repository, Scope, UserProfile, Description 
    }

    #---------------------------------------------------------------------------
    #   ShowPackageStatus
    #---------------------------------------------------------------------------
    [System.Object] ShowPackageStatus() 
    {
        If ($This.PackageStatus -eq $Null)
        {
            $This.GetPackageStatus() 
        }
        
        Return $This.PackageStatus | Format-Table @{
            Label = "Task"
            Expression = {$_.ColoredTask}}, Version, @{
            Label = "Name"
            Expression = {$_.ColoredName}}, Repository, Description
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfilesPackages(
        [System.String[]] $GroupProfiles) 
    {
        # Return a profile list
        Return ($GroupProfiles | ForEach { $GroupProfile = $_; $This.GroupProfiles | Where-Object {$_.GroupProfile -contains $GroupProfile}}).Packages | Sort -Unique | ForEach {[PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfiles() 
    {
        # Return a profile list
        Return $This.GroupProfiles | Select-Object -Property GroupProfile | Sort
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    [System.Object] GetGroupProfilesPackages() 
    {
        # Return a profile list
        Return $This.GroupProfiles.Packages | Sort -Unique | ForEach {
            [PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   GetVTSequence
    #---------------------------------------------------------------------------

    [System.String] GetVTSequence(
        [System.String] $Value,
        [System.ValueType] $Color
    )
    {
        Return "$([Char]27)[${Color}m$Value$([Char]27)[0m"
    }

    #---------------------------------------------------------------------------
    #  GetPackageStatus()
    #---------------------------------------------------------------------------
    [Void] GetPackageStatus()  
    {
        # Get installed Module
        $PckgsInst = Get-InstalledModule
        $PckgsIprt = Get-Module

        # Loop through all elements with the defined tag
        $This.PackageStatus = ForEach ($Loop_Pckgs in ($This.Packages | Where { $_.Deactivated -match "false"})) {
                $Name = $Loop_Pckgs.Name; $Task = $Null
                $Color = 0; $Repo = $Loop_Pckgs.Repository
                $Version = ($PckgsInst | Where {$_.Name -eq $Loop_Pckgs.Name}).Version
                If ( $PckgsInst.Name -contains $Loop_Pckgs.Name) {
                    # If ( -not ($Version -eq (Find-Module $Loop_Pckgs.Name).Version)){
                    #     $Task = "Update";  $Color = 36
                    # }
                }
                ElseIf ($Repo -match "PSGallery" ) {
                    $Task = "Install"; $Color = 31;}
                $ColoredTask = $This.GetVTSequence($Task, $Color)
                
                If ($PckgsIprt.Name -contains $Loop_Pckgs.Name) {
                    $Color = 32;}
                $ColoredName = $This.GetVTSequence($Loop_Pckgs.Name, $Color)

                [PSCustomObject]@{
                    Name = $Loop_Pckgs.Name; Version = $Version; Task = $Task
                    Session = ($PckgsIprt.Name -contains $Loop_Pckgs.Name)
                    ColoredTask = $ColoredTask 
                    ColoredName = $ColoredName
                    Repository = $Repo; Description = $Loop_Pckgs.Description
                }
            }
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [System.Object] PackageManager(
        [System.String] $Task) 
    {
        $Question = ""; $Object = New-Object PSCustomObject
        Switch ($Task) {
            "Install" {
                $Question = "Which packages should be get installed?"
                $Object = $This.PackageStatus | Where {$_.Task -match $Task}
            }
            "Uninstall" {
                $Question = "Which packages should be get uninstalled?"
                $Object = $This.PackageStatus | Where {$_.Repository -match "PSGallery"}
            }
            "Update" {
                $Question = "Which packages should be get updated?"
                $Object = $This.PackageStatus | Where {$_.Task -match $Task}
            }                     
            "Import" {
                $Question = "Which packages should be get imported?"
                $Object = $This.GroupProfiles.Packages | Sort -Unique
            }
            "Remove" {
                $Question = "Which packages should be get removed?"
                $Object = $This.GroupProfiles.Packages | Sort -Unique
            }
            "Import-Group" {
                $Question = "Which group profile should be get imported?"
                $Object = $This.GetGroupProfiles().GroupProfile
            }
            "Remove-Group" {
                $Question = "Which group profile should be get removed?"
                $Object = $This.GetGroupProfiles().GroupProfile
            }
            Default {
                Write-Warning "Task $Task is not valid."        
            }
        }

        $This.ChangeManager( $Task, $Question, $This.GetArrayList( $Object))

        Return $This.ShowPackageStatus() 
    }

    #---------------------------------------------------------------------------
    #   GetPackagesInstall
    #---------------------------------------------------------------------------
    [System.Collections.ArrayList] GetArrayList(
        [System.Object] $Object
    )
    {   $Array = [System.Collections.ArrayList]::New();
        $Object | ForEach { [Void] $Array.Add( $_ ) }

        Return $Array
    }

    #---------------------------------------------------------------------------
    #   ChangeManager
    #---------------------------------------------------------------------------
    [Void] ChangeManager(
        [System.String] $Task,
        [System.String] $Question,
        [System.Collections.ArrayList] $Options
    )
    {
        If ($Options.Count -gt 0 )
        {
            $LoopIdx = 0;
            $Abort = $True
            Do {
                $Abort = $This.ChangePackages(
                    $This.ChangeQuery($Question,$Options),
                    $Options, 
                    $Task)
                $LoopIdx++
            } While ($Options.Count -gt 0 -and $Abort)

            If ($Abort) {Write-Warning "Completion of Task $Task." }
            Else {Write-Warning "Task $Task aborted." }
            If ($LoopIdx -gt 1) {
                $This.Update();
            }
        }
        Else {
            Write-Warning "There are no packages which are available for Task $Task."
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

        For ($LoopIdx_Pckg = $ChangePckg.Count - 1;
                $LoopIdx_Pckg -ge 0;
                $LoopIdx_Pckg--) 
        {
            Switch ($Task) {
            "Install" {
                Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command Find-Module -Name $($ChangePckg[$LoopIdx_Pckg]) | Install-Module -Scope AllUsers -Verbose -Force" -Verb RunAs
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                Break
            }
            "Uninstall" {
                Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -Command Uninstall-Module -Name $($ChangePckg[$LoopIdx_Pckg]) -Verbose -Force" -Verb RunAs
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                Break
            }
            "Update" { 
                Update-Module $ChangePckg[$LoopIdx_Pckg]
                Break
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
            }
            "Import" {
                $This.ImportPackage($ChangePckg[$LoopIdx_Pckg])
                Break
            }
            "Remove" {
                $This.RemovePackage($ChangePckg[$LoopIdx_Pckg])
                Break
            } 
            "Import-Group" {
                $This.ManageGroupProfiles("Import", $ChangePckg[$LoopIdx_Pckg])
                Break
            }
            "Remove-Group" {
                $This.ManageGroupProfiles("Remove", $ChangePckg[$LoopIdx_Pckg])
                Break
            }              
            }     
        }

        Return $True
    }

    #---------------------------------------------------------------------------
    #   ImportPackage
    #---------------------------------------------------------------------------
    [System.Object] ImportPackage(
        [System.String] $Package
    )
    {
        Import-Module -Name $Package -Verbose:($True)
        # If ($Package.Import){ $ArgumentList = [Regex]::Replace($Package.Import.Text,$Package.Import.Pattern, (Get-Variable -Name $Package.Import.Type).Value)}
        #  Import-Module -Name $Package.Name -ArgumentList $ArgumentList -Verbose:($False)
        Return Get-Module;
    }
    
    [System.Object] RemovePackage(
        [System.String] $Package
    )
    {
        $LoadedModule = Get-Module;
        If ($LoadedModule | Where-Object { $_.Name -match $Package}) {
            Remove-Module -Name $Package -Force:($True) -Verbose:($True)
        }

        Return Get-Module;
    }

    #---------------------------------------------------------------------------
    #   ImportGroupProfile
    #---------------------------------------------------------------------------
    [System.Object] ManageGroupProfiles(
        [System.String] $Task,
        [System.String[]] $GroupProfiles
    )
    {
        $GroupProfilesPackages = $This.GetGroupProfilesPackages($GroupProfiles).Packages

        $Progress = [Progress]::New("Import/remove packages", "Progress:", $GroupProfilesPackages.Count)

        # Loop through all elements with the defined tag
        ForEach ($Lop_Packages in $GroupProfilesPackages)
        {
            $This.RemovePackage($Lop_Packages)

            If ($Task -match "Import") {
                $This.ImportPackage($Lop_Packages)
            }
        }

        Return Get-Module;
    }

    #---------------------------------------------------------------------------
    #   ReadGroupProfiles
    #---------------------------------------------------------------------------
    [System.Xml.XmlDocument] ReadGroupProfiles() 
    {
        # Read the profile config file
        Return ([System.Xml.XmlDocument] (Get-Content -Path $This.FilePathGroupProfiles))
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfileFromFile
    #---------------------------------------------------------------------------
    [Void] GetGroupProfileFromFile()
    {
        # Read the profile config file
        $GroupProfileXml = $This.ReadGroupProfiles()
        
        # Initialize a hashtable to store specific profiles
        $UniqueHashTableList = [System.Collections.Generic.Dictionary[[System.String],[System.Collections.Generic.HashSet[System.String]]]]::New()
        # Loop through all elements with the defined tag
        ForEach ($_ in (Select-Xml -Xml $GroupProfileXml -XPath "//Package[Deactivated='false']").Node) 
        {
            # Array for storing required packages
            $Array = [System.Collections.Arraylist]::New()
            [Void] $Array.Add($_.Name);

            # Recursive search to get required packages
            $This.RecursiveSearchProfile($GroupProfileXml, $Array, $_)

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

        $This.GroupProfiles =  $UniqueHashTableList.Keys | ForEach-Object { 
            $Array = [System.String[]]::New($UniqueHashTableList[$_].Count)
            $UniqueHashTableList[$_].CopyTo($Array)
            [PSCustomObject] @{
                                GroupProfile = $_
                                Packages = $Array
                            }
                        }
        $This.Packages = (Select-Xml -Xml $GroupProfileXml -XPath "//Package").Node
    }

    #---------------------------------------------------------------------------
    #   RecursiveSearchProfile
    #---------------------------------------------------------------------------
    # Search for required packages and insert them into the related array
    [Void] RecursiveSearchProfile(
        [System.Xml.XmlDocument] $GroupProfileXml,     
        [System.Collections.Arraylist] $Array,
        [System.Xml.XmlElement] $Element
    )
    {
        ForEach ($__1 in (Select-Xml -Xml $Element -XPath ".//RequiredPackages").Node)
        {   
            ForEach ($__2 in (Select-Xml -Xml $GroupProfileXml -XPath "//Package[Name='$($__1.InnerText)' and Deactivated='false']").Node)
            {
                If ( -not ($Array -contains $__2.Name)) 
                {
                    [Void] $Array.Add($__2.Name)
                    $This.RecursiveSearchProfile($GroupProfileXml, $Array, $__2)
                }
            }
        }
    }
}
