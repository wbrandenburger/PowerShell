# ==============================================================================
#   Profile.Projects.ps1 -------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:ProjectConfigFile = $Null
$Script:ProjectFiles = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-ProjectConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File,

        [Parameter(Position=2, Mandatory=$True)]
        [PSCustomObject[]] $Files
    )

    $Script:ProjectConfigFile = $File
    $SCript:ProjectFiles = $Files
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Project {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param (

        [Parameter()]
        [Switch] $Unformated
    )

    Process {

        $data = @()
        $Script:ProjectFiles | ForEach-Object{
            $fileData = Get-Content $_.Path | ConvertFrom-Json
            $fileData | Add-Member -MemberType NoteProperty -Name "Tag" -Value $_.Tag
            $data += $fileData | Select-Object -Property Name, Alias, Tag, Path, Description
        }

        Out-File -FilePath $Script:ProjectConfigFile -InputObject (ConvertTo-Json $data)

        if ($Unformated) {
            return $data
        }

        return Format-Project $data
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Format-Project {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias, Tag, Description, Path

    }
}


#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Select-Project {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property
    )

    Process{ 

        $data = Get-Project -Unformated
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-ChildItemProject {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1)]
        [System.String] $Name,

        [Parameter()]
        [Switch] $All
    )

    Process{ 
        
        if ($All){
            return Get-Project
        }
        
        $selection = Select-Project $Name Path

        if ($selection -and (Test-Path -Path $selection)) { 
            Get-ChildItem -Path $selection 
        }
        else { 
            Write-FormatedError -Message "Path of project is not valid."
            return Get-Project
        }

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-LocationProject {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process{ 

        $selection = Select-Project $Name Path

        if ($selection -and (Test-Path -Path $selection)) { 
            Set-Location -Path $selection 
        }
        else { 
            Write-FormatedError -Message "Path of project is not valid."
            return Get-Project
        }

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-ProjectVSCode {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Name
    )

    $selection = Select-Project $Name Path
    
    if ($selection -and (Test-Path -Path $selection)) { 
        code $selection 
    }
    else { 
        Write-FormatedError -Message "Path of project is not valid."
        return Get-Project
    }
    
    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-ProjectExplorer {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1)]
        [System.String] $Name
    )

    $selection = Select-Project $Name Path
    
    if ($selection -and (Test-Path -Path $selection)) { 
        explorer $selection 
    }
    else { 
        Write-FormatedError -Message "Path of project is not valid."
        return Get-Project
    }
    
    return $Null
}
