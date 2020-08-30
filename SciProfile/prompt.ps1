# ============================================================================
#   Modify-Prompt.ps1 --------------------------------------------------------
# ============================================================================

[System.Environment]::SetEnvironmentVariable("VIRTUAL_ENV_DISABLE_PROMPT","True","process")

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Prompt {

    Write-PromptTime -Color "DarkCyan"              # display current time
    Write-PromptAdmin -Value "Admin" -Color "Red"   # display admin

    Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor "Gray"
    
    # Write-Host " " -NoNewline -ForegroundColor "Gray"

    If ((Get-Module).Name -contains "Posh-Git") {   # displays git status
        Write-VcsStatus
        Write-Host " " -NoNewline -ForegroundColor "Gray"
    }
        
    if ($ENV:PSVIRTUALENV_PROJECT) {
        Write-VirtualEnvStatus
        Write-Host " " -NoNewline -ForegroundColor "Gray"
    }

    if ($ENV:PSPOCS_PROJECT) {
        Write-PocsLibStatus
        Write-Host " " -NoNewline -ForegroundColor "Gray"
    }

    if ($Env:EXPMGMT_PROJECT) {
        Write-PromptEnvStatus -Env "Exp" -Value $Env:EXPMGMT_PROJECT
        Write-Host " " -NoNewline -ForegroundColor "Gray"
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Write-PromptEnvStatus {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Env,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Value,

        [Parameter(Mandatory=$False)]
        [System.String] $EnvColor = "DarkGray",

        [Parameter(Mandatory=$False)]
        [System.String] $ParenColor = "Yellow",

        [Parameter(Mandatory=$False)]
        [System.String] $ValueColor = "Cyan"

    )
    
    Process{

        If ($Value) {       
            Write-Host $Env -NoNewline -ForegroundColor $EnvColor
            Write-Host "["  -NoNewline -ForegroundColor $ParenColor
            Write-Host  $Value -NoNewline -ForegroundColor $ValueColor
            Write-Host  "] " -NoNewline -ForegroundColor $ParenColor
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Write-PromptAdmin{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$False)]
        [System.String] $Value = "Admin",

        [Parameter(Position=2, Mandatory=$False)]
        [System.String] $Color = "Red"

    )

    Process{

        # check whether the host as administrator rights
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        $checkAs = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        If ($checkAs) { 
            Write-Host "($Value) " -NoNewline -ForegroundColor $Color
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Write-PromptTime {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$False)]
        [System.String] $Color = "DarkCyan"

    )

    Process{

        Write-Host "[" -NoNewline -ForegroundColor $Color
        Write-Host (Get-Date -UFormat %R) -NoNewline -ForegroundColor $Color
        Write-Host "] " -NoNewline -ForegroundColor $Color
    
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Write-PromptLocation {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$False)]
        [System.String] $Color = "Gray"

    )

    Process {

        Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor $Color
        Write-Host " " -NoNewline

    }
}