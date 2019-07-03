# ==============================================================================
#   Get-EnvironmentVariable.ps1 ------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Get-EnvironmentVariable
{
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Name

    .PARAMETER Scope

    .EXAMPLE

    .NOTES
    #>

    [CmdletBinding()]

    [OutputType([PSCustomObject])]

    Param(
        [Parameter()]
        [System.String] $Name = 'PATH',

        [Parameter()]
        [ValidateSet("process", "machine", "user")]
        [System.String[]] $Scope = "process"
    )
  
    Process {
        $environmentPath = @()
        $Scope | ForEach-Object {
            $environmentScope = $_
            [System.Environment]::GetEnvironmentVariable($Name, $environmentScope) -Split ';' |  ForEach-Object {
                if (-not [System.String]::IsNullOrWhiteSpace($_)) {
                    $environmentPath += [PSCustomObject] @{
                        Path   = $_
                        Scope  = $environmentScope
                        Exists = Test-Path($_)
                    }
                }
            } 
        }
        return $environmentPath
    }
}
Set-Alias -Name lsenv -Value Get-EnvironmentVariable

