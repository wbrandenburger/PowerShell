# ===========================================================================
#   InstallProfile.ps1 ------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------

# set main install structure with path to folders, files and environment variables
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$pwsh_path = Split-Path -Path $path -Parent
$Install = New-Object -TypeName PSObject -Property @{
    # path definitions
    Path = @{
        sciprofile = Join-Path -Path $pwsh_path -ChildPath "SciProfile"
        module = Join-Path -Path $pwsh_path -ChildPath "Modules"
    }
    # files
    File = @{
        import = Join-Path -Path $path -ChildPath "import.json"
    }
    # environment variables
    Env = @{
        XDG_CONFIG_HOME = [System.Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME")
        PYTHONHOME = [System.Environment]::GetEnvironmentVariable("PYTHONHOME")
    }
    # powershell module
    Module = @(
        "PSIni"
        "PSVirtualEnv"
        "PSPocs"
        "SciProfile"
    )
}

$Install.File["sciprofile_config"] = Join-Path -Path $Install.Env["XDG_CONFIG_HOME"] -ChildPath "sciprofile\config.ini"
$Install.File["sciprofile_import"] = Join-Path -Path $Install.Env["XDG_CONFIG_HOME"] -ChildPath "sciprofile\config\import.json"

# display variables for visual inspection and check whether all variables are set
$flag_folder = $False
@("Path", "File", "Env") | ForEach-Object {
    $property = $_
    
    Write-Host -Object "Property $($property):" -ForegroundColor Yellow
    $Install.($property) | Format-Table
    $Install.($property).Values | ForEach-Object {
        if (-not $_ -or -not $(Test-Path -Path $_)){
            $flag_folder = $True
        }
    }
}

# 
if ($flag_folder) {
    Write-Host -Object "Some paths to files and folders or environment variables are not set or does not exist. Abort installation." -ForegroundColor Red
    return
} else {
    Write-Host -Object "All paths to files and folders or environment variables are set as well as does exist." -ForegroundColor Green
}

Write-Host

#   install -----------------------------------------------------------------
# ---------------------------------------------------------------------------
Write-Host -Object "Install or update powershell modules..." -ForegroundColor "Yellow" 

$module_available = Get-Module -ListAvailable
@("Module") | ForEach-Object {
    $property = $_

    $Install.($property) | ForEach-Object {
        $module = $_
        if ($module_available  | Where-Object {$_.Name -eq $module}){
            Write-Host -Object "Update $($_)..." -ForegroundColor Yellow
            Update-Module -Name $module -Force
        } else {
            Write-Host -Object "Install $($_)..." -ForegroundColor Yellow
            Install-Module -Name $module -Scope "CurrentUser" -AllowClobber -Force 
        }
    }
}

Write-Host

#   configuration -----------------------------------------------------------
# ---------------------------------------------------------------------------
Write-Host -Object "Set fields in configuration file..." -ForegroundColor "Yellow" 

$config_content = Get-IniContent -FilePath $Install.File["sciprofile_config"]
@(
    @{ 
        NameValuePairs = @{"module-dir"=$Install.Path["module"]}
        Sections = "sciprofile"
    }
    @{
        NameValuePairs = @{"scripts-dir"=$Install.Path["sciprofile"]}
        Sections ="user"
    }
) | ForEach-Object {
    $config_content = $config_content | Set-IniContent -NameValuePairs $_.NameValuePairs -Sections $_.Sections 
}
$config_content | Out-IniFile $Install.File["sciprofile_config"] -Force -Pretty -Loose

Write-Host

#   files -------------------------------------------------------------------
# ---------------------------------------------------------------------------
Write-Host -Object "Copy files..." -ForegroundColor "Yellow" 

@(
    @{ 
        Path = $Install.File["import"]
        Destination = $Install.File["sciprofile_import"]
    }
) | ForEach-Object {
    if (-not $(Test-Path -Path $_.Path )) {
        Write-Host -Object "[CP] $($_.Path) $($_.Destination)." -ForegroundColor "Yellow" 
        Copy-Item -Path $_.Path -Destination $_.Destination -Force
    } else {
        Write-Host -Object "File $($_.Destination) does exist." -ForegroundColor "Green" 
    }
}

Start-Process -FilePath pwsh -Wait -NoNewWindow
