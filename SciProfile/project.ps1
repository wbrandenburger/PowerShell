# ===========================================================================
#   project.ps1 -------------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Get-Repository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]

    Param (

        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Alias,

        [Switch] $Unformatted
    )

    $result = Get-ProjectList -Type repository -Unformatted 
    if ($Alias) {
        
        $result = $result | Where-Object{
            $_.Alias -eq $Alias
        }

    }
    
    if ($Unformatted){
        return $result
    }

    return $result | Format-Table Name, Alias, Url
}
