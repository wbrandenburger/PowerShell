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

    Process {

        $data = Get-Content $Script:ProjectFile | ConvertFrom-Json
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

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias, Description, Path

    }
}


#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Project {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
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

    Param(
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
function Set-LocationProject {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
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

    Param(
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



