$repo_path = "A:\Repositories"
if (-not (Test-Path -Path $repo_path)) {
    New-Item -Path $repo_path -ItemType Directory
}

$tempFolderPath = Join-Path $Env:Temp $(New-Guid)
New-Item -Type Directory -Path $tempFolderPath | Out-Null

git clone https://github.com/wbrandenburger/PSVirtualEnvConfig $tempFolderPath 
Move-Item $tempFolderPath A:\VirtualEnv --Force

# git clone https://github.com/wbrandenburger/EvalObjD A:\Repositories\EvalObjD 
# git clone https://github.com/wbrandenburger/ObjGis A:\Repositories\ObjGis
# git clone https://github.com/wbrandenburger/Strato A:\Repositories\WebAPI-Strato