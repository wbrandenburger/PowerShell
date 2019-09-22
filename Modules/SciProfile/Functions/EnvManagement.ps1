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

        [Parameter(Position=2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName , HelpMessage="Value ofor specified environment variable")]
        [System.String] $Value,

        [Parameter(Position=3, HelpMessage="Scope of specified environment variable")]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )
  
    Process {

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
        PS C:\> Test-EnvPath -Path 'C:\Windows' -SCope 'process'
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

# #   function -------------------------------------------------------------------
# # ------------------------------------------------------------------------------
# function Repair-EnvironmentPath
# {
#     <#
#     .SYNOPSIS

#     .DESCRIPTION

#     .PARAMETER Name

#     .PARAMETER Scope

#     .EXAMPLE

#     .NOTES
#     #>

#     [CmdletBinding(PositionalBinding=$True, SupportsShouldProcess=$True, ConfirmImpact="None")]

#     [OutputType([Void])]
    
#     Param (
#         [Parameter()]
#         [ValidateSet("process", "machine", "user")]
#         [System.String] $Scope = "process"
#     )

#     Process {

#         if ($Scope -eq 'process')
#         {
#             Write-Warning -Message 'This will change current-process value only. This may not be what you intended; see -Scope'
#         }

#         # Ensure unique paths only
#         $paths = Get-EnvironmentVariable -Name "Path" -Scope $Scope
#         $result = @()
#         foreach ($path in ($paths | Select-Object -ExpandProperty Path))
#         {
#             if ([string]::IsNullOrWhiteSpace($path)) {
#             Write-Verbose -Message 'Found empty path. Removing.'
#             continue
#             }

#             $path = $path.Trim()
#             if ($path -in $result) {
#                 Write-Warning -Message "Found duplicate path [$path]. Removing."
#                 if ($PSCmdlet.ShouldProcess($path, 'Removing duplicate path entry?')) {
#                     continue
#                 }
#             }   

#             if (-not (Test-Path $path -PathType Container)) {
#                 Write-Warning -Message "Found invalid path [$path]. Removing."
#                 if ($PSCmdlet.ShouldProcess($path, 'Removing invalid path entry?')) {
#                     continue
#                 }
#             }

#             $result += $path
#         }

#         if ($PSCmdlet.ShouldProcess("`n$($result -join "`n")`n", 'Update environment with paths')){
#             [Environment]::SetEnvironmentVariable("Path", $result -join ';', $Scope)
#         }
#     }
# }
