# ==============================================================================
#   Repository-Tools.ps1 -------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
write-host 
$Script:repositoriesFile = "A:\.config\repositories.json"
$Script:modulePath = "A:\Documents\PowerShell\Modules"

#   aliases --------------------------------------------------------------------
# ------------------------------------------------------------------------------
Set-Alias cdrep -Value Set-LocationRepository
Set-Alias gitrep -Value Start-RepositoryWeb
Set-Alias vsrep -Value Start-RepositoryVSCode

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Repository {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param()

    return Get-Content  $Script:repositoriesFile | ConvertFrom-Json 
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Repository {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Repositories,

        [Parameter()]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    if ($Abb -or $Name) {
        if (($Repositories.Abbreviation -contains $Abb) -or (($Repositories.Name -contains $Name))) {
            return $True
        }
        else {
            return $False
        }
    }

    return $False
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-RepositoryQuery {
    
    [CmdletBinding()]
    
    [OutputType([System.String])]

    Param(

        [Parameter()]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    if ($Abb) { return @{Name = "Abbreviation"; Value = $Abb}}
    if ($Name) { return @{Name = "Name"; Value = $Name}}

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-LocationRepository {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository
    if (-not (Test-Repository -Repositories $repositories -Abb $Abb -Name $Name)) {
        return $repositories | Format-Table
    }

    $repositoryQuery = Get-RepositoryQuery -Abb $Abb -Name $Name


    Set-Location -Path ($repositories | Where-Object -Property $repositoryQuery.Name -EQ  -Value $repositoryQuery.Value | Select-Object -ExpandProperty "Local")

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-LocationRepository {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository
    if (-not (Test-Repository -Repositories $repositories -Abb $Abb -Name $Name)) {
        return $repositories | Format-Table
    }

    $repositoryQuery = Get-RepositoryQuery -Abb $Abb -Name $Name

    Set-Location -Path ($repositories | Where-Object -Property $repositoryQuery.Name -EQ  -Value $repositoryQuery.Value | Select-Object -ExpandProperty "Local")

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-RepositoryWeb {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository
    if (-not (Test-Repository -Repositories $repositories -Abb $Abb -Name $Name)) {
        return $repositories | Format-Table
    }

    $repositoryQuery = Get-RepositoryQuery -Abb $Abb -Name $Name

    Start-Process -FilePath ($repositories | Where-Object -Property $repositoryQuery.Name -EQ  -Value $repositoryQuery.Value | Select-Object -ExpandProperty "github")

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-RepositoryVSCode {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository
    if (-not (Test-Repository -Repositories $repositories -Abb $Abb -Name $Name)) {
        return $repositories | Format-Table
    }

    $repositoryQuery = Get-RepositoryQuery -Abb $Abb -Name $Name

    . code ($repositories | Where-Object -Property $repositoryQuery.Name -EQ  -Value $repositoryQuery.Value | Select-Object -ExpandProperty "local")
    
    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Copy-PSModuleFromModule {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository
    if (-not (Test-Repository -Repositories $repositories -Abb $Abb -Name $Name)) {
        return $repositories | Format-Table
    }

    $repositoryQuery = Get-RepositoryQuery -Abb $Abb -Name $Name

    . code ($repositories | Where-Object -Property $repositoryQuery.Name -EQ  -Value $repositoryQuery.Value | Select-Object -ExpandProperty "local")
    
    return $Null

}
    