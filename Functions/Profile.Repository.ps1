# ==============================================================================
#   Profile.Repository.ps1 -----------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:RepositoryFile = $Null
$Env:RepositoryFileBackUp = $Null

#   Class ----------------------------------------------------------------------
# ------------------------------------------------------------------------------
Class ValidateRepositoryAlias : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((Get-Repository -Unformated | Select-Object -ExpandProperty alias) + "")
    }
}


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
        [ValidateSet([ValidateRepositoryAlias])]
        [Parameter(Position=1)]
        [System.String] $Name,

        [Parameter()]
        [Switch] $Fork
    )

    Process {

        $property = "GitHub"
        if ($Fork) {
            $property = "Fork"
        }
        $selection = Select-Repository $Name $property

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
function Get-ActiveRepositoryCollection {
    
    [CmdletBinding()]
    
    [OutputType([Boolean])]

    Param (

        [Parameter()]
        [Switch] $Name
    )

    Process {

        if ( $Env:PSPROFILE_REPOSITORY_COLLECTION) { 
            if ($Name) {
                return $Env:PSPROFILE_REPOSITORY_COLLECTION
            }
            else{
                return $True
            }

        }
        else { 
            return $False
        }
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-RepositoryCollection {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidatePSModuleAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,
       
        [Parameter()]
        [Switch] $Silent
    )

    Process {  

        if (-not ($Script:RepositoryFile -eq  $Env:RepositoryFileBackUp)){
            Stop-RepositoryCollection
        }

        $repositorySpecies = Select-Repository $Name Repository
        if (-not ($repositorySpecies -eq "Collection")){
            Write-FormatedError -Message "User specification is not a collection of repositories."
            return Get-Repository
        }

        $repositoryFile = Select-Repository $Name Repository-Config-File
        if ($repositoryFile -and (Test-Path -Path $repositoryFile)) {
            [System.Environment]::SetEnvironmentVariable("PSPROFILE_REPOSITORY_COLLECTION", (Select-Repository $Name Alias), "process")

            $Script:RepositoryFile = $repositoryFile
            $Script:ProjectFiles += @{Path=$repositoryFile; Tag=$Name}

            if (-not $Silent){
                Write-FormatedSuccess -Message "Activated repository collection '$Name'." -Space

                return Get-Repository
            }
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

    Param (

        [Parameter()]
        [Switch] $Silent
    
    )

    Process {
        if (Get-ActiveRepositoryCollection) {
            $Script:ProjectFiles = $Script:ProjectFiles | Where-Object {$_.Path  -ne $Script:RepositoryFile}
            $Script:RepositoryFile = $Env:RepositoryFileBackUp
             
            [System.Environment]::SetEnvironmentVariable("PSPROFILE_REPOSITORY_COLLECTION", "", "process")

            if (-not $Silent){
                Write-FormatedSuccess -Message "Deactivated repository collection." -Space
            }
        }
        else {
            Write-FormatedError -Message "There is no repository collection activated." -Space
        }

        return $Null
    }
}
