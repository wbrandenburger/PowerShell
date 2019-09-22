# ===========================================================================
#   Get-Projects.ps1 --------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ConfigurationFile {
    
    <#
    .DESCRIPTION
        Returns the path of a single module project configuration file.
    
    .PARAMETER Type

    .OUTPUTS
        System.String. Path of project configuration file.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param (
        [Parameter(Position=1, HelpMessage="Existing project type.")]
        [System.String] $Type="project"
    )

    Process {

        if ($Type -eq "project") {
            return $SciProfile.ProjectFile 
        } else {
            return Join-Path -Path $SciProfile.ConfigDir -ChildPath "project-$($Type).json"
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function New-ConfigurationFile {

    <#
    .DESCRIPTION
        Returns an object containing projects of all types found in modules project directory.

    .OUTPUTS
        System.String. Path of project configuration file.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param ()

    Process {
        $project_file = Get-ConfigurationFile
        if (Test-Path -Path $project_file) {
            Remove-Item -Path $project_file -Force
        }

        $project_list = @()
        if ($SciProfile.ProjectAlias){       
            $SciProfile.ProjectAlias -split " "  | ForEach-Object {
                $project_content = Get-Content -Path $(Get-ConfigurationFile -Type $_) | ConvertFrom-Json 
                $project_list += $project_content | Select-Object -Property $SciProfile.Format
            }
        }

        $project_json = $(ConvertTo-Json $project_list)
        Out-File -FilePath $project_file -InputObject $project_json
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Set-ProfileProjectList {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param ()

    Process{

        Set-PocsLibrary -Name $SciProfile.ConfigLib -VirtualEnv $SciProfile.VirtualEnv


        if ($SciProfile.ProjectAlias){
            $project_list = $SciProfile.ProjectAlias -split " "
            
            $project_list | ForEach-Object {
                $project_file = Get-ConfigurationFile -Type $_

                If (Test-Path -Path $project_file){
                    Remove-Item -Path $project_file -Force
                }

                Start-Process -Path "papis" -Args "export", "--format", "json", "--out", $project_file, "type:$_", "--all" -WindowStyle "Hidden"
            }

            do {
                $wait = $False
                $project_list | ForEach-Object {
                    if (-not (Test-Path -Path $(Get-ConfigurationFile -Type $_))) {
                        $wait = $True
                    }
                }
                Start-Sleep -Seconds 0.5
            } while ($wait)
        }

        Restore-PocsLibrary
        Restore-VirtualEnv

        New-ConfigurationFile
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ProjectList {

    <#
    .DESCRIPTION
        Returns all entries of each user defined project type.
    
    .PARAMETER Type

    .PARAMETER Unformatted

    .OUTPUTS
        PSCustomObject. All project entries related to specified type.
    #>
    
    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, HelpMessage="Existing project type.")]
        [System.String] $Type="project",

        [Parameter(HelpMessage="Does not return information as readable table.")]
        [Switch] $Unformatted
    )

    Process {
        $project_file = Get-ConfigurationFile -Type $Type
        if ($Type -eq "project" -and -not $(Test-Path -Path $project_file)) {
            New-ConfigurationFile
        }

        $project_list = Get-Content  $project_file | ConvertFrom-Json

        if ($Unformatted) {
            return $project_list
        }
        return Format-Project -Type $Type -Projects $project_list
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Format-Project {
    
    <#
    .DESCRIPTION
        Returns all entries of each user defined project type as formatted table.
    
    .PARAMETER Type

    .PARAMETER Projects
    
    .OUTPUTS
        Format. All project entries as formatted table.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, HelpMessage="Existing project type.")]
        [System.String] $Type="project",

        [Parameter(Position=2, HelpMessage="Project list with all entries of specified project type")]
        [PSCustomObject] $Projects
    )

    Process {

        return $Projects | Format-Table -Property $SciProfile.Format

    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Test-Project {

    <#
    .DESCRIPTION
        Check whether a list of projects contains a entry with specified identifier.
    
    .PARAMETER Name

    .PARAMETER Projects

    .OUTPUTS
        PSCustomObject. Project which contains the specified identifier.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([PSCustomObject])]

    Param (

        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name,

        [Parameter(Position=2, HelpMessage="Project list with all entries of specified project type")]
        [PSCustomObject] $Projects
    )
    
    Process {

        $project = $Projects | Where-Object {$_.Name -eq $Name -or $_.Alias -eq $Name}
        if ($project) {
            return $project
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ProjectType {

    <#
    .DESCRIPTION
        Get project type of specified identifier.
    
    .PARAMETER Name

    .OUTPUTS
        System.String. Project type of specified identifier
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    $project_list = Get-ProjectList -Unformatted
    $project = Test-Project -Name $Name -Projects $project_list

    if ($project) {
        return $project | Select-Object -ExpandProperty "Type"
    }
    else {
        Write-FormattedError -Message "No entry with user specification '$($Name)' was found in project type '$($Type)'." -Module $SciProfile.Name
        return
    }

}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Select-Project {

    <#
    .DESCRIPTION
        Returns a project entry as dictionary for a given.
    
    .PARAMETER Name

    .PARAMETER Property

    .PARAMETER Project

    .OUTPUTS
        PSCustomObject. All project entries as formatted table.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name,

        [Parameter(Position=2, HelpMessage="Property of project entry, which shall be returned.")]
        [System.String] $Property,

        [Parameter(Position=1, HelpMessage="Existing project type.")]
        [System.String] $Type="project"
    )

    Process{ 

        $project_list = Get-ProjectList -Type $Type -Unformatted
        $project = Test-Project -Name $Name -Projects $project_list

        if ($project.($Property)) {
            return  $project | Select-Object -ExpandProperty $Property
        }
        else {
            Write-FormattedError -Message "No property '$($Property)' for user specification '$($Name)' was found in project type '$($Type)'." -Module $SciProfile.Name
            return
        }
    }
}

