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
    $PSModulePath += ";$env:Home\Repositories"
    [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath)

    Import-Module PSCommandLine -Verbose

    # Initialize object of class profile
    $Global:Pro = [Profile]::New($PSScriptRoot)

    # Clear Variables
    Remove-Variable -Name PSModulePath

#-------------------------------------------------------------------------------
#   Prompt
#-------------------------------------------------------------------------------
Function Global:Prompt 
{
    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    $CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)


    Write-Host "[" -NoNewline -ForegroundColor DarkCyan
    Write-Host (Get-Date -UFormat %R) -NoNewline -ForegroundColor DarkCyan
    Write-Host "] " -NoNewline -ForegroundColor DarkCyan
	If ($CheckAs) { 
        Write-Host "(Admin) " -NoNewline -ForegroundColor DarkRed
    } 
    Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor DarkGreen 
    
    Write-Host " " -NoNewline

    If ((Get-Module).Name -contains "Posh-Git") {
        Write-VcsStatus
    }
}

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
    Hidden [System.String] $PathLocal
    Hidden [System.String] $FilePathProfile
    Hidden [System.String] $PathConfig
    Hidden [System.String] $FilePathGroupProfiles
    
    Hidden [System.Object] $Packages
    Hidden [System.Object] $GroupProfiles
    Hidden [System.Object] $PackagesRaw
    
    Hidden [System.Collections.ArrayList] $PackageTasks

    #---------------------------------------------------------------------------
    #   Constructor
    #---------------------------------------------------------------------------
    Profile($Path_Home)
    {
        # Location of local powershell settings
        $This.PathLocal = $Path_Home
        $This.FilePathProfile = Join-Path -Path $Path_Home -ChildPath "profile.ps1"
        $This.PathConfig = Join-Path -Path $Path_Home -ChildPath ".config"
        $This.FilePathGroupProfiles = Join-Path -Path $Path_Home -ChildPath ".config\ProfilePackages.xml"

        $This.PackageTasks = [System.Collections.ArrayList]::New( @(
            "Install",
            "Uninstall",
            "Update",
            "Import",
            "Remove",
            "Import-Group",
            "Remove-Group")
        )
    }

    #---------------------------------------------------------------------------
    #   Update
    #---------------------------------------------------------------------------
    [Void] Update()
    {
        $This.GetGroupProfileFromFile()
        $This.GetPackages()
    }

    #---------------------------------------------------------------------------
    #   ShowProfiles
    #---------------------------------------------------------------------------
    [System.Object] ShowGroupProfiles() 
    {
        $This.Update()

        Return $This.GroupProfiles | Format-Table
    }

    #---------------------------------------------------------------------------
    #   ShowPackages
    #---------------------------------------------------------------------------
    [System.Object] ShowPackagesRaw() 
    {
        $This.Update()

        Return $This.PackagesRaw | Format-Table 
    }

    #---------------------------------------------------------------------------
    #   ShowPackageStatus
    #---------------------------------------------------------------------------
    [System.Object] ShowPackages() 
    {
        $This.Update()

        Return $This.Packages | Format-Table @{
            Label = "Task"
            Expression = {$_.ColoredTask}}, Version, @{
            Label = "Name"
            Expression = {$_.ColoredName}}, Repository, Description
    }

    #---------------------------------------------------------------------------
    #   ShowPackageTasks
    #--------------------------------------------------------------------------
    [System.Object] ShowPackageTasks() 
    {
        Return $This.PackageTasks
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfilesPackages(
        [System.String[]] $GroupProfiles) 
    {
        # Return a profile list
        Return ($GroupProfiles | ForEach { $GroupProfile = $_; $This.GroupProfiles | Where-Object {$_.GroupProfile -contains $GroupProfile}}).Packages | Sort -Unique | ForEach {[PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfiles() 
    {
        # Return a profile list
        Return $This.GroupProfiles | Select-Object -Property GroupProfile | Sort
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfilesPackages() 
    {
        # Return a profile list
        Return $This.GroupProfiles.Packages | Sort -Unique | ForEach {
            [PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   FindPackage
    #---------------------------------------------------------------------------
    Hidden [Void] FindPackage(
        [System.String] $PackageName
    )
    {
        $Package = Find-Module -Name $PackageName
        If ($Package -ne $Null ) {
        Out-File -FilePath  "$($This.PathConfig)\Package.$PackageName.txt" -InputObject ($Package | Select-Object -Property Name, Author, Version, PublishedDate, Repository, Description)
        }
    }
    #---------------------------------------------------------------------------
    #   FindPackage
    #---------------------------------------------------------------------------
    [Void] FindPackage()
    {
        $This.Update()

        $This.Packages | Where {$_.Repository -match "PSGallery" } | ForEach { $This.FindPackage( $_.Name ) }
    }

    #---------------------------------------------------------------------------
    #   GetVTSequence
    #---------------------------------------------------------------------------
    Hidden [System.String] GetVTSequence(
        [System.String] $Value,
        [System.ValueType] $Color
    )
    {
        Return "$([Char]27)[${Color}m$Value$([Char]27)[0m"
    }

    #---------------------------------------------------------------------------
    #  GetPackageStatus()
    #---------------------------------------------------------------------------
    Hidden [Void] GetPackages()  
    {
        # Get installed Module
        $PckgsInst = Get-InstalledModule
        $PckgsIprt = Get-Module

        # Loop through all elements with the defined tag
        $This.Packages =  $This.PackagesRaw | Where { $_.Deactivated -match "false"} | ForEach {
                $Name = $_.Name; $Task = $Null; $Color = 0;
                $Version = ($PckgsInst | Where {$_.Name -eq $Name}).Version

                If ( $PckgsInst.Name -contains $_.Name) {
                    If ( -not ($Version -eq $_.Version)){
                        $Task = "Update";  $Color = 36
                    }
                }
                ElseIf ($_.Repository -match "PSGallery" ) {
                    $Task = "Install"; $Color = 31;}

                $ColoredTask = $This.GetVTSequence($Task, $Color)
                
                If ($PckgsIprt.Name -contains $_.Name) {
                    $Color = 32;}

                $ColoredName = $This.GetVTSequence($_.Name, $Color)

                [PSCustomObject]@{
                    Name = $_.Name; Version = $Version; Task = $Task
                    Session = ($PckgsIprt.Name -contains $_.Name)
                    ColoredTask = $ColoredTask 
                    ColoredName = $ColoredName
                    Repository = $_.Repository; Description = $_.Description
                }
            }
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [System.Object] PackageManager(
        [System.String] $Task) 
    {
        $This.Update()

        $Question = ""; $Object = New-Object PSCustomObject
        Switch ($Task) {
            "Install" {
                $Question = "Which packages should be get installed?"
                $Object = ($This.Packages | Where {$_.Task -match $Task}).Name
            }
            "Uninstall" {
                $Question = "Which packages should be get uninstalled?"
                $Object = ($This.Packages | Where {$_.Repository -match "PSGallery"}).Name
            }
            "Update" {
                $Question = "Which packages should be get updated?"
                $Object = ($This.Packages | Where {$_.Task -match $Task}).Name
            }                     
            "Import" {
                $Question = "Which packages should be get imported?"
                $Object = $This.Packages.Name
            }
            "Remove" {
                $Question = "Which packages should be get removed?"
                $Object = $This.Packages.Name
            }
            "Import-Group" {
                $Question = "Which group profile should be get imported?"
                $Object = $This.GroupProfiles.GroupProfile
            }
            "Remove-Group" {
                $Question = "Which group profile should be get removed?"
                $Object = $This.GroupProfiles.GroupProfile
            }
            Default {
                Write-Warning "Task $Task is not valid."        
            }
        }
        $This.ChangeManager( $Task, $Question, $This.GetArrayList( $Object))

        Return $This.ShowPackages() 
    }

    #---------------------------------------------------------------------------
    #   GetPackagesInstall
    #---------------------------------------------------------------------------
    Hidden [System.Collections.ArrayList] GetArrayList(
        [System.Object] $Object
    )
    {   $Array = [System.Collections.ArrayList]::New();
        If ($Object.Count -gt 0) {$Object | ForEach { [Void] $Array.Add( $_ ) }}
        
        Return $Array
    }

    #---------------------------------------------------------------------------
    #   ChangeManager
    #---------------------------------------------------------------------------
    Hidden [Void] ChangeManager(
        [System.String] $Task,
        [System.String] $Question,
        [System.Collections.ArrayList] $Options
    )
    {
        If ($Options.Count -gt 0 )
        {
            $Abort = $True
            Do {
                $Abort = $This.ChangePackages(
                    $This.ChangeQuery($Question,$Options),
                    $Options, 
                    $Task)
                $This.Update();
            } While ($Options.Count -gt 0 -and $Abort)

            If ($Abort) {Write-Warning "Completion of Task $Task." }
            Else {Write-Warning "Task $Task aborted." }
        }
        Else {
            Write-Warning "There are no packages which are available for Task $Task."
        }
    }

    #---------------------------------------------------------------------------
    #   ChangeQuery
    #---------------------------------------------------------------------------
    Hidden [Int] ChangeQuery(
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
    Hidden [Bool] ChangePackages(
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
                Start-Process PowerShell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Find-Module -Name $($ChangePckg[$LoopIdx_Pckg]) | Install-Module -Scope AllUsers -Verbose -Force"
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                Break
            }
            "Uninstall" {
                Start-Process PowerShell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Uninstall-Module -Name $($ChangePckg[$LoopIdx_Pckg]) -Verbose -Force" 
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
    Hidden [Void] ImportPackage(
        [System.String] $Package
    )
    {
        Import-Module -Name $Package -Verbose:($True)
    }
    
    Hidden [Void] RemovePackage(
        [System.String] $Package
    )
    {
        $LoadedModule = Get-Module;
        If ($LoadedModule | Where-Object { $_.Name -match $Package}) {
            Remove-Module -Name $Package -Force:($True) -Verbose:($True)
        }
    }

    #---------------------------------------------------------------------------
    #   ManageGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [Void] ManageGroupProfiles(
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
    }

    #---------------------------------------------------------------------------
    #   ReadGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Xml.XmlDocument] ReadGroupProfiles() 
    {
        # Read the profile config file
        Return ([System.Xml.XmlDocument] (Get-Content -Path $This.FilePathGroupProfiles))
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfileFromFile
    #---------------------------------------------------------------------------
    Hidden [Void] GetGroupProfileFromFile()
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
            $This.RecursiveRequiredPackages($GroupProfileXml, $Array, $_)

            # Add the profile groups to the hashtable
            ForEach ($Loop_SubItem in (Select-Xml -Xml $_ -XPath ".//Profile").Node) 
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

        $This.PackagesRaw = (Select-Xml -Xml $GroupProfileXml -XPath "//Package").Node
    }

    #---------------------------------------------------------------------------
    #   RecursiveRequiredPackages
    #---------------------------------------------------------------------------
    Hidden [Void] RecursiveRequiredPackages(
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
                    $This.RecursiveRequiredPackages($GroupProfileXml, $Array, $__2)
                }
            }
        }
    }
}
