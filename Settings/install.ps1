# ===========================================================================
#   InstallProfile.ps1 ------------------------------------------------------
# ===========================================================================

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------

# set main install structure with path to folders, files and environment variables
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$pwsh_path = Split-Path -Path $path -Parent
$Install = New-Object -TypeName PSObject -Property @{
    # prerequisites
    Command = @(
        "pwsh.exe"
        "git.exe"
        "code.cmd"
    )

    # path to 
    Path = @{
        sciprofile = Join-Path -Path $pwsh_path -ChildPath "SciProfile"
        module = Join-Path -Path $pwsh_path -ChildPath "Modules"
    }

    # path to files
    File = @{}

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

    # repositories
    Repository = @{
        Requirement = @{
                "Dir" = Join-Path -Path $env:USERPROFILE -ChildPath "PSVirtualEnv\.require"
                "Url" = "https://github.com/wbrandenburger/PyVirtualEnv"
        }
    }
}


# display variables for visual inspection and check whether all variables are set
$flag_folder = $False

@("Path", "Env") | ForEach-Object {
    $property = $_

    $Install.($property).Values | ForEach-Object {
        if (-not $_){
            $flag_folder = $True
        }
    }
        
    Write-Host -Object "Property $($property):" -ForegroundColor Yellow
    $Install.($property) | Format-Table 
}

$command = @{}
$Install.Command | ForEach-Object {
    $command_info = Get-Command $_ -ErrorAction SilentlyContinue
    
    if (-not $command_info){
        $flag_folder = $True
        $command[$_] = $Null
    } else {
        $command[$_] = $command_info | Select-Object -ExpandProperty Source
    }
}
Write-Host -Object "Property Command:" -ForegroundColor Yellow
$command

Write-Host

if ($flag_folder) {
    Write-Host -Object "Some paths to files and folders or environment variables are not set or does not exist. Abort installation." -ForegroundColor Red
    return
} else {
    Write-Host -Object "All paths to files and folders or environment variables are set as well as does exist." -ForegroundColor Green
}

# set additional path to files and directories, which will be generated
$Install.File +=  @{
    install_import = Join-Path -Path $path -ChildPath "import.json"
    sciprofile_config = Join-Path -Path $Install.Env["XDG_CONFIG_HOME"] -ChildPath "sciprofile\config.ini"
    sciprofile_import = Join-Path -Path $Install.Env["XDG_CONFIG_HOME"] -ChildPath "sciprofile\config\import.json"
}

Write-Host

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Install-SciProfileModules {

    Write-Host -Object "Install or update powershell modules..." -ForegroundColor "Yellow" 

    $module_available = Get-Module -ListAvailable
    @("Module") | ForEach-Object {
        $property = $_

        $Install.($property) | ForEach-Object {
            $module = $_
            if ($module_available  | Where-Object {$_.Name -eq $module}){
                Write-Host -Object "Update $($_)..." -ForegroundColor Yellow
                # Update-Module -Name $module -ErrorAction SilentlyContinue
            } else {
                Write-Host -Object "Install $($_)..." -ForegroundColor Yellow
                
                Install-Module -Name $module -Scope "CurrentUser" -AllowClobber -Force
            }

            Write-Host -Object "Import $($_)..." -ForegroundColor Yellow

            Import-Module -Name $module -Force
        }
    }
    
    #Start-Process -FilePath pwsh -Wait -NoNewWindow

    Write-Host
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Install-SciProfileConfiguration {

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
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Install-SciProfileFile {

    Write-Host -Object "Copy files..." -ForegroundColor "Yellow" 

    @(
        @{ 
            Path = $Install.File["install_import"]
            Destination = $Install.File["sciprofile_import"]
        }
    ) | ForEach-Object {
        if (-not $(Test-Path -Path $_.Destination )) {
            Write-Host -Object "[CP] $($_.Path) $($_.Destination)." -ForegroundColor "Yellow" 
            Copy-Item -Path $_.Path -Destination $_.Destination -Force
        } else {
            Write-Host -Object "File $($_.Destination) does exist." -ForegroundColor "Green" 
        }
    }

    #Start-Process -FilePath pwsh -Wait -NoNewWindow

    Write-Host
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Install-SciProfileRepository {

    Write-Host -Object "Clone repositories..." -ForegroundColor "Yellow" 

    $Install.Repository.Values | ForEach-Object {
        Write-Host

        if (Test-Path -Path $_["Dir"]) {
            if (Test-GitWorkingTree -Path $_["Dir"]){
                Write-Host -Object "[UD] $($_['Url']) in $($_['Dir'])" -ForegroundColor Yellow
                Start-Process -FilePath "git" -Args "-C",  $_["Dir"], "pull" -NoNewWindow -Wait
                return
            } 

            Remove-Item $_["Dir"] -Recurse -Force
        }
        Write-Host -Object "[MK] $($_['Url']) to $($_['Dir'])" -ForegroundColor Yellow

        Start-Process -FilePath "git" -Args "clone", $_["Url"], $_["Dir"] -NoNewWindow -Wait

    }
    Write-Host
}

# #   function ----------------------------------------------------------------
# # ---------------------------------------------------------------------------
function Test-GitWorkingTree {
    Param(
        [System.String] $Path
    )

    if (-not $(Test-Path -Path $Path)){
        return $False
    }
    
    #Write-Host -Object "Check git repository with 'git -C $Path rev-parse --is-inside-work-tree'" -ForegroundColor Yellow

    $working_tree = git -C $Path rev-parse --is-inside-work-tree
    if(-not $($working_tree -eq "true")) {
        return $False
    }

    return $True
}

#   install -----------------------------------------------------------------
# ---------------------------------------------------------------------------
Install-SciProfileModules
Install-SciProfileConfiguration
Install-SciProfileFile
$Install.Repository["Requirement"]["Dir"] = $env:PSVIRTUALENV_REQUIRE
Install-SciProfileRepository

#   restart -----------------------------------------------------------------
# ---------------------------------------------------------------------------
Start-Process -FilePath pwsh -Wait -NoNewWindow