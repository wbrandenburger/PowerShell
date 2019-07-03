# ==============================================================================
#   Repair-EnvironmentPath.ps1 -------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Repair-EnvironmentPath
{
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Name

    .PARAMETER Scope

    .EXAMPLE

    .NOTES
    #>

    [CmdletBinding(PositionalBinding=$True, SupportsShouldProcess=$True, ConfirmImpact="None")]

    [OutputType([Void])]
    
    Param (
        [Parameter()]
        [ValidateSet("process", "machine", "user")]
        [System.String] $Scope = "process"
    )

    Process {

        if ($Scope -eq 'process')
        {
            Write-Warning -Message 'This will change current-process value only. This may not be what you intended; see -Scope'
        }

        # Ensure unique paths only
        $paths = Get-EnvironmentVariable -Name "Path" -Scope $Scope
        $result = @()
        foreach ($path in ($paths | Select-Object -ExpandProperty Path))
        {
            if ([string]::IsNullOrWhiteSpace($path)) {
            Write-Verbose -Message 'Found empty path. Removing.'
            continue
            }

            $path = $path.Trim()
            if ($path -in $result) {
                Write-Warning -Message "Found duplicate path [$path]. Removing."
                if ($PSCmdlet.ShouldProcess($path, 'Removing duplicate path entry?')) {
                    continue
                }
            }   

            if (-not (Test-Path $path -PathType Container)) {
                Write-Warning -Message "Found invalid path [$path]. Removing."
                if ($PSCmdlet.ShouldProcess($path, 'Removing invalid path entry?')) {
                    continue
                }
            }

            $result += $path
        }

        if ($PSCmdlet.ShouldProcess("`n$($result -join "`n")`n", 'Update environment with paths')){
            [Environment]::SetEnvironmentVariable("Path", $result -join ';', $Scope)
        }
    }
}

