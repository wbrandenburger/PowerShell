# ==============================================================================
#   Profile.Repository.ps1 -----------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:RepositoryFile = $Null
$Script:RepositoryPSModulePath = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-RepositoryConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File
    )

    Process {

        $Script:RepositoryFile = $File

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Repository {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        [Parameter()]
        [Switch] $Unformated
    )

    Process {

        $data = Get-Content $Script:RepositoryFile | ConvertFrom-Json
        if ($Unformated) {
            return $data
        }
        
        return Format-Repository $data
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Format-Repository {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias @{ Label="Fork"; Expression = {if($_.Fork){$True}else{$Null} }}, Path, GitHub

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Repository {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $data,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Name
    )
    
    Process {

        if (($data.Alias -contains $Name) -or (($data.Name -contains $Name))) {
            return $True
        }

        return $False
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Select-Repository {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property
    )

    Process{ 

        $data = Get-Repository -Unformated
        if (-not (Test-Repository $data $Name)) {
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
function Start-RepositoryWeb {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Name
    )

    $selection = Select-Repository $Name GitHub

    if ($selection) { Start-Process -FilePath $selection }
    else { 
        Write-FormatedError -Message "No valid url was found."
        return Get-Repository
    }

    return $Null
}
