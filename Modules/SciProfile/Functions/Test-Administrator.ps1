# ===========================================================================
#   Test-Administrator.ps1 --------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
Function Test-Administrator {

    <#
    .SYNOPSIS
        Test whether current powershell session is run by administrator.

    .DESCRIPTION
        Test whether current powershell session is run by administrator. Return true, if powershell session is run by administrator.

    .EXAMPLE
        PS C:\> Test-Administrator
        False

        -----------
        Description
        Return false, if powershell session is not run by administrator.


    .INPUTS
        None.

    .OUTPUTS
        Bool. Return true, if powershell session is run by administrator.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Bool])]

    Param()

    Process {

        return (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    }
}
