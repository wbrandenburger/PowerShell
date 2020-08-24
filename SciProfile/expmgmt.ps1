# ===========================================================================
#   expmgmt.ps1 -------------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Update-PowerShell{
    Invoke-Expression "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
    # -Preview
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Get-ExpmgmtProject{
    return Get-EnvVariable -Name "EXPMGMT_PROJECT"
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Set-ExpmgmtProject{
    Param(
        [ValidateSet("dl-multi-train", "dl-multi-train-test", "dl-multi-eval", "dl-multi-eval-tile", "dl-multi-tfrecord", "dl-multi-test", "expmgmt", "rsvis-datasets", "rsvis-lecture", "rsvis-dl", "shdw")]
        [System.String] $Project
    )
    Set-EnvVariable -Name "EXPMGMT_PROJECT" -Value $Project
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Remove-ExpmgmtTemp{
    
    Get-ChildItem -Path ([System.Environment]::GetEnvironmentVariable("TEMP")) | Where-Object {($_.name -match "expmgmt") -or ($_.name -match "shdw")} | Remove-Item -Force

}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Start-RSVis
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [ValidateSet("dev-rsvis", "dev-rsvis-torch")]
        [Parameter(Position=1, HelpMessage="Name of virtual environment.")]
        [System.String] $VirtualEnv="dev-rsvis",

        [ValidateSet("dl-multi-train", "dl-multi-train-test", "dl-multi-eval", "dl-multi-eval-tile", "dl-multi-tfrecord", "dl-multi-test", "expmgmt", "rsvis-datasets", "rsvis-lecture", "rsvis-dl", "shdw")]
        [Parameter(Position=2, HelpMessage="Name of experiment project.")]
        [System.String] $Project="rsvis-datasets"
    ) 

    Process{

        Start-VirtualEnv -Name $VirtualEnv
        Set-ExpmgmtProject -Project $Project
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Start-Inkscape
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
    ) 

    Process{

        Start-VirtualEnv -Name inkscape -Silent
        . "C:\Program Files\Inkscape\bin\inkscape.exe"
        Stop-VirtualEnv -Silent
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Open-RSVis
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [ValidateSet("vai", "dfc", "dfc-single", "mtarsi", "mtarsi-single", "mtarsi-single-5")]
        [Parameter(Position=1, HelpMessage="Name of the experiment.")]
        [System.String] $Name="vai"
    ) 

    Process{
        expmgmt run -e $Name
    }
}