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
        [ValidateSet("dl-multi-train", "dl-multi-train-3n", "dl-multi-eval", "dl-multi-eval-3n", "dl-multi-tfrecord", "dl-multi-test", "rsvis-datasets", "rsvis-dl")]
        [System.String] $Project
    )
    Set-EnvVariable -Name "EXPMGMT_PROJECT" -Value $Project
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Set-CudaDevices{
    Param(
        [System.String] $Devices
    )
    Set-EnvVariable -Name "CUDA_VISIBLE_DEVICES" -Value $Devices
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

        [ValidateSet("dl-multi-train", "dl-multi-train-3n", "dl-multi-eval", "dl-multi-eval-3n", "dl-multi-tfrecord", "dl-multi-test", "rsvis-datasets", "rsvis-dl")]
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