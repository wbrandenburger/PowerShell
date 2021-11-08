# ===========================================================================
#   Profile.ps1 -------------------------------------------------------------
# ===========================================================================

#   import ------------------------------------------------------------------
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable | Where-Object {$_.Name -eq "SciProfile"}){
    # import main module
    Import-Module SciProfile

    # import user defined module
    Write-Host
    Import-PSMModule

    # import user defined functions
    Import-PSMFunction

    # activate autocompletion
    . (activate-sci)
}

#   settings ----------------------------------------------------------------
# ---------------------------------------------------------------------------
Set-PSReadlineKeyHandler -Chord Alt+F4 -Function ViExit # 'alt+F' or 'alt+space c'
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -BellStyle None

function Open-History {
    # Get-Content (Get-PSReadlineOption).HistorySavePath
    $file_path = (Get-PSReadlineOption).HistorySavePath
    code -n $file_path
}

function Start-DEMShell{

  Param (
    [Parameter(Position = 0, Mandatory = $True)]
    [ValidateSet('default', 'all', 'dqp-db', 'gsp-db', 'dem-db', 'db', 'dqp', 'gsp', 'rs-gsp', 'rs-dem', 'rs-dqp')]
    [string] $server,

    [ValidateSet('localhost', 'system')]
    [string] $ip
  )
  
  if ($server -ne "default") {
    $cmd =  "Start-DEMServer -server $server"
  }
  if ($ip) { $cmd += " -ip $ip"}

  Start-Process pwsh -ArgumentList @("-noexit -command
    cd $env:DEM_HOME;
    . .\init.ps1;
    `"$cmd`";
  ")
}

function Start-DEMShellServer {
  Start-DEMShell -all
}

function Start-DEMDevelopment {
  Start-DEMShell -server db
  Start-DEMShell -server rs-gsp -ip system
  
  Start-Sleep -Seconds 5
  Start-DEMShell -server gsp 
  Start-Process code -ArgumentList $env:DEM_HOME
}


$DEM_GIT_INTERNSHIP =  @("feature/students", "feature/data-preparation", "feature/visualization", "feature/patch-generation")
$DEM_GIT_ALL =  @("main", "dev", "feature/students", "feature/data-preparation", "feature/visualization", "feature/patch-generation")

function Invoke-GitInternship {
  Param(
    [Parameter(Mandatory=$True)]
    $branch,
    [Parameter(Mandatory = $True)]
    [system.string[]] $branches
  )

  $branches | ForEach-Object {
    git checkout $_
    git merge $branch
    git push origin $_
  }
  git checkout $branch
}

function ipy { python .\run.py }