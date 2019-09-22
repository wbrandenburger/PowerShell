# ===========================================================================
#   LibraryManagement.ps1 --------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Attempt {
      <#
    .DESCRIPTION
        Get all libraries defined in configuration file of papis and add them to configuration if they do not exist. 
    
    .PARAMETER Name

    .PARAMETER Property

    .OUTPUTS
        ArrayList. List with location of specified property.
    #>
    
    Param()

    Process {
        $pocs_library = Get-PocsLibrary -Unformatted | Where-Object {$_.Library}
        $pocs_out = @()

        $pocs_library | ForEach-Object {
            $pocs_out += [PSCustomObject] @{
                alias = $_.Name
                description = if ($_.Content["description"]){$_.Content["description"]}
                folder = blubb -Object $_
                name = if ($_.Content["name"]){$_.Content["name"]}
                ref = $_.Name
                type = "papis"
                url = if ($_.Content["url"]){$_.Content["url"]}
            }
        }
        return $pocs_out
    }
}

function blubb {

    Param(
        [System.Object] $Object
    )

    $result = @($_.Content["dir"])

    if ($object.Content["use-shared-folders"] -eq "true"){
        $object.Content["shared-library-list"] | ForEach-Object{
            write-host $([Regex]::Matches($_, '\"([a-z0-9])\"', "IgnoreCase").Groups)
        }
        
    }
    return $result
}