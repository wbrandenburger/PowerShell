# ===========================================================================
#   EnvManagement.ps1 -------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-EnvVariable
{
    <#
    .DESCRIPTION
        Get detailed information about a environment variable of specific scope, or all existing environment variables.

    .PARAMETER Name

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Get-EnvVariable

        Name                           Value
        ----                           -----
        ALLUSERSPROFILE                C:\ProgramData
        ANDROID_SDK_HOME               C:\Android

        -----------
        Description
        Return detailed information about all existing environment variables in scope process. All available environment variables can be accessed by autocompletion.

    .EXAMPLE
        PS C:\> Get-EnvVariable -Name 'ALLUSERSPROFILE' -Scope 'process'

        Name                Scope
        ----                -----
        C:\ProgramData      process

        -----------
        Description
        Return detailed information about environment variable 'ALLUSERSPROFILE' in scope process.

    .INPUTS
        Name

    .OUTPUTS
        System.Object. Information about specified environment variable
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([System.Object])]

    Param(
        [Parameter(Position=1, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="Name of environment variable")]
        [ValidateSet([ValidateSystemEnv])]
        [System.String] $Name,

        [Parameter(Position=2, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )
  
    Process {

        $result = @()

        if ($Name) {
            # if name is specified return the environment variable, and split the elements if its elements are structured as list
            [System.Environment]::GetEnvironmentVariable($Name, $Scope) -Split ';' | ForEach-Object {
                if (-not [System.String]::IsNullOrWhiteSpace($_)) {
                    $result += [PSCustomObject] @{
                        Name   = $_
                        Scope  = $Scope
                    }
                }
            }
        } else {
            # return all environment variales in scope process
            $result = Get-ChildItem -Path "Env:"
        }

        return $result
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Set-EnvVariable
{
    <#
    .DESCRIPTION
        Set environment variable with specific value.

    .PARAMETER Name

    .PARAMETER Value

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Set-EnvVariable -Name 'ALLUSERSPROFILE' -Value 'C:\ProgramData' -Scope 'process'

        -----------
        Description
        Set Environment variable 'ALLUSERSPROFILE' with value 'C:\ProgramData' in scope 'process'.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [Parameter(Position=1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName , HelpMessage="Name of environment variable")]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName , HelpMessage="Value for specified environment variable")]
        [System.String] $Value,

        [Parameter(Position=3, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process",

        [Parameter(HelpMessage="Concatenates the specified environment variable")]
        [Switch] $Concatenate
    )
  
    Process {

        if ($Concatenate) {
            $Value = $Value + ";" + [System.Environment]::GetEnvironmentVariable($Name, $Scope)
        } 

        [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)

    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Test-EnvPath {    
    <#
    .DESCRIPTION
        Test whether a path exists in environment of specific scope.

    .PARAMETER Path

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Test-EnvPath -Path 'C:\Windows' -Scope 'process'
        True

        -----------
        Description
        Return true if environment path contains path 'C:\Windows' in scope 'process'.
    .OUTPUTS
        Boolean. True if environment path contains specified parameter path.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Boolean])]

    Param (    
        [Parameter(Position=1, ValueFromPipeline, HelpMessage="Path which will be searched for in environment path")]
        [System.String] $Path,

        [Parameter(Position=2, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {
        return $(if (Get-EnvVariable -Name "Path" -Scope $Scope | Where-Object -FilterScript { $_.Name -match $($Path -replace "\\", "\\")}) {$True} else {$False})
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Set-EnvPath {
    <#
    .DESCRIPTION
        Add a path to environment variable 'PATH'.

    .PARAMETER Name

    .PARAMETER Value

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Set-EnvPath -Path 'C:\ProgramData' -Scope 'process'

        -----------
        Description
        Add to environment variable 'PATH' the path 'C:\ProgramData' in scope 'process'.

    .OUTPUTS
        None.
    #>  
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName , HelpMessage="Path which shall be added to environment variable 'PATH'")]
        [System.String] $Path,

        [Parameter(Position=1, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {

        if (-not (Test-Path -Path $Path)){
            Write-FormattedError -Message "The path '$Path' does not exist." -Module $SciProfile.Name
            return
        }

        Set-EnvVariable -Name "PATH" -Value $Path -Scope $Scope -Concatenate
    
    } 
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Remove-EnvPath {
    <#
    .DESCRIPTION
        Add a path to environment variable 'PATH'.

    .PARAMETER Name

    .PARAMETER Value

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Set-EnvPath -Path 'C:\ProgramData' -Scope 'process'

        -----------
        Description
        Add to environment variable 'PATH' the path 'C:\ProgramData' in scope 'process'.

    .OUTPUTS
        None.
    #>  
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([Boolean])]

    Param(
        [ValidateSet([ValidateSystemEnvPath])]
        [Parameter(Position=0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage="Path which shall be added to environment variable 'PATH'")]
        [System.String] $Path,

        [Parameter(Position=1, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {

        $value = ([System.Environment]::GetEnvironmentVariable("PATH", $Scope) -Split ';' | Where-Object { $_ -ne $Path }) -Join ";"

        Set-EnvVariable -Name "PATH" -Value $value -Scope $Scope
    } 
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Repair-EnvPath {
    <#
    .DESCRIPTION
        Add a path to environment variable 'PATH'.

    .PARAMETER Name

    .PARAMETER Value

    .PARAMETER Scope

    .EXAMPLE
        PS C:\> Set-EnvPath -Path 'C:\ProgramData' -Scope 'process'

        -----------
        Description
        Add to environment variable 'PATH' the path 'C:\ProgramData' in scope 'process'.

    .OUTPUTS
        None.
    #>  
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([Boolean])]

    Param(
        [Parameter(Position=0, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {

        if ($Scope -eq 'process')
        {
            Write-FormattedWarning -Message 'This will change current-process value only. This may not be what you intended; see -Scope' -Module $SciProfile.Name
        }

        $path_list = [System.Environment]::GetEnvironmentVariable("PATH", $Scope) -Split ';' | Sort-Object | Get-Unique

        $value=@()
        $value = ($path_list | ForEach-Object {
            if (Test-Path -Path $_ -ErrorAction SilentlyContinue ){
                $result + $_
            }
        }) -Join ";"

        if ($Scope -ne 'process')
        {
            Set-EnvVariable -Name "PATH" -Value $value -Scope $Scope
        }
    } 
}