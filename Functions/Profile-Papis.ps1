# ============================================================================
#   Profile-Papis.ps1 --------------------------------------------------------
# ============================================================================

#   settings -----------------------------------------------------------------
# ----------------------------------------------------------------------------
$Script:PapisFile = $Null
$Script:ConfigPapis = $Null

#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidatePapisLibraryAlias: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] (Get-Project | Where-Object {$_.type -eq "papis"} | Select-Object -ExpandProperty Alias)
    }
}
#   validation ---------------------------------------------------------------
# ----------------------------------------------------------------------------
Class ValidateVirtualEnv: System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return [String[]] ((Get-VirtualEnv | Select-Object -ExpandProperty Name) + "")
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-PapisConfiguration{

    [CmdletBinding()]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $File
    )

    Process {

        $Script:PapisFile = $File
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-PapisConfiguration {
    
    [CmdletBinding()]
    
    [OutputType([Void])]

    Param (
    )

    Process {

        $Script:ConfigPapis = Get-IniContent $Env:PAPIS_CONFIG

        return $Null
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Get-ActivePapisEnv {
    
    [CmdletBinding()]
    
    [OutputType([Boolean])]

    Param (

        [Parameter()]
        [Switch] $Name
    )

    Process {

        if ( $Env:PAPIS_LIB) { 
            if ($Name) {
                return $Env:PAPIS_LIB
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
function Get-CurrentPapisEnv {
    
    [CmdletBinding()]
    
    [OutputType([System.String])]

    Param (

        [Parameter()]
        [Switch] $NoRead
    )

    Process {
        
        if (-not $NoRead) {
            Get-PapisConfiguration
        }

        return $Script:ConfigPapis["settings"]["default-library"]
    }
}


#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Start-PapisLibrary {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (

        [ValidateSet([ValidatePapisLibraryAlias])]
        [Parameter(Position=1)]
        [System.String] $Name,

        [ValidateSet([ValidateVirtualEnv])]
        [Parameter(Position=2)]
        [System.String] $VirtualEnv,

        [Parameter()]
        [Switch] $Silent
    )

    Process {

        Get-PapisConfiguration 
        if (-not $Name) {
            if ($Env:PAPIS_LIB){
                $Name = $Env:PAPIS_LIB
            }
            else {
                $Name = Get-CurrentPapisEnv -NoRead
            }
            
        }
        $selection = Select-Project -Name $Name -Property papis -Type Papis

        
        if ($selection) { 
            
            [System.Environment]::SetEnvironmentVariable("PAPIS_LIB", $selection, "process")

            if (-not $VirtualEnv){
                $VirtualEnv = Select-Project -Name $Name -Property virtualenv -Type Papis
            }
            Start-VirtualEnv -Name $VirtualEnv -Silent
            
        }
        else { 
            Write-FormatedError -Message "No corresponding papis library was found."
            return Get-Papis
        }

        return $Null

    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Stop-PapisLibrary {
    
    [CmdletBinding()]
    
    [OutputType([Void])]

    Param (
    )

    Process {

        if ( Get-ActivePapisEnv ) { 

            [System.Environment]::SetEnvironmentVariable("PAPIS_LIB", "", "process")

            Stop-VirtualEnv -Silent

        }
        else { 
            Write-FormatedError -Message "There is no running virtual environment."
        }

        return $Null

    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Set-PapisLibrary {
    
   
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (

        [ValidateSet([ValidatePapisLibraryAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process{ 

        Get-PapisConfiguration 

        $selection = Select-Papis -Name $Name -Property papis -Type Papis

        if ($selection) { 
            $configPapis | Set-IniContent -Sections "settings" -NameValuePairs @{"default-library" =  "$selection"} | Out-IniFile $Env:PAPIS_CONFIG -Force
        }    
        else { 
            Write-FormatedError -Message "No corresponding papis library was found."
            return Get-Papis
        }

        return $Null
    }
}
