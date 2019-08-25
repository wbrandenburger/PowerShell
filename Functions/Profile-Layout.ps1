# ===========================================================================
#   Profile-Layout.ps1 -----------------------------------------------------
# ===========================================================================

$Script:Window_Layouts = @(
    [PSCustomObject] @{
        "Computer" = "WB-LAPTOP1"
        "Application" = "Papis-Default"
        "X" = 953
        "Y" = 700
        "Width" = 974
        "Height" =  387
    },
    [PSCustomObject] @{
        "Computer" = "WB-LAPTOP1"
        "Application" = "Papis"
        "X" = 953
        "Y" = 40
        "Width" = 974
        "Height" =  667
    }
)

Function Set-Layout {

    [CmdletBinding()]

    [OutputType([Void])]

    Param(

        [Parameter(Position=1, Mandatory=$False)]
        [String] $Application="Default",

        [Parameter(Position=2, Mandatory=$False)]
        [String] $Computer="WB-LAPTOP1"
    )

    Process{

        $layout = $Script:Window_Layouts | Where-Object{ $_.Computer -eq $Computer -and $_.Application -eq $Application}

        Set-Window -Id $PID -X $layout.X -Y $layout.Y -Width $layout.Width -Height $layout.Height

    }
}

Function Set-LayoutPapis
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Mandatory=$False)]
        [Switch] $Prompt
    ) 

    Process{

        Set-Layout -Application Papis

        if ($Prompt) {
        Start-Process pwsh "-NoExit -NoLogo -command Set-Layout -Application Papis-Default"

        }
    }
}

