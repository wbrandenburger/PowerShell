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
        [System.String] $File,

        [Parameter(Position=1, Mandatory=$True)]
        [System.String[]] $PSModulePath
    )

    $Script:RepositoryFile = $File
    $Script:RepositoryPSModulePath = $PSModulePath
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

    $content = Get-Content $Script:RepositoryFile | ConvertFrom-Json
    if ($Unformated) {
        return $content
    }
    
    return  $content | Format-Table -Property Name, Abbreviation, GitHub, Local
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Repository {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Repository,

        [Parameter()]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )
    
    if ($Abb -or $Name) {
        if (($Repository.Abbreviation -contains $Abb) -or (($Repository.Name -contains $Name))) {
 
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
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Repository,

        [Parameter()]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    
    )

    if (-not (Test-Repository -Repository $Repository -Abb $Abb -Name $Name)) {
        return $Null
    }

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

    $repositories = Get-Repository -Unformated
    $repositoryQuery = Get-RepositoryQuery -Repository $repositories -Abb $Abb -Name $Name
    if (-not $repositoryQuery) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $repositories | Format-Table -Property Name, Abbreviation, GitHub, Local
    }
   
    $repository = $repositories | Where-Object -Property $repositoryQuery.Name -EQ -Value $repositoryQuery.Value
    $localDir = $repository | Select-Object -ExpandProperty "local"
    
    if (Test-Path -Path $localDir) { Set-Location -Path  $localDir }
    else { 
        Write-FormatedError -Message "Path of repository is not valid."
        return $repository | Format-Table -Property Name, Abbreviation, GitHub, Local
    }

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

    $repositories = Get-Repository -Unformated
    $repositoryQuery = Get-RepositoryQuery -Repository $repositories -Abb $Abb -Name $Name
    if (-not $repositoryQuery) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $repositories | Format-Table -Property Name, Abbreviation, GitHub, Local
    }

    $repository = $repositories | Where-Object -Property $repositoryQuery.Name -EQ -Value $repositoryQuery.Value
    $github = $repository | Select-Object -ExpandProperty "github"

    if ($github) { Start-Process -FilePath $github }
    else { 
        Write-FormatedError -Message "No valid url was found."
        return $repository | Format-Table -Property Name, Abbreviation, GitHub, Local
    }

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

    $repositories = Get-Repository -Unformated
    $repositoryQuery = Get-RepositoryQuery -Repository $repositories -Abb $Abb -Name $Name
    if (-not $repositoryQuery) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $repositories | Format-Table -Property Name, Abbreviation, GitHub, Local
    }

    $repository = $repositories | Where-Object -Property $repositoryQuery.Name -EQ -Value $repositoryQuery.Value
    $localDir = $repository | Select-Object -ExpandProperty "local"
    
    if (Test-Path -Path $localDir) { . code $localDir }
    else { 
        Write-FormatedError -Message "Path of repository is not valid."
        return $repository | Format-Table -Property Name, Abbreviation, GitHub, Local
    }
    
    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Copy-PSModuleFromRepository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Abb,

        [Parameter()]
        [System.String] $Name
    )

    $repositories = Get-Repository -Unformated
    $repositoryQuery = Get-RepositoryQuery -Repository $repositories -Abb $Abb -Name $Name
    if (-not $repositoryQuery) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $repositories | Format-Table -Property Name, Abbreviation, GitHub, Local
    }
    
    $repository = $repositories | Where-Object -Property $repositoryQuery.Name -EQ -Value $repositoryQuery.Value
    $moduleDir =  $repository | Select-Object -ExpandProperty "ps-module"

    if (Test-Path -Path $moduleDir) {
        Write-Host $moduleDir
        $Script:RepositoryPSModulePath | ForEach-Object {
            $localModulePath = (Join-Path -Path $_ -ChildPath ($repository | Select-Object -ExpandProperty "name"))
            if (Test-Path  -Path  $localModulePath){
                Remove-Item -Path  $localModulePath -Recurse -Force
            }
            Copy-Item -Path $moduleDir -Destination $localModulePath -Recurse -Force
            Write-FormatedSuccess -Message "Module copied to '$localModulePath'."
        }
    }      
    else { 
        Write-FormatedError -Message "Path of module is not valid."
        return $repository | Format-Table -Property Name, Abbreviation, GitHub, Local
    }

    return $Null
}
    