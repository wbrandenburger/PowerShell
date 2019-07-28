# ==============================================================================
#   Profile.Prompt.ps1 ---------------------------------------------------------
# ==============================================================================

#   function -------------------------------------------------------------------
# ------------------------------------------------------------------------------
Function Prompt 
{

    # display current time
    Write-Host "[" -NoNewline -ForegroundColor DarkCyan
    Write-Host (Get-Date -UFormat %R) -NoNewline -ForegroundColor DarkCyan
    Write-Host "] " -NoNewline -ForegroundColor DarkCyan
    
    # displays administrator

        # check whether the host as administrator rights
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        $checkAs = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    If ($checkAs) { 
        Write-Host "(Admin) " -NoNewline -ForegroundColor Red
    }

    # displays running virtual environment
    If ($Env:VIRTUAL_ENV){        
        Write-Host "VirtualEnv[$(Split-Path $Env:VIRTUAL_ENV -leaf)]" -NoNewline -ForegroundColor DarkRed
        if ($Env:PAPIS_LIBRARY){
            Write-Host "[$Env:PAPIS_LIBRARY]"-NoNewline -ForegroundColor DarkMagenta
        }
        Write-Host " " -NoNewline
    }

    # displays location
    Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor DarkGreen 
    Write-Host " " -NoNewline

    # displays git status
    If ((Get-Module).Name -contains "Posh-Git") {
        Write-VcsStatus
    }
}
