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

# @ToDo Choco Install - Add copy Tab-Completion folder

# @ToDo TestPath and create Folder
    # If(Test-Path -Path $PathVcPkg ) {
    #     Write-Verbose "Path $PathVcPkg exists." 
    # }
    # Else {
    #     Write-Verbose "Path $PathVcPkg does not exists."
        
    #     # New-Item -Path  $env:Repositories -Name $VcPkg -ItemType Directory
    #     # If(Test-Path -Path $PathVcPkg ) {
    #     #     Write-Verbose "Directory $PathVcPkg created." 
    #     # }
    # }

#-------------------------------------------------------------------------------
#   Update-PSSession
#-------------------------------------------------------------------------------
Function Update-PSSession
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None")]
    Param
    (
    )

    If ($PSCmdlet.ShouldProcess("Refresh environment and start a new powershell session?")) {
        Start-Process -FilePath RefreshEnv.cmd -Wait -NoNewWindow

        Start-Process -FilePath PowerShell.exe -Wait -NoNewWindow
    }
}

# #-------------------------------------------------------------------------------
# #   Start-Profile 
# #-------------------------------------------------------------------------------
# Function Open-Profile 
# {

#     Param
#     (
#     )
        
#     Start-Process -FilePath $PSPackages.GetFilePathProfile()
# }

#-------------------------------------------------------------------------------
#   Open-ProfileXml
#-------------------------------------------------------------------------------
Function Open-ProfileXml
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param
    (
    )

    Start-Process FilePath $PSPackages.GetFilePathGroupProfiles() -NoNewWindow
}

#-------------------------------------------------------------------------------
#   Set-Environment
#-------------------------------------------------------------------------------
Function Set-Environment
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None", PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param
    (
    )

    If ($PSCmdlet.ShouldProcess("Should environment variables get changed?")){
    . "$Env:LOCAL_PS\Environment.ps1"
    }
}

#-------------------------------------------------------------------------------
#   New-PSFunction
#-------------------------------------------------------------------------------
Function New-PSFunction
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None",PositionalBinding=$True)]

    [OutputType([Void])]

    Param
    (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Name of file, which contains a powershell cmdlet")]
        [Alias("i")]
        [System.String] $Name
    )

    Process {
        $LocalPSFunctionFullPath = (Join-Path -Path $Env:LOCAL_PS -ChildPath "Templates\PSFunction.ps1")
        $NewPSFunctionFullPath = (Join-Path -Path $Env:LOCAL_PS -ChildPath "$Name.ps1")
        Copy-Item -Path $LocalPSFunctionFullPath -Destination $NewPSFunctionFullPath -Verbose -Force

        Start-Process -FilePath "$NewPSFunctionFullPath" -NoNewWindow
    }
}

#-------------------------------------------------------------------------------
#   Open-VSProject
#-------------------------------------------------------------------------------
Function Open-VSProject
{
    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param
    (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Path, which contains a project folder")]
        [Alias("i")]
        [System.String[]] $Path
    )

    Process {
        If ($Path.Length -le 1) {
            Start-Process -FilePath Code -ArgumentList "--new-window  $Path" -NoNewWindow
        }
# @ToDo Opening Multirootfolders --add <dir>
    }
}

#-------------------------------------------------------------------------------
#   New-DocFile
#-------------------------------------------------------------------------------
Function New-DocFile
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None",PositionalBinding=$True)]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Name of file, which contains a documentation file")]
        [Alias("i")]
        [System.String] $Name,

        [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Additional creation of a folder containing supplementary files")]
        [Switch] $Supplements,

        [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Additional creation of a tempory file for working in multiple desktops")]
        [Switch] $Temp
    )

    Process {
        $LocalDocFilePath =     (Join-Path -Path $Env:LOCAL_PS -ChildPath "Templates\DocFile.md")
        $NewDocFolderPath =     (Join-Path -Path $Env:SHARED_BIB -ChildPath "Doc\$Name")
        $NewDocFilePath =       (Join-Path -Path $Env:SHARED_BIB -ChildPath "Doc\$Name.md")
        $NewDocFileTmpPath =    (Join-Path -Path $Env:SHARED_BIB -ChildPath "Doc\$Name.tmp.md")

        If (Test-Path -Path $NewDocFilePath ) {
            Write-Warning "File $NewDocFilePath exists in destination, skip copying template."
        }
        Else {
            Copy-Item -Path $LocalDocFilePath -Destination $NewDocFilePath -Verbose
            Write-Host "File $NewDocFilePath created." -ForegroundColor Green
        }

        If ($Supplements) {
            New-Item -Path $NewDocFolderPath -ItemType "Directory"
        }
        
        If ($Temp) {
            New-Item -Path $NewDocFileTmpPath -Verbose
        }

        Start-Process -FilePath "$NewDocFilePath"
    }
}



