# ===========================================================================
#   psfunctions-utils.ps1 ---------------------------------------------------
# ===========================================================================

#   alias -------------------------------------------------------------------
# ---------------------------------------------------------------------------
New-Alias -Name "psm-i" -Value "Invoke-User" -Scope "Global"
New-Alias -Name "psm-ud" -Value "Update-PowerShell" -Scope "Global"
New-Alias -Name "psm-pb" -Value "Publish-SciProfile" -Scope "Global"

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Invoke-User {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [Parameter(Position=1, HelpMessage="Specifies the name of the user defined action to be performed.")]
        [ValidateSet("DLBox", "Color")]
        [System.String] $Name
    )

    switch ($Name) {
        "Color" {
            return [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
            break
        }
        "DLBox" {
            Start-Process -FilePath putty -ArgumentList "-ssh", "wolfgang@137.193.150.172"
            # 20wolf19gang
            # pscp.exe  source A:\OneDrive\Download\putty-64bit-0.72-installer.msi wolfgang@137.193.150.172:/media/Raid/Datasets
            break
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Publish-SciProfile {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(
        [Parameter(Position=1, HelpMessage="Specifies the name of the module that you want to publish. Publish-Module searches for the specified module name in `$Env:PSModulePath.")]
        [ValidateSet("SciProfile", "PSVirtualEnv", "PSPocs")]
        [System.String] $Name
    )

    Process {

        $local_module = @(
            @{ Name = "SciProfile"; NuGetApiKey="oy2pa5ev5v4qo7dv3bkq3u76pm2z34yujo7gzl4ykno3x4"}
            @{ Name = "PSVirtualEnv"; NuGetApiKey="oy2g2qz54gynlzaf23aaydgh3j3ipelungwxlhthucfxwe"}
            @{ Name = "PSPocs"; NuGetApiKey="oy2itxr6nv3o6c5emaqqtyua3nlgauwuxet3e2cujj6gfa"}
        )

        Publish-Module -Name $Name -NuGetApiKey $($local_module | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty "NuGetApiKey") 
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
Function Global:Update-PowerShell {

    [CmdletBinding(SupportsShouldProcess=$True)]
    
    [OutputType([Void])]

    Param(
        [Parameter(HelpMessage="Deletes files and folders in system's temporary folder.")]
        [Switch] $Clear
    )

    Process {

        if ($Clear) {
            Remove-Item $env:UserPath\AppData\Local\Temp\* -recurse -force -ErrorAction SilentlyContinue
        }

        Start-Process -FilePath refreshenv.cmd -Wait -NoNewWindow

        Start-Process -FilePath pwsh -Wait -NoNewWindow

    }
}

# $Global:Window_Layouts = @(
#     [PSCustomObject] @{
#         "Computer" = "WB-LAPTOP1"
#         "Application" = "Papis-Default"
#         "X" = 953
#         "Y" = 700
#         "Width" = 974
#         "Height" =  387
#     },
#     [PSCustomObject] @{
#         "Computer" = "WB-LAPTOP1"
#         "Application" = "Papis"
#         "X" = 953
#         "Y" = 40
#         "Width" = 974
#         "Height" =  667
#     }
# )

# Function Global:Set-Layout {

#     [CmdletBinding()]

#     [OutputType([Void])]

#     Param(

#         [Parameter(Position=1, Mandatory=$False)]
#         [String] $Application="Default",

#         [Parameter(Position=2, Mandatory=$False)]
#         [String] $Computer="WB-LAPTOP1"
#     )

#     Process{

#         $layout = $Script:Window_Layouts | Where-Object{ $_.Computer -eq $Computer -and $_.Application -eq $Application}

#         Set-Window -Id $PID -X $layout.X -Y $layout.Y -Width $layout.Width -Height $layout.Height

#     }
# }
