# ============================================================================
#   Profile-Modules.ps1 ------------------------------------------------------
# ============================================================================

#   settings -----------------------------------------------------------------
# ----------------------------------------------------------------------------
$Script:ModuleFile = $Null
$Script:ModuleProfile = $Null
$Script:ModulePSPath = $Null

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePSModuleAlias: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (Get-Project | Where-Object {$_.type -eq "psmodule"} | Select-Object -ExpandProperty Alias)
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-PSModuleConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Profile,

        [Parameter(Position=3, Mandatory=$True)]
        [System.String[]] $PSModulePath
    )

    $Script:ModuleFile = $File
    $Script:ModuleProfile = $Profile
    $Script:ModulePSPath = $PSModulePath   
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-PSModule{

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        
        [Parameter()]
        [Switch] $Profile,

        [Parameter()]
        [Switch] $Unformated
    )

    Process {

        if (-not $Profile) {
            $data = Get-Content $Script:ModuleFile | ConvertFrom-Json
        }
        else {
            $data = Get-Content $Script:ModuleProfile | ConvertFrom-Json
        }
        
        if ($Unformated) {
            return $data
        }
        
        if (-not $Profile) {
            return Format-PSModule $data
        }
        else {
            return Format-PSModuleProfile $data
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Import-PSModule {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [ValidateSet("User","Developer", "Admin")]
        [System.String] $Profile
    )

    Process {
        $profiles = Get-PSModule -Profile -Unformated

        Write-FormatedProcess -Message "Begin to import profile '$Profile'" -Space
        Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

        $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
            Write-Host $_
            Import-Module -Name $_
        }
        Write-FormatedSuccess -Message "Finished importing profile '$Profile'." -Space

        return Get-Module
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Remove-PSModule {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [ValidateSet("User", "Developer", "Admin")]
        [System.String] $Profile
    )

    Process {
        $profiles = Get-PSModule -Profile -Unformated

        Write-FormatedProcess -Message "Begin to remove profile '$Profile'." -Space
        Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

        $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
            Remove-Module -Name $_
        }
        Write-FormatedSuccess -Message "Finished removing profile '$Profile'." -Space
        
        return Get-Module
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Copy-PSModuleFromRepository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [ValidateSet([ValidatePSModuleAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process {

        $moduleName = Select-Project -Name $Name -Property Name -Type PSModule
        if (-not $moduleName){
            Write-FormatedError -Message "Specified module does not exist."
            return Get-PSModule        
        }
        $modulePath = Select-Project -Name $Name -Property Local -Type PSModule
        
        if ($modulePath -and (Test-Path -Path $modulePath)) {
            $Script:ModulePSPath | ForEach-Object {
                $localModulePath = (Join-Path -Path $_ -ChildPath $moduleName)
                if (Test-Path  -Path  $localModulePath){
                    Remove-Item -Path  $localModulePath -Recurse -Force
                }
                Write-FormatedProcess -Message "Begin to copy module to '$localModulePath'."
                Copy-Item -Path $modulePath -Destination $localModulePath -Recurse -Force
                Write-FormatedSuccess -Message "Module copied to '$localModulePath'."
            }
        }      
        else { 
            Write-FormatedError -Message "Path of module is not valid."
            return Get-PSModule
        }

        return $Null
    }
}
    