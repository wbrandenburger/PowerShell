# ============================================================================
#   Profile-Projects.ps1 -----------------------------------------------------
# ============================================================================

#   settings -----------------------------------------------------------------
# ----------------------------------------------------------------------------
$Script:ProjectConfigFile = $Null
$Script:ProjectFiles = $Null
$Script:WorkspaceConfigFiles = $Null

#   settings -----------------------------------------------------------------
# ----------------------------------------------------------------------------
$Script:FormatProperty = @{
    "Project" = "Name", "Alias", "Type", "Description", "Folder"
    "Papis" = "Name", "Alias", "Folder", "Description"
    "PSModule" = "Name", "Alias", "Repository", "Folder"
    "Repository" = "Name", "Alias", @{ Label="Fork"; Expression = {if($_.Fork){$True}else{$Null} }}, "Folder", @{ Label="GitHub"; Expression = {if($_.repository -eq "Collection"){"Collection"} else {$_.Github} }}
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateProjectAlias : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((Get-Project | Select-Object -ExpandProperty alias) + "")
    }
}

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateProfileType: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((Get-Project | Select-Object -ExpandProperty type -Unique) + "project")
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-ProjectConfiguration{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File,

        [Parameter(Position=2, Mandatory=$True)]
        [PSCustomObject[]] $Files,

        [Parameter(Position=3, Mandatory=$True)]
        [PSCustomObject] $Workspace

    )

    $Script:ProjectConfigFile = $File
    $SCript:ProjectFiles = $Files
    $Script:WorkspaceFile = $Workspace
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-Project {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param (

        [Parameter(Position=1)]
        [System.String] $Name="Project"

    )

    Process {

        if ($Name -eq "Project") {
            $data = @()
            $Script:ProjectFiles | ForEach-Object{
                $fileData = Get-Content $_ | ConvertFrom-Json
                $data += $fileData | Select-Object -Property $Script:FormatProperty.Project
            }

            Out-File -FilePath $Script:ProjectConfigFile -InputObject (ConvertTo-Json $data)
        }
        else {
            switch ($Name){
                "Papis" {
                    $data = Get-Content $Script:PapisFile | ConvertFrom-Json
                    break
                }
                "PSModule" {
                    $data = Get-Content $Script:ModuleFile | ConvertFrom-Json
                    break
                }
                "Repository" {
                    $data = Get-Content $Script:RepositoryFile | ConvertFrom-Json
                    break
                }
                "Workspace" {
                    $data = Get-Content $Script:WorkspaceFile | ConvertFrom-Json
                    break
                }
            }
        }

        return $data
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-ProfileProject{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([PSCustomObject])]

    Param (
        
        [ValidateSet([ValidateProfileType])]
        [Parameter(Position=1)]
        [System.String] $Name="Project",

        [Parameter()]
        [Switch] $Unformated
    )

    Process {

        $data = Get-Project -Name $Name

        if ($Unformated) {
            return $data
        }

        return Format-Project $Name $data
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Format-Project {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (

        [ValidateSet([ValidateProfileType])]
        [Parameter(Position=1, Mandatory=$False)]
        [System.String] $Name="Project",

        [Parameter(Position=2, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property $Script:FormatProperty.($Name)

    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Test-Project {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Name
    )
    
    Process {

        if (($Data.Alias -contains $Name) -or (($Data.Name -contains $Name))) {
            return $True
        }

        return $False
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-ProjectType {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    $data = Get-Project
    if (-not (Test-Project $data $Name)) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $Null
    }

    $datum = $data | Where-Object {$_.Name -eq $Name -or $_.Alias -eq $Name}

    if ($datum.Type) {
        return $datum | Select-Object -ExpandProperty Type
    }
    else {
       return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Select-Project {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property,

        [ValidateSet([ValidateProfileType])]
        [Parameter(Position=3)]
        [System.String] $Type="Project"
    )

    Process{ 

        $data = Get-Project $Type
        if (-not (Test-Project $data $Name)) {
            Write-FormatedError -Message "No entry with user specification was found."
            return $Null
        }
    
        $datum = $data | Where-Object {$_.Name -eq $Name -or $_.Alias -eq $Name}

        if ($datum.$Property) {
            $selection = $datum | Select-Object -ExpandProperty $Property
        }
        else {
            $selection = $Null
        }

        return $selection
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-ProjectChildItem {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (

        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Name

    )

    Process{ 
        
        if (-not $Name){
            return Get-ProfileProject
        }

        $selection = Select-Project $Name Folder

        if ($selection){
            $selection | ForEach-Object {
                if (Test-Path -Path $_) {
                    Get-ChildItem -Path $_
                } 
                else { 
                    Write-FormatedError -Message "Path of project is not valid."
                    return Get-ProfileProject
                }
            }
        }
        else { 
            Write-FormatedError -Message "Poperty $Name has no content."
            return Get-ProfileProject
        }

        return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-ProjectLocation {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process{ 

        $selection = Select-Project $Name Folder

        if ($selection){
            $selection | ForEach-Object {
                if (-not (Test-Path -Path $_)) {
                    Write-FormatedError -Message "Path $_ of project is not valid."
                    return Get-ProfileProject
                }
            }

            return $selection
        }
        else { 
            Write-FormatedError -Message "Poperty $Name has no content."
            return Get-ProfileProject
        }

        return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-ProjectLocation {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process{ 

        $selection = Select-Project $Name Folder
 
        if ($selection){
            $selection | ForEach-Object {
                if (Test-Path -Path $_) {
                    Set-Location -Path $_
                    return $Null
                } 
                else { 
                    Write-FormatedError -Message "Path of project is not valid."
                    return Get-ProfileProject
                }
            }
        }
        else { 
            Write-FormatedError -Message "Poperty $Name has no content."
            return Get-ProfileProject
        }

        return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Open-ProjectWorkspace {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Name
    )

    $type = Get-ProjectType $Name

    $selection = Select-Project $Name Folder

    if ($type -eq "Workspace"){
        $workspace = Select-Project -Name $Name -Property Workspace -Type Workspace
    }

    if ($selection){
        if ($workspace){
            
            $selection = $workspace
        }
        else{
            $selection | ForEach-Object {
                if (-not (Test-Path -Path $_)) {
                    Write-FormatedError -Message "Path of project is not valid."
                    return Get-ProfileProject
                }
            }
        }

        code --new-window --disable-gpu $selection
        
    }
    else { 
        Write-FormatedError -Message "Poperty $Name has no content."
        return Get-ProfileProject
    }
    
    return $Null
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Open-ProjectFileExplorer {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Name
    )

    $selection = Select-Project $Name Folder
    
    if ($selection){
        $selection | ForEach-Object {
            if (Test-Path -Path $_) {
                Explorer $_
            } 
            else { 
                Write-FormatedError -Message "Path of project is not valid."
                return Get-ProfileProject
            }
        }
    }
    else { 
        Write-FormatedError -Message "Poperty $Name has no content."
        return Get-ProfileProject
    }
    
    return $Null
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Open-ProjectBrowser {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (

        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Name
    )

    Process {
        
        $type = Get-ProjectType $Name

        if (-not ($type -in @("Repository", "PSModule"))) {
            Write-FormatedError -Message "Project does not have the type for this operation."
            return Get-ProfileProject
        }

        $selection = Select-Project -Name $Name -Property url -Type $type

        if ($selection) { 
            if ($selection.getType().Name -ne "String"){
                $selection = $selection[0]
            }
            Start-Process -FilePath $selection }
        else {
            Write-FormatedError -Message "No valid url was found."
            return Get-ProfileProject
        }

        return $Null

    }
}


#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-PowerShellProfile {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param ()

    Start-PapisLibrary -Name lib-config

    $Script:ProjectFiles  | ForEach-Object {
        If (Test-Path -Path $_){
            Remove-Item -Path $_ -Force
        }
        
        $papisQuery = [System.IO.Path]::GetFileNameWithoutExtension($_)

        $(papis export --format json --out $_ "type:$papisQuery" --all)
        
    }

    Stop-PapisLibrary
}