# ==============================================================================
#   Profile.Repository.ps1 -----------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:RepositoryFile = $Null
$Env:RepositoryFileBackUp = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-RepositoryConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File
    )

    Process {

        $Script:RepositoryFile = $File
        $Env:RepositoryFileBackUp = $File
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Repository {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param (
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

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias, @{ Label="Fork"; Expression = {if($_.Fork){$True}else{$Null} }}, Path, @{ Label="GitHub"; Expression = {if($_.repository -eq "Collection"){"Collection"} else {$_.Github} }}

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Repository {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param (
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

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property
    )

    Process { 

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

    Param (
        [Parameter(Position=1)]
        [System.String] $Name
    )

    Process {

        $selection = Select-Repository $Name GitHub

        if ($selection) { Start-Process -FilePath $selection }
        else { 
            Write-FormatedError -Message "No valid url was found."
            return Get-Repository
        }

        return $Null

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-RepositoryCollection {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process {  

        if (-not ($Script:RepositoryFile -eq $Env:RepositoryFileBackUp)){
            Stop-RepositoryCollection
        }

        $repositorySpecies = Select-Repository $Name Repository
        if (-not ($repositorySpecies -eq "Collection")){
            Write-FormatedError -Message "User specification is not a collection of repositories."
            return Get-Repository
        }

        $repositoryFile = Select-Repository $Name Repository-Config-File
        if ($repositoryFile -and (Test-Path -Path $repositoryFile)) {
            $Script:RepositoryFile = $repositoryFile
            $Script:ProjectFiles += @{Path=$repositoryFile; Tag=$Name}

            Write-FormatedSuccess -Message "Activated repository collection '$Name'." -Space

            return Get-Repository
        }
        else{
            Write-FormatedError -Message "Repository collection path does not exist." -Space
        }

        return $Null

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Stop-RepositoryCollection {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param ()

    Process {
        if ($Env:RepositoryFileBackUp) {
            $Script:ProjectFiles = $Script:ProjectFiles | Where-Object {$_.Path  -ne $Script:RepositoryFile}
            $Script:RepositoryFile = $Env:RepositoryFileBackUp
             
            Write-FormatedSuccess -Message "Deactivated repository collection." -Space
        }
        else {
            Write-FormatedError -Message "There is no repository collection activated." -Space
        }
    }
}
