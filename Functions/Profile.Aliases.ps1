# ==============================================================================
#   Profile.Aliases.ps1 --------------------------------------------------------
# ==============================================================================

#   aliases --------------------------------------------------------------------
# ------------------------------------------------------------------------------

    # define aliases for specific function
    [PSCustomObject[]] $Script:PSAlias = @(

    # aliases for functions to manage projects
    [PSCustomObject] @{Name="cdx"; Value="Set-LocationProject"; Tag="Project"},
    [PSCustomObject] @{Name="exx"; Value="Start-ProjectExplorer"; Tag="Project"},
    [PSCustomObject] @{Name="lsx"; Value="Get-ChildItemProject"; Tag="Project"},
    [PSCustomObject] @{Name="vsx"; Value="Start-ProjectVSCode"; Tag="Project"},

    # aliases for functions to manage repositories
    [PSCustomObject] @{Name="lsgit"; Value="Get-Repository"; Tag="Repository"}
    [PSCustomObject] @{Name="webgit"; Value="Start-RepositoryWeb"; Tag="Repository"}
    [PSCustomObject] @{Name="rungitc"; Value="Start-RepositoryCollection"; Tag="Repository"}
    [PSCustomObject] @{Name="stgitc"; Value="Stop-RepositoryCollection"; Tag="Repository"}
    
    # aliases for functions to manage modules
    [PSCustomObject] @{Name="lspsm"; Value="Get-PSModule"; Tag="Module"}
    [PSCustomObject] @{Name="mkpsm"; Value="Import-PSModule"; Tag="Module"}
    [PSCustomObject] @{Name="rmpsm"; Value="Remove-PSModule"; Tag="Module"}
    [PSCustomObject] @{Name="webpsm"; Value="Start-PSModuleWeb"; Tag="Module"}
    [PSCustomObject] @{Name="cppsm"; Value="Copy-PSModuleFromRepository"; Tag="Module"}


    # aliases for common functions
    [PSCustomObject] @{Name="psalias"; Value="Get-PSAlias"; Tag="Common"},
    [PSCustomObject] @{Name="refreshps"; Value="Restart-PSSession";Tag="Common"}
    )
    
    $Script:PSAlias | ForEach-Object {
        Set-Alias -Name $_.Name -Value $_.Value
    }

#     # $Script:PSAliasTags = $Script:PSAlias | Select-Object -Property Tag -Unique

#   functions ------------------------------------------------------------------
# ------------------------------------------------------------------------------
    function Get-PSAlias{

        [CmdletBinding(PositionalBinding=$True)]

        [OutputType([PSCustomObject])]

        Param(
            [Parameter(Position=1)]
            [ValidateSet("Project", "Repository", "Common", "Module")]
            [System.String[]] $Tag = @("Project", "Repository", "Common", "Module")
        )

        Process {

            $PSAliasTag = @()
            $Tag | ForEach-Object {
                $tagName = $_
                $Script:PSAlias | ForEach-Object { 
                    if ($_.Tag -eq $tagName) {
                        $PSAliasTag += $_
                    }
                }
            }
            
            return $PSAliasTag | Format-Table
        }
    }