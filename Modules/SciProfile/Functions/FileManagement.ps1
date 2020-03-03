# ===========================================================================
#   Get-Projects.ps1 --------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ChildItemSize {
    
    <#
    .DESCRIPTION
        Returns the path of a single module project configuration file.
    
    .PARAMETER Type

    .OUTPUTS
        System.String. Path of project configuration file.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param (
        [Parameter(Position=1, HelpMessage="Existing project type.")]
        [System.String] $Path = ".\"
    )

    Process {
        $result = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { 
            $_ -is [IO.Directoryinfo] 
        } | ForEach-Object {
            $length = 0
            Get-ChildItem -Path $_.fullname -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { 
                $length += $_.length 
            }
            [PSCustomObject] @{
                Name = $_.fullname
                Length = [int64] $length 
            }
        }
        return $result | Sort-Object -Property Length | Format-Table Name, @{
            Label="Length"
            Expression= {"{0:N3} GB" -f ($_.Length / 1Gb)}
        }
    }
}