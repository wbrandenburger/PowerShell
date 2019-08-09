# ============================================================================
#   Profile.Repository.ps1 ---------------------------------------------------
# ============================================================================

#   settings -----------------------------------------------------------------
# ----------------------------------------------------------------------------
$Script:RepositoryFile = $Null
$Env:RepositoryFileBackUp = $Null

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateRepositoryAlias: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (Get-Project | Where-Object {$_.type -eq "repository"} | Select-Object -ExpandProperty Alias)
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
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

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
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

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Start-RepositoryCollection {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateRepositoryAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,
       
        [Parameter()]
        [Switch] $Silent
    )

    Process {  

        if (-not ($Script:RepositoryFile -eq  $Env:RepositoryFileBackUp)){
            Stop-RepositoryCollection
        }

        $repositorySpecies = Select-Project -Name $Name -Property Repository -Type Repository

        if (-not ($repositorySpecies -eq "Collection")){
            Write-FormatedError -Message "User specification is not a collection of repositories."
            return Get-ProfileProject Repository
        }

        $repositoryFile =  Select-Project -Name $Name -Property Repository-Config-File -Type Repository

        if ($repositoryFile -and (Test-Path -Path $repositoryFile)) {
            [System.Environment]::SetEnvironmentVariable("PSPROFILE_REPOSITORY_COLLECTION", (Select-Project -Name $Name -Property Alias -Type Repository), "process")

            $Script:RepositoryFile = $repositoryFile
            $Script:ProjectFiles += @{Path=$repositoryFile; Tag=$Name}

            if (-not $Silent){
                Write-FormatedSuccess -Message "Activated repository collection '$Name'." -Space

                return Get-ProfileProject Repository
            }
        }
        else{
            Write-FormatedError -Message "Repository collection path does not exist." -Space
        }

        return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
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
