# ==============================================================================
#   Profile.Projects.ps1 -------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:ProjectFile = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-ProjectConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File
    )

    $Script:ProjectFile = $File
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Project {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        [Parameter()]
        [Switch] $Unformated
    )

    $content = Get-Content $Script:ProjectFile | ConvertFrom-Json
    if ($Unformated) {
        return $content
    }
    
    return  $content | Format-Table -Property Name, Path, Description
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Project {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Project,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Name
    )
    
    if (-not ($Project.Name -contains $Name)) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $False
    }

    return $True
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-LocationProject {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    $projects = Get-Project -Unformated

    if (-not (Test-Project -Project $projects -Name $Name)) {
        return $projects | Format-Table -Property Name, Path, Description
    }

    $project = $projects | Where-Object -Property Name -EQ -Value $Name
    $localDir = $project| Select-Object -ExpandProperty "path"
    
    if (Test-Path -Path $localDir) { Set-Location -Path  $localDir }
    else { 
        Write-FormatedError -Message "Path of project is not valid."
        return $projects | Format-Table -Property Name, Path, Description
    }

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-ProjectVSCode {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    $projects = Get-Project -Unformated

    if (-not (Test-Project -Project $projects -Name $Name)) {
        return $projects | Format-Table -Property Name, Path, Description
    }

    $project = $projects | Where-Object -Property Name -EQ -Value $Name
    $localDir = $project| Select-Object -ExpandProperty "path"
    
    if (Test-Path -Path $localDir) { . code $localDir  }
    else { 
        Write-FormatedError -Message "Path of project is not valid."
        return $projects | Format-Table -Property Name, Path, Description
    }
}
