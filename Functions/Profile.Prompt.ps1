# ============================================================================
#   Profile.Prompt.ps1 -------------------------------------------------------
# ============================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Prompt {

    Write-PromptTime -Color "DarkCyan"              # display current time
    Write-PromptAdmin -Value "Admin" -Color "Red"   # display admin

    Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor "Gray"
    # Write-Host " " -NoNewline -ForegroundColor "Gray"

    If ((Get-Module).Name -contains "Posh-Git") {   # displays git status
        Write-VcsStatus
        Write-Host " " -NoNewline -ForegroundColor "Gray"
    }

    Write-PromptEnvStatus -Env "Venv" -Value (Split-Path $Env:VIRTUAL_ENV -leaf)
    Write-PromptEnvStatus -Env "Papis" -Value $Env:PAPIS_LIB
    Write-PromptEnvStatus -Env "Collection" -Value  $Env:PSPROFILE_REPOSITORY_COLLECTION
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Write-PromptEnvStatus {

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
        [System.String] $ValueColor = "Yellow"

    )
    
    Process{

        If ($Value) {       
            Write-Host $Env -NoNewline -ForegroundColor $EnvColor
            Write-Host "[$Value] " -NoNewline -ForegroundColor $ValueColor
        }
        
        return 0

    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Write-PromptAdmin{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param (

        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Value = "Admin",

        [Parameter(Mandatory=$False)]
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
function Write-PromptTime {

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
function Write-PromptLocation {

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