#-------------------------------------------------------------------------------
#   Update-PSGit
#-------------------------------------------------------------------------------
Function Update-PSGit
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None",PositionalBinding=$True)]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Name of file, which contains a documentation file")]
        [Alias("m")]
        [System.String] $Message 
    )

    Process {
        If ($PSCmdlet.ShouldProcess("Push changes of local powershell workspace to remote repository?")) {
            Start-Process -FilePath sh.exe -ArgumentList "GitAddCommitPush.sh $Env:LOCAL_PS $Message" -Wait -NoNewWindow
        }
    }

}

#-------------------------------------------------------------------------------
#   PackageUpdater()
#-------------------------------------------------------------------------------
Function PackageUpdater
{
    . (Join-Path $PSPackages.GetPathLocal() "PackageBasics.ps1")
}

#---------------------------------------------------------------------------
#   Import-Package
#---------------------------------------------------------------------------
Function Import-Package
{
        [CmdletBinding()]
    
        [OutputType([Void])]
        
        Param
        (
            [Parameter(HelpMessage="Task Import")]
            [Switch] $Import,
            [Parameter(HelpMessage="Task Remove")]
            [Switch] $Remove,
            [Parameter(HelpMessage="Task Import-Group")]
            [Switch] $ImportGroup,
            [Parameter(HelpMessage="Task Remove-Group")]
            [Switch] $RemoveGroup,
            [Parameter(HelpMessage="Task Install")]
            [Switch] $Install,
            [Parameter(HelpMessage="Task Update")]
            [Switch] $Update,
            [Parameter(HelpMessage="Task Uninstall")]
            [Switch] $Uninstall
        )

        

        If ($Import) {$Task = "Import"; $Install = $False}
        If ($Remove) {$Task ="Remove"; $Install = $False}
        If ($ImportGroup) {$Task ="Import-Group"; $Install = $False}
        If ($RemoveGroup) {$Task ="Remove-Group"; $Install = $False}
        If ($Install) {$Task ="Install"; $Install = $True}        
        If ($Update) {$Task ="Update"; $Install = $True}
        If ($Uninstall) {$Task ="Uninstall"; $Install = $True}
     
        Show-Package -Install:($Install)

        $PSPackages.PackageManager($Task, $VerbosePreference)

        Show-Package -Install:($Install)
}

#---------------------------------------------------------------------------
#   Import-PackageCLI
#---------------------------------------------------------------------------
Function Import-PackageCLI
{
        [CmdletBinding(PositionalBinding=$True)]
    
        [OutputType([Void])]
        
        Param
        (            
            [Parameter(Position=1, Mandatory=$True, HelpMessage="Name of Package which should be get imported, removed, installed,...")]
            [System.String] $Package,

            [Parameter(Position=2, Mandatory=$True, HelpMessage="Task, which should be performed")]
            [System.String] $Task
        )

        $PSPackages.PackageManagerCLI($Package, $Task, $VerbosePreference)

        Show-Package
}
#---------------------------------------------------------------------------
#   Import-PSScriptAnalyzer 
#---------------------------------------------------------------------------
Function Import-PSScriptAnalyzer 
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
    )

    $PSScriptAnalyzer = "PSScriptAnalyzer"
    If (Get-Module | Where-Object { $_.Name -match $PSScriptAnalyzer}) {
        Remove-Module -Name $PSScriptAnalyzer -Force:($True) -Verbose:($VerbosePreference)
    }
    Import-Module $PSScriptAnalyzer
}
#---------------------------------------------------------------------------
#   Show-PackageProfile
#---------------------------------------------------------------------------
Function Show-PackageProfile
{
    [CmdletBinding()]

    [OutputType([System.Object])]

    Param(
    )

    Return $PSPackages.GroupProfiles | Format-Table
}

