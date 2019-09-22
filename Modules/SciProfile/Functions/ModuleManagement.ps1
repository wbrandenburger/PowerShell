# ============================================================================
#   Manage-Module.ps1 --------------------------------------------------------
# ============================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Import-PSMFunction {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param()

    Process {
        Get-ChildItem -Path $SciProfile.ScriptDir -Filter "*.ps1" | ForEach-Object {
            . $_.FullName
        }        
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Import-PSMModule {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [Parameter(Position=1)]
        [System.String] $Profile = "Default"
    )

    Process {

        if (-not $(Test-Path -Path $SciProfile.ImportFile)){
            Write-FormattedWarning -Message "File $($SciProfile.ImportFile) does not exist. Import of profile $Profile is aborted." -Module $SciProfile.Name
            return
        }

        $profiles = Get-Content -Path $SciProfile.ImportFile | ConvertFrom-Json
        $available_module = Get-Module -ListAvailable

        if ($profiles.($Profile)) {
            Write-FormattedProcess -Message "Begin to import profile '$Profile'" -Module $SciProfile.Name

            $profiles | Select-Object -ExpandProperty $Profile | ForEach-Object {
                $module_name = $_
                if ($available_module | Where-Object {$_.Name -eq $module_name}){
                    Write-FormattedMessage -Type "Import" -Message $module_name -Color Cyan -Module $SciProfile.Name

                    Import-Module -Name $module_name -Scope "Global"
                } else {
                    Write-FormattedWarning -Message "Module $module_name does not exist. No Import of specified module." -Module $SciProfile.Name
                }
            }
        } else {
            Write-FormattedWarning -Message "Profile $Profile does not exist. No Import of specified profile." -Module $SciProfile.Name 
            return
        }

        if ($($Profile -ne "Admin") -and $(Test-Administrator)){
            return $(Import-PSMModule -Profile "Admin")
        }

        Write-FormattedSuccess -Message "Finished importing profile '$Profile'." -Module $SciProfile.Name

        if ($VerbosePreference){
            return Get-Module
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Remove-PSMModule {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param(
        [Parameter(Position=1, Mandatory)]
        [System.String] $Profile
    )

    Process {

        if (-not $(Test-Path -Path $SciProfile.ImportFile)){
            Write-FormattedWarning -Message "File $($SciProfile.ImportFile) does not exist. Import of profile $Profile aborted." -Module $SciProfile.Name
            return
        }

        $profiles = Get-Content -Path $SciProfile.ImportFile | ConvertFrom-Json
        $loaded_module = Get-Module

        if ($profiles.($Profile)) {
            Write-FormattedProcess -Message "Begin to remove profile '$Profile'" -Module $SciProfile.Name
            $profiles | Select-Object -ExpandProperty $Profile  | ForEach-Object {
                $module_name = $_
                if ($loaded_module | Where-Object {$_.Name -eq $module_name}){
                    Remove-Module -Name $module_name
                }
            }
            Write-FormattedSuccess -Message "Finished removing profile '$Profile'." -Module $SciProfile.Name
        } else {
            Write-FormattedWarning -Message "Profile $Profile does not exist. No Import of specified profile." -Module $SciProfile.Name
            return
        }

        if ($VerbosePreference){
            return Get-Module
        }
    }
}


#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Import-PSMRepository {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param(

        [ValidateSet([ValidatePSModuleProject])]
        [Parameter(Position=1, HelpMessage="Specification of project.")]
        [System.String] $Name="",

        [Parameter(HelpMessage="Modules are gotten from configuration file.")]
        [Switch] $Config
    )

    Process {

        if ($Config) {
            Get-Content -Path $SciProfile.ImportFile | ConvertFrom-Json | Select-Object -ExpandProperty "repository" | ForEach-Object {
                if ($_) {
                    Import-PSMRepository -Name $_
                }
            }
            return
        }
        
        $module = Select-Project -Name $Name -Property "Name" -Type "PSModule"
        $module_path = Select-Project -Name $Name -Property "Local" -Type "PSModule"
        
        if ($module_path -and (Test-Path -Path $module_path)) {
            $SciProfile.ModuleDir | ForEach-Object {
                $module_local = (Join-Path -Path $_ -ChildPath $module)
                if (Test-Path  -Path  $module_local){
                    Remove-Item -Path $module_local -Recurse -Force
                }
                Write-FormattedProcess -Message "Begin to copy module to '$($module_local)'." -Module $SciProfile.Name
                Copy-Item -Path $module_path -Destination $module_local -Recurse -Force
                Write-FormattedSuccess -Message "Module copied to '$($module_local)'." -Module $SciProfile.Name
            }
        }      
        else { 
            Write-FormattedError -Message "Path of module $($module) is not valid." -Module $SciProfile.Name
            return 1
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Install-PSMRepository {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param(
        [ValidateSet([ValidatePSModuleProject])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name,

        [Parameter(HelpMessage="Modules are gotten from configuration file.")]
        [Switch] $Config
    )

    Process {
        
        if ($Config){
            Import-PSMRepository -Config
        } else {
            Import-PSMRepository -Name $Name
        }
        
        Start-Process -FilePath "pwsh" -Wait -NoNewWindow
    }
}



