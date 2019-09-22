# ===========================================================================
#   Repair-PocsPapis.ps1 ----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Repair-PocsPapis {

    <#
    .SYNOPSIS
        Validates an existing papis environment and repair it, if needed.

    .DESCRIPTION
        Checks, whether the referenced virtual environment can be found, the package papis is installed and its configuration file exists. If it is needed a new virtual environment will be created, papis installed and a new configuration file generated.

    .INPUTS
        None.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param()

    Process {

        if (-not $(Get-VirtualEnv -Unformatted | Where-Object { $_.Name -eq $PSPocs.VirtualEnv})){
            Write-FormattedWarning -Message "Virtual environment '$($PSPocs.VirtualEnv)' cannot be found. Installation of new virtual environment." -Module $PSPocs.Name

            New-VirtualEnv -Name $PSPocs.VirtualEnv
        } 

        if (-not $((Get-VirtualEnv -Name $PSPocs.VirtualEnv -Unformatted) | Where-Object { $_.Name -eq "papis"})){
            Write-FormattedWarning -Message "Package 'papis' can not be found in virtual environment '$($PSPocs.VirtualEnv)' can not be found. Installation of 'papis'." -Module $PSPocs.Name
            
            Install-VirtualEnv -Name $PSPocs.VirtualEnv -Package "$($PSPocs.PapisPckg)"
        } 

        if (-not $(Test-Path -Path $PSPocs.PapisConfig)){
            
            Write-FormattedWarning -Message "Papis configuration file '$($PSPocs.PapisConfig)' cannot be found." -Module $PSPocs.Name

            Invoke-VirtualEnv -Name $PSPocs.VirtualEnv -ScriptBlock {papis config dir} -Silent
        }

    }
}