#---------------------------------------------------------------------------
#   Add-Package
#---------------------------------------------------------------------------
Function Add-Package
{    
    [CmdletBinding()]

    [OutputType([System.Object])]
    
    Param
    (
        [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True,HelpMessage="String which determines the searched package")]
        [System.String] $Package
    )
    
    Return Get-Content $PSPackages.FindPackage($Package)
}

#---------------------------------------------------------------------------
#   Show-Package
#---------------------------------------------------------------------------
Function Show-Package
{
    [CmdletBinding()]
    
    [OutputType([System.Object])]

    Param(
        [Parameter(HelpMessage="Switch, which determnines whether installed packages should get checked")]
        [Switch] $Install = $False
    )

    If ($Install) {
        $PSPackages.GetPackagesInstalled()
    }
    Else {
        $PSPackages.GetPackagesImported()
    }

    Return $PSPackages.Packages | Format-Table @{
        Label = "Task"
        Expression = {$_.ColoredTask}}, Version, @{
        Label = "Name"
        Expression = {$_.ColoredName}}, Repository, Description
}

#---------------------------------------------------------------------------
#   Show-PackageTask
#--------------------------------------------------------------------------
Function Show-PackageTask
{
    [CmdletBinding()]

    [OutputType([System.Object])]

    Param(
    )

    Return $PSPackages.PackageTasks | ForEach-Object{[PSCustomObject]@{
        Task = $_
    }}
}

