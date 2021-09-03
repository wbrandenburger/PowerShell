. "./AutomatedInstallation/utils.ps1"

# Downloading Python

$id = 'Python - 3.7.9'
$msi_python = Join-Path -Path $temp_path -ChildPath "python-3.7.9.exe"
$url_python = "https://www.python.org/ftp/python/3.7.9/python-3.7.9-amd64.exe" # 3.7.9

# $id = 'Python - 3.9.6'
# $msi_python = Join-Path -Path $temp_path -ChildPath "python-3.9.6.exe"
# $url_python = "https://www.python.org/ftp/python/3.9.6/python-3.9.6-amd64.exe" # 3.9.6

$result = getInstaller -Path $msi_python -Url $url_python -Identifier $id
if ($env:AutoInstall -and -not $result){. $msi_python }

if ($env:AutoSetEnvironment){
    Set-EnvVariable "PYTHONHOME" -Value ( $env:LOCALAPPDATA | Join-Path -ChildPath "Programs" | Join-Path -ChildPath "Python" | Join-Path -ChildPath "Python37")  -Scope "user"
}
