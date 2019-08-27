# ============================================================================
#   Profile-Repository.ps1 ---------------------------------------------------
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
function Get-Repository {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateRepositoryAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter()]
        [Switch] $Fork
    )

    Process{
        
        $repositorySpecies = Select-Project -Name $Name -Property Repository -Type Repository

        if ($repositorySpecies -eq "Collection"){
            Write-FormatedError -Message "User specification is a collection of repositories, which does not contain a url for a single repository."
            return Get-ProfileProject Repository
        }

        $property = "GitHub"
        if ($type -eq "Repository"){
            if ($Fork) {
                $property = "Fork"
            }
        }
       
        $selection =  Select-Project -Name $Name -Property $property -Type Repository
 
        if ($selection) { return $selection }
        else {
            Write-FormatedError -Message "No valid repository was found."
            return Get-ProfileProject
        }
    }

}