#-------------------------------------------------------------------------------
#   Prompt
#-------------------------------------------------------------------------------
Function Prompt 
{
    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    $CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    If ($PSPackages.ExistsImportedGroupProfiles()){
        Write-Host "($($PSPackages.GetImportedGroupProfiles())) " -NoNewline -ForegroundColor Yellow
    }
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

#------------------------------------------------------------------------------
#   Test-Verb
#------------------------------------------------------------------------------
Function Test-Verb
{
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]
    
    Param
    (
        [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True,HelpMessage="Verb which will be tested being a member of approved PowerShell verbs")]
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

# @ToDo: Outsourcing Profile a own class and provide Cmdlets
# @ToDo: Avoid invoking Get-InstalledModules with initialization
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

        $This.GetGroupProfileFromFile()

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
    #   Get-FilePathProfile
    #---------------------------------------------------------------------------
    Hidden [System.String] GetFilePathProfile()
    {
        Return $This.FilePathProfile
    }

    #---------------------------------------------------------------------------
    #   Get-FilePathGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.String] GetFilePathGroupProfiles()
    {
        Return $This.FilePathGroupProfiles
    }

    #---------------------------------------------------------------------------
    #   Update
    #---------------------------------------------------------------------------
    Hidden [Void] New()
    {
        $This.GetGroupProfileFromFile()
    }  

    #---------------------------------------------------------------------------
    #   ShowRaw
    #---------------------------------------------------------------------------
    [System.Object] ShowRaw() 
    {
        Return $This.PackagesRaw | Format-Table 
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfilesPackages(
        [System.String[]] $GroupProfiles) 
    {
        # Return a profile list
        Return ($GroupProfiles | ForEach-Object { $GroupProfile = $_; $This.GroupProfiles | Where-Object {$_.GroupProfile -contains $GroupProfile}}).Packages | Sort-Object -Unique | ForEach-Object {[PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfiles() 
    {
        # Return a profile list
        Return $This.GroupProfiles | Select-Object -Property GroupProfile | Sort-Object
    }

    #---------------------------------------------------------------------------
    #   GetGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [System.Object] GetGroupProfilesPackages() 
    {
        # Return a profile list
        Return $This.GroupProfiles.Packages | Sort-Object -Unique | ForEach-Object {
            [PSCustomObject] @{ Packages = $_ }}
    }

    #---------------------------------------------------------------------------
    #   FindPackage
    #---------------------------------------------------------------------------
    Hidden [System.String] WritePackageFromFindModule(
        [System.String] $PackageName
    )
    {
        $Package = Find-Module -Name $PackageName

        $FilePath = "$($This.PathConfig)\Package.$PackageName.txt" 

        If ($Package -ne $Null ) {
        Out-File -FilePath  $FilePath -InputObject ($Package | Select-Object -Property Name, Author, Version, PublishedDate, Repository, Description)
        }

        Return  $FilePath
    }
    #---------------------------------------------------------------------------
    #   FindPackage
    #---------------------------------------------------------------------------
    [Void] FindPackage()
    {
        $This.Packages | Where-Object {$_.Repository -match "PSGallery" } | ForEach-Object { $This.WritePackageFromFindModule( $_.Name ) }
    }

    #---------------------------------------------------------------------------
    #   FindPackage
    #---------------------------------------------------------------------------
    [System.String]  FindPackage($PackageName)
    {
        Return $This.WritePackageFromFindModule($PackageName)
    }

# @ToDo: Virtual Terminal Sequences - Outsourcing in own class ->UPDATE: Copi in PSColorization
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
    #  GetPathLocal()
    #---------------------------------------------------------------------------
    [System.String] GetPathLocal()
    {
        Return $This.PathLocal
    }

    #---------------------------------------------------------------------------
    #  GetPathConfig()
    #---------------------------------------------------------------------------
    [System.String] GetPathConfig()
    {
        Return $This.PathConfig;
    }
    #---------------------------------------------------------------------------
    #  GetPackageStatus()
    #---------------------------------------------------------------------------
    Hidden [Void] GetPackagesInstalled()  
    {
        # Get installed Module
        $PckgsInst = Get-InstalledModule
        $PckgsImport = Get-Module

        # Loop through all elements with the defined tag
        $This.Packages =  $This.PackagesRaw | Where-Object { $_.Deactivated -match "false"} | ForEach-Object {
                $Name = $_.Name; $Task = $Null; $Color = 0;
                $Version = ($PckgsInst | Where-Object {$_.Name -eq $Name}).Version

                If ( $PckgsInst.Name -contains $_.Name) {
                    If ( -not ($Version -eq $_.Version)){
                        $Task = "Update";  $Color = 36
                    }
                }
                ElseIf ($_.Repository -match "PSGallery" ) {
                    $Task = "Install"; $Color = 31;}

                $ColoredTask = $This.GetVTSequence($Task, $Color)
                
                If ($PckgsImport.Name -contains $_.Name) {
                    $Color = 32;}

                $ColoredName = $This.GetVTSequence($_.Name, $Color)

                [PSCustomObject]@{
                    Name = $_.Name; Version = $Version; Task = $Task
                    Session = ($PckgsImport.Name -contains $_.Name)
                    ColoredTask = $ColoredTask 
                    ColoredName = $ColoredName
                    Repository = $_.Repository; Description = $_.Description
                }
            }
    }

    #---------------------------------------------------------------------------
    #  GetPackageStatus()
    #---------------------------------------------------------------------------
    Hidden [Void] GetPackagesImported()  
    {
        # Get installed Module
        $PckgsImport = Get-Module

        # Loop through all elements with the defined tag
        $This.Packages =  $This.PackagesRaw | Where-Object { $_.Deactivated -match "false"} | ForEach-Object {
                $Name = $_.Name; $Task = $Null; $Color = 0;
                $Version = ($PckgsInst | Where-Object {$_.Name -eq $Name}).Version

                If ($PckgsImport.Name -contains $_.Name) {
                    $Color = 32;}

                $ColoredName = $This.GetVTSequence($_.Name, $Color)

                [PSCustomObject]@{
                    Name = $_.Name; Version = $Version; Task = $Task
                    Session = ($PckgsImport.Name -contains $_.Name)
                    ColoredTask = $ColoredTask 
                    ColoredName = $ColoredName
                    Repository = $_.Repository; Description = $_.Description
                }
            }
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [Void] PackageManagerCLI(
        [System.String] $Value,    
        [System.String] $Task,
        [Bool] $Verbose
        )
    {
        $Object = New-Object PSCustomObject
        Switch ($Task) {
            "Install" {
                $This.GetPackagesInstalled()
                $Object = ($This.Packages | Where-Object {$_.Task -match $Task}).Name
            }
            "Uninstall" {
                $This.GetPackagesInstalled()
                $Object = ($This.Packages | Where-Object {$_.Repository -match "PSGallery"}).Name
            }
            "Update" {
                $This.GetPackagesInstalled()
                $Object = ($This.Packages | Where-Object {$_.Task -match $Task}).Name
            }                     
            "Import" {
                $This.GetPackagesImported()
                $Object = $This.Packages.Name
            }
            "Remove" {
                $This.GetPackagesImported()
                $Object = $This.Packages.Name
            }
            "Import-Group" {
                $This.GetPackagesImported()
                $Object = $This.GroupProfiles.GroupProfile
            }
            "Remove-Group" {
                $This.GetPackagesImported()
                $Object = $This.GroupProfiles.GroupProfile
            }
        }
        
        $Options = $This.GetArrayList($Object)
        $This.ChangePackages($Options.IndexOf($Value), $Options, $Task, $Verbose)
    }

    #---------------------------------------------------------------------------
    #   PackageManager
    #---------------------------------------------------------------------------
    [Void] PackageManager(
        [System.String] $Task,
        [Bool] $Verbose) 
    {
        $Question = ""; $Object = New-Object PSCustomObject
        Switch ($Task) {
            "Install" {
                $This.GetPackagesInstalled()
                $Question = "Which packages should be get installed?"
                $Object = ($This.Packages | Where-Object {$_.Task -match $Task}).Name
            }
            "Uninstall" {
                $This.GetPackagesInstalled()
                $Question = "Which packages should be get uninstalled?"
                $Object = ($This.Packages | Where-Object {$_.Repository -match "PSGallery"}).Name
            }
            "Update" {
                $This.GetPackagesInstalled()
                $Question = "Which packages should be get updated?"
                $Object = ($This.Packages | Where-Object {$_.Task -match $Task}).Name
            }                     
            "Import" {
                $This.GetPackagesImported()
                $Question = "Which packages should be get imported?"
                $Object = $This.Packages.Name
            }
            "Remove" {
                $This.GetPackagesImported()
                $Question = "Which packages should be get removed?"
                $Object = $This.Packages.Name
            }
            "Import-Group" {
                $This.GetPackagesImported()
                $Question = "Which group profile should be get imported?"
                $Object = $This.GroupProfiles.GroupProfile
            }
            "Remove-Group" {
                $This.GetPackagesImported()
                $Question = "Which group profile should be get removed?"
                $Object = $This.GroupProfiles.GroupProfile
            }
            Default {
                Write-Warning "Task $Task is not valid."        
            }
        }
        $This.ChangeManager( $Task, $Question, $This.GetArrayList( $Object), $Verbose)
    }

    #---------------------------------------------------------------------------
    #   GetPackagesInstall
    #---------------------------------------------------------------------------
    Hidden [System.Collections.ArrayList] GetArrayList(
        [System.Object] $Object
    )
    {   $Array = [System.Collections.ArrayList]::New();
        If ($Object.Count -gt 0) {$Object | ForEach-Object { [Void] $Array.Add( $_ ) }}
        
        Return $Array
    }

    #---------------------------------------------------------------------------
    #   ExistsImportedGroupProfiles
    #--------------------------------------------------------------------------- 
    [Bool] ExistsImportedGroupProfiles()
    {   
        $Bool_Out = $False
        If ($This.GroupProfiles.Imported -contains $True) {
            $Bool_Out = $True
        }   
        
        Return $Bool_Out
    } 

    #---------------------------------------------------------------------------
    #   GetImportedGroupProfiles
    #--------------------------------------------------------------------------- 
    [System.String] GetImportedGroupProfiles()
    {   
        Return ($This.GroupProfiles | Where-Object {$_.Imported -match "True"}).GroupProfile 
    } 

    #---------------------------------------------------------------------------
    #   ChangeManager
    #---------------------------------------------------------------------------
    Hidden [Void] ChangeManager(
        [System.String] $Task,
        [System.String] $Question,
        [System.Collections.ArrayList] $Options,
        [Bool] $Verbose
    )
    {
        If ($Options.Count -gt 0 )
        {
            $Abort = $True
            Do {
                $Abort = $This.ChangePackages(
                    $This.ChangeQuery($Question,$Options),
                    $Options, 
                    $Task,
                    $Verbose)
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
        [System.String] $Task,
        [Bool] $Verbose
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
                Start-Process PowerShell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Find-Module -Name $($ChangePckg[$LoopIdx_Pckg]) | Install-Module -Scope AllUsers -AllowClobber -Verbose -Force"
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                $This.GetPackagesInstalled()
                Break
            }
            "Uninstall" {
                Start-Process PowerShell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command Uninstall-Module -Name $($ChangePckg[$LoopIdx_Pckg]) -Verbose -Force" 
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                $This.GetPackagesInstalled()
                Break
            }
            "Update" { 
                Update-Module $ChangePckg[$LoopIdx_Pckg]
                Break
                $Options.Remove($ChangePckg[$LoopIdx_Pckg])
                $This.GetPackagesInstalled()
            }
            "Import" {
                $This.ImportPackage($ChangePckg[$LoopIdx_Pckg],$Verbose)
                $This.GetPackagesImported()
                Break
            }
            "Remove" {
                $This.RemovePackage($ChangePckg[$LoopIdx_Pckg],$Verbose)
                $This.GetPackagesImported()
                Break
            } 
            "Import-Group" {
                $This.ManageGroupProfiles("Import", $ChangePckg[$LoopIdx_Pckg],$Verbose)
                ($This.GroupProfiles | Where-Object  {$_.GroupProfile -match $ChangePckg[$LoopIdx_Pckg]}).Imported = $True
                $This.GetPackagesImported()
                Break
            }
            "Remove-Group" {
                $This.ManageGroupProfiles("Remove", $ChangePckg[$LoopIdx_Pckg],$Verbose)
                ($This.GroupProfiles | Where-Object {$_.GroupProfile -match $ChangePckg[$LoopIdx_Pckg]}).Imported = $False
                $This.GetPackagesImported()
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
        [System.String] $Package,
        [Bool] $Verbose
    )
    {
        Import-Module -Name $Package -Verbose:($Verbose)
    }
    
    Hidden [Void] RemovePackage(
        [System.String] $Package,
        [Bool] $Verbose
    )
    {
        $LoadedModule = Get-Module;
        If ($LoadedModule | Where-Object { $_.Name -match $Package}) {
            Remove-Module -Name $Package -Force:($True) -Verbose:($Verbose)
        }
    }

    #---------------------------------------------------------------------------
    #   ManageGroupProfiles
    #---------------------------------------------------------------------------
    Hidden [Void] ManageGroupProfiles(
        [System.String] $Task,
        [System.String[]] $GroupProfiles,
        [Bool] $Verbose
    )
    {
        $GroupProfilesPackages = $This.GetGroupProfilesPackages($GroupProfiles).Packages

        # Loop through all elements with the defined tag
        ForEach ($Lop_Packages in $GroupProfilesPackages)
        {
            $This.RemovePackage($Lop_Packages, $Verbose)

            If ($Task -match "Import") {
                $This.ImportPackage($Lop_Packages, $Verbose)
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
            ForEach ($Loop_SubItem in (Select-Xml -Xml $_ -XPath ".//GroupProfile").Node) 
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
                                Imported = $False
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

# =============================================================================
#    Define Global Variables
# =============================================================================

# @ToDo Add PSCommandLine to ProfilePackages.Xml

# @ToDo Open recently used file with Papis YES Open-Profile especially - deprecated
    $PSCommandLine = "PSCommandLine"
    If (Get-Module | Where-Object { $_.Name -match $PSCommandLine}) {
        Remove-Module -Name $PSCommandLine -Force:($True) -Verbose:($True)
    }
    Import-Module $PSCommandLine 

    # Initialize object of class profile
    $PSPackages = [Profile]::New($PSScriptRoot)

    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    $CheckAs = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    
    $Package = "Usability"
    If ($CheckAs){
        $Package = "SoftwareManagement"    
    }
    Import-PackageCLI -Package $Package -Task "Import-Group" # -Verbose

    # Clear Variables