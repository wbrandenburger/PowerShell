# ==============================================================================
#   Profile.Papis.ps1 ----------------------------------------------------------
# ==============================================================================

#   settings -------------------------------------------------------------------
# ------------------------------------------------------------------------------
$Script:PapisFile = $Null
$Script:ConfigPapis = $Null

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-Papis{

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param (
        [Parameter()]
        [Switch] $Unformated
    )

    Process {

        $data = Get-Content $Script:PapisFile | ConvertFrom-Json
        if ($Unformated) {
            return $data
        }
        
        return Format-Papis -Data $data
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Format-Papis {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [PSCustomObject] $Data
    )

    Process {

        return $Data | Format-Table -Property Name, Alias, Path, Description

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-Papis {

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
function Select-Papis {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([PSCustomObject])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Property
    )

    Process { 

        $data = Get-Papis -Unformated
        if (-not (Test-Papis $data $Name)) {
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-ActivePapisEnv {
    
    [CmdletBinding()]
    
    [OutputType([Boolean])]

    Param (

        [Parameter()]
        [Switch] $Name
    )

    Process {

        if ( $Env:PSPROFILE_PAPIS_LIBRARY) { 
            if ($Name) {
                return $Env:PSPROFILE_PAPIS_LIBRARY
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


#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-PapisLibrary {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter(Position=1)]
        [System.String] $Name,

        [Parameter(Position=2)]
        [System.String] $VirtualEnv,

        [Parameter()]
        [Switch] $Silent
    )

    Process {

        Get-PapisConfiguration 
        if (-not $Name) {
            $Name = Get-CurrentPapisEnv -NoRead
        }
        $selection = Select-Papis $Name papis

        
        if ($selection) { 
            
            if (-not ( (Get-ActivePapisEnv -Name) -match $selection)){      
                Set-PapisLibrary -Name $Name
            }
            
            [System.Environment]::SetEnvironmentVariable("PSPROFILE_PAPIS_LIBRARY", $selection, "process")

            if (-not $VirtualEnv){
                $VirtualEnv = Select-Papis $Name virtualenv
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

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Stop-PapisLibrary {
    
    [CmdletBinding()]
    
    [OutputType([Void])]

    Param (
    )

    Process {

        if ( Get-ActivePapisEnv ) { 

            [System.Environment]::SetEnvironmentVariable("PSPROFILE_PAPIS_LIBRARY", "", "process")

            Stop-VirtualEnv -Silent

        }
        else { 
            Write-FormatedError -Message "There is no running virtual environment."
        }

        return $Null

    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Set-PapisLibrary {
    
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name
    )

    Process{ 

        Get-PapisConfiguration 

        $selection = Select-Papis $Name papis

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


#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Invoke-PapisFunctions {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter()]
        [System.String] $Name,

        [Parameter()]
        [System.String] $Command,

        [Parameter()]
        [System.String] $Query
    )

    Process{ 
 
        $activePapisEnv = Get-ActivePapisEnv

        Start-PapisLibrary -Name $Name

        if (Get-ActivePapisEnv) {
            Write-FormatedProcess -Message "Search in papis library '$(Get-ActivePapisEnv -Name)'."
        
            switch ($Command){
                "browse" {
                    papis browse "$Query"
                    break
                }
                "clear" {
                    papis --clear-cache
                    papis list
                    break
                }
                "edit" {
                    papis edit "$Query"
                    break
                }
                "explorer" {
                    papis open --dir "$Query"
                    break
                }
                "open" {
                    papis open "$Query"
                    break
                }   
            }
                       
            if (-not $activePapisEnv) {
                Stop-PapisLibrary
            }
        }

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-PapisExplorer {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter()]
        [System.String] $Name,

        [Parameter(Position=1)]
        [System.String] $Query
    )

    Process{ 
        
        Invoke-PapisFunctions -Name $Name -Command "explorer" -Query $Query

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-PapisVSCode {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter()]
        [System.String] $Name,

        [Parameter(Position=1)]
        [System.String] $Query
    )

    Process{ 
 
        Invoke-PapisFunctions -Name $Name -Command "edit" -Query $Query

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Start-PapisWeb {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter()]
        [System.String] $Name,

        [Parameter(Position=1)]
        [System.String] $Query
    )

    Process{ 

        Invoke-PapisFunctions -Name $Name -Command "browse" -Query $Query

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Clear-PapisLibrary {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter(Position=1)]
        [System.String] $Name
    )

    Process{ 

        Invoke-PapisFunctions -Name $Name -Command "clear"

        return $Null
    }
}

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Open-PapisDocument {
    
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [Parameter()]
        [System.String] $Name,

        [Parameter(Position=1)]
        [System.String] $Query
    )

    Process{ 

        Invoke-PapisFunctions -Name $Name -Command "open" -Query $Query

        return $Null

    }
}
