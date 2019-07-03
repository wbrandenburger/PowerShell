# ==============================================================================
#   Copy-VirtualEnv.ps1 --------------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
function Copy-VirtualEnv {
    
    <#
    .SYNOPSIS

    .DESCRIPTION
        
    .PARAMETER Name

    .PARAMETER All

    .EXAMPLE
        PS C:\> Install-VirtualEnvPckg -Name venv

        -----------
        Description
       
    .INPUTS
        None.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Name of the virtual environment to be changed.")]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$True, ValueFromPipeline=$True,HelpMessage="Specifies the path to the new location..")]
        [System.String] $Path,

        [Parameter(Position=3, Mandatory=$False, ValueFromPipeline=$True,HelpMessage="Copies files from Dest to specified virtual envrionment.")]
        [Switch] $Reverse
    )
    
    Process {

        # check whether the specified virtual environment exists
        if (-not (Test-VirtualEnv -Name $Name -Verbose)){
            Get-VirtualEnv
            return $Null
        }

        # abort if parent folder of the destination does not exist
        if (-not (Test-Path -Path (Split-Path -Path $Path -Parent))) {
            Write-FormatedError -Message "Directory '$(Split-Path -Path $Path -Parent)' does not exist."
            return $Null
        }

        if ((Test-Path -Path $Path) -and -not $Reverse){
            $choices  = "&Yes", "&No"
            if ($Host.UI.PromptForChoice($Null, "Remove existing directory '$Path'?", $choices, 1) -eq 0) {
                Remove-Item -Path $Path -Recurse -Force
            } else {
                return $Null
            }
        } 

        if (-not (Test-Path -Path $Path) -and $Reverse){
            Write-FormatedError -Message "Directory '$Path' does not exist."
            return $Null
        }

        Write-FormatedProcess -Message "Copying local files of virtual environment '$Name' to '$Path'."
        
        $copyPath = Get-VirtualEnvLocalDir -Name $Name
        if ($Reverse) {
            $copyPath = $Path
            $Path = Get-VirtualEnvLocalDir -Name $Name
        } 
        
        Copy-Item -Path $copyPath -Destination $Path -Recurse -Force -ErrorAction Stop

        Write-FormatedSuccess -Message "Files was copied."
    }
}