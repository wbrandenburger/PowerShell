# ==============================================================================
#   Test-EnvironmentPath.ps1 ---------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Test-EnvironmentPath
{    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Name

    .PARAMETER Scope

    .EXAMPLE

    .NOTES
    #>

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Boolean])]

    Param (    
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String] $Path,

        [Parameter()]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {
        $testResult = if (Get-EnvironmentVariable -Name "Path" -Scope $Scope | Where-Object -FilterScript { $_.Path -ieq $Path}) {$True} else {$False}
        return $testResult
    }
}
