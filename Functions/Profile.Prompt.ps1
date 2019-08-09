# ============================================================================
#   Profile.Prompt.ps1 -------------------------------------------------------
# ============================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
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

    # displays running virtual environment, papis libraries and repository collection
    If ($Env:VIRTUAL_ENV -or $Env:PAPIS_LIB -or $Env:PSPROFILE_REPOSITORY_COLLECTION) {
        Write-Host "Active" -NoNewline -ForegroundColor DarkGreen
        If ($Env:VIRTUAL_ENV){        
            
            Write-Host "[venv-$(Split-Path $Env:VIRTUAL_ENV -leaf)]" -NoNewline -ForegroundColor Cyan
        }
        if ($Env:PAPIS_LIB){
            Write-Host "[$Env:PAPIS_LIB]"-NoNewline -ForegroundColor Cyan
        }
        If ($Env:PSPROFILE_REPOSITORY_COLLECTION){
            Write-Host "[$Env:PSPROFILE_REPOSITORY_COLLECTION]" -NoNewline -ForegroundColor Cyan
        }
    }
    Write-Host " " -NoNewline
    
    # displays location
    Write-Host ([Regex]::Replace($(Get-Location),"\\.+\\","\~\")) -NoNewline -ForegroundColor Gray 
    Write-Host " " -NoNewline

    # displays git status
    If ((Get-Module).Name -contains "Posh-Git") {
        Write-VcsStatus
    }
}
