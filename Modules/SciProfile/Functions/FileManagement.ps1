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

    [CmdletBinding(PositionalBinding, DefaultParameterSetName="Default")]
    
    [OutputType([Void])]

    Param (
        [Parameter(ParameterSetname="Default", Position=0, HelpMessage="Existing project type.")]
        [System.String] $Path = ".\",

        [Parameter(Position=1, HelpMessage="Depth of recusion.")]
        [UInt32] $Depth = 0,

        [ValidateSet("AppData")]
        [Parameter(ParameterSetname="Template", Position=1, HelpMessage="Templates.")]
        [System.String] $Template
    )

    Process {

        if($PSCmdlet.ParameterSetName -eq "Template"){
            switch ($Template){
                "AppData" {
                    $Path = Join-Path -Path $Env:USERPROFILE -ChildPath "AppData"
                    $Depth = 1
                    break
                }
            } 
        }


        $result = Get-ChildItem -Path $Path -Depth $Depth -Recurse -ErrorAction SilentlyContinue | Where-Object { 
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