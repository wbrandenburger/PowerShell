# ===========================================================================
#   Open-Project.ps1 --------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-PropertyLocation {

    <#
    .DESCRIPTION
        Returns a list with the location of speciefied project property.
    
    .PARAMETER Name

    .PARAMETER Property

    .OUTPUTS
        ArrayList. List with location of specified property.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([System.Collections.ArrayList])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, Mandatory, HelpMessage="Name or alias of an project.")]
        [System.String] $Name,

        [Parameter(Position=2, HelpMessage="Property of project entry, which shall be returned.")]
        [System.String] $Property
    )

    Process{ 

        [System.Array] $selection = Select-Project -Name $Name -Property $Property

        $path_list = [System.Collections.ArrayList]::New()
        if ($selection){
            $selection | ForEach-Object {
                if ($_) {
                    [Void] $path_list.Add($_)
                } 
                else { 
                    Write-FormattedError -Message "Property $($_) of project '$($Name)' is not valid." -Module $SciProfile.Name 
                    return
                }
            }

        }

        return $path_list
    }
}


#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ProjectLocation {

    <#
    .DESCRIPTION
        Returns a list with the location of specified project property.
    
    .PARAMETER Name

    .OUTPUTS
        ArrayList. List with location of specified property.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([System.Collections.ArrayList])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, Mandatory, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process{ 

        return Get-PropertyLocation -Name $Name -Property "Folder"

    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-WebLocation {

    <#
    .DESCRIPTION
        Returns a list with the location of specified project property.
    
    .PARAMETER Name

    .OUTPUTS
        ArrayList. List with location of specified property.
    #>    

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (

        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process {
    
        return Get-PropertyLocation -Name $Name -Property "Url"

    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ProjectChildItem {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process{ 
       
        if (-not $Name){
            return Get-ProjectList
        }

        $path_list = Get-ProjectLocation -Name $Name
        foreach ($path in $path_list){
            Get-ChildItem -Path $path
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Set-ProjectLocation {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name,

        [Switch] $NewWindow
    )

    Process{ 
       
        if (-not $Name){
            return Get-ProjectList
        }

        $path_list = Get-ProjectLocation -Name $Name
        foreach ($path in $path_list){
            if ($NewWindow) {
                foreach ($path in $path_list){
                    Start-Process -FilePath pwsh -WorkingDirectory $path
                }
            } else {
                Set-Location -Path $path
            }
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Open-ProjectWorkspace {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process{ 
       
        if (-not $Name){
            return Get-ProjectList
        }

        $path_list = Get-ProjectLocation -Name $Name
        if ($path_list) {
            if (Get-Command "code.cmd" -ErrorAction SilentlyContinue) {
                code --new-window --disable-gpu $($path_list -join " ")
            }
            else { 
                Write-FormattedError -Message "Visual Studio Code is not in system's path or not installed." -Module $SciProfile.Name
            }
        }   
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Open-ProjectFileExplorer {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process{ 
       
        if (-not $Name){
            return Get-ProjectList
        }

        $path_list = Get-ProjectLocation -Name $Name
        foreach ($path in $path_list){
            Start-Process -FilePath "explorer.exe" -ArgumentList $path
        }
    }
}
#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Open-ProjectBrowser {
    
    [CmdletBinding(PositionalBinding)]
    
    [OutputType([PSCustomObject])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, HelpMessage="Name or alias of an project.")]
        [System.String] $Name
    )

    Process {
       
        if (-not $Name){
            return Get-ProjectList
        }

        $web_list = Get-WebLocation -Name $Name
        foreach ($url in $web_list){
            Start-Process -FilePath $url
        }
    }
}
