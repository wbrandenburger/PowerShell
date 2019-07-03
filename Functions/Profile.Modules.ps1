# ==============================================================================
#   Profile.Modules.ps1 --------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:ModuleFile = $Null
$Script:ModuleProfile = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-PSModuleConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Profile
    )

    $Script:ModuleFile = $File
    $Script:ModuleProfile = $Profile
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-PSModule {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        [Parameter()]
        [Switch] $Unformated
    )

    $content = Get-Content $Script:ModuleFile | ConvertFrom-Json
    if ($Unformated) {
        return $content
    }
    
    return $content | Format-Table -Property Name, Repository, Description
}


#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-PSModuleProfile {

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        [Parameter()]
        [Switch] $Unformated
    )

    $content = Get-Content $Script:ModuleProfile | ConvertFrom-Json
    if ($Unformated) {
        return $content
    }
    
    return $content | Format-List
}
#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-PSModule {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Module,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Name
    )
    
    if (-not ($Module.Name -contains $Name)) {
        Write-FormatedError -Message "No entry with user specification was found."
        return $False
    }

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        return $False
    }

    return $True
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

    $modules = Get-PSModule -Unformated

    if (-not (Test-PSModule -Module $modules -Name $Name)) {
        return $modules | Format-Table -Property Name, Repository, Description
    }

    $module = $modules | Where-Object -Property Name -EQ -Value $Name
    $webApp = @()
    if ($module.GitHub -ne $Null) { $webApp += $module| Select-Object -ExpandProperty GitHub}
    if ($module.PSGallery -ne $Null) { $webApp += $module| Select-Object -ExpandProperty PSGallery}

    if ($webApp) { $webApp| ForEach-Object{ Start-Process -FilePath $_ }}
    else { 
        Write-FormatedError -Message "No valid url was found."
        return $modules | Format-Table -Property Name, Repository, Description
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
    $profiles = Get-PSModuleProfile -Unformated
    $modules = Get-PSModule -Unformated

    Write-FormatedProcess -Message "Begin to import profile '$Profile'" -Space
    Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

    $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
        if (Test-PSModule -Module $modules -Name $_) {
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

    $profiles = Get-PSModuleProfile -Unformated
    $modules = Get-PSModule -Unformated

    Write-FormatedProcess -Message "Begin to rempove profile '$Profile'." -Space
    Write-FormatedMessage -Message "Profile '$Profile':" -Color DarkGray

    $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
        Write-Host $_
        if (Test-PSModule -Module $modules -Name $_) {
            Remove-Module -Name $_
        }
        else { 
            Write-FormatedError -Message "Module $_ can not imported."
        }
    }

    Write-FormatedSuccess -Message "Finished removing profile '$Profile'." -Space
    
    return Get-Module
}
    