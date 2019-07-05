# ==============================================================================
#   Profile.Modules.ps1 --------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:ModuleFile = $Null
$Script:ModuleProfile = $Null
$Script:ModulePSPath = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Format-PSModule {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias, Repository, Path

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Format-PSModuleProfile {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $data
    )

    Process {

        return $Data | Format-List

    }
}
#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-PSModule {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Name,

        [Parameter()]
        [Switch] $Local
    )
    
    Process {
        
        if ($Data.Alias -contains $Name){
            $Name =  $Data | Where-Object {$_.Alias -eq $Name} | Select-Object -ExpandProperty Name
        }

        if (-not ($Data.Alias -contains $Name) -and -not (($Data.Name -contains $Name))) {
            return $False
        }

        if (-not $Local) {
            if (-not (Get-Module -ListAvailable -Name $Name)) {
                return $False
            }
        }

        return $True
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Select-PSModule {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property,

        [Parameter()]
        [Switch] $Local
    )

    Process{ 

        $data = Get-PSModule -Unformated
        if (-not (Test-PSModule $data $Name -Local:$Local)) {
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
function Start-PSModuleWeb {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    $selection = @((Select-PSModule $Name GitHub), (Select-PSModule $Name PSGallery))

    if ($selection) { $selection | ForEach-Object{ Start-Process -FilePath $_ }}
    else { 
        Write-FormatedError -Message "No valid url was found."
        return Get-PSModule
    }

    return $Null
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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
        $modules = Get-PSModule -Unformated

        Write-FormatedProcess -Message "Begin to import profile '$Profile'" -Space
        Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

        $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
            if (Test-PSModule -Data $modules -Name $_) {
                Write-Host $_
                Import-Module -Name $_
            }
            else { 
                Write-FormatedError -Message "Module $_ can not imported."
            }
        }

        Write-FormatedSuccess -Message "Finished importing profile '$Profile'." -Space

        return Get-Module
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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
        $modules = Get-PSModule -Unformated

        Write-FormatedProcess -Message "Begin to remove profile '$Profile'." -Space
        Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

        $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
            Write-Host $_
            if (Test-PSModule -Data $modules -Name $_) {
                Remove-Module -Name $_
            }
            else { 
                Write-FormatedError -Message "Module $_ can not imported."
            }
        }

        Write-FormatedSuccess -Message "Finished removing profile '$Profile'." -Space
        
        return Get-Module
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Copy-PSModuleFromRepository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process {

        $moduleName = Select-PSModule $Name Name -Local
        if (-not $moduleName){
            Write-FormatedError -Message "Specified module does not exist."
            return Get-PSModule        
        }
        $modulePath = Select-PSModule $Name Local -Local
        
        if ($modulePath -and (Test-Path -Path $modulePath)) {
            $Script:ModulePSPath | ForEach-Object {
                $localModulePath = (Join-Path -Path $_ -ChildPath $moduleName)
                if (Test-Path  -Path  $localModulePath){
                    Remove-Item -Path  $localModulePath -Recurse -Force
                }
                Write-FormatedProcess -Message "Begin to copy moduel to '$localModulePath'."
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
    