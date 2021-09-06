$repo_path = "A:\Repositories"
if (-not (Test-Path -Path $repo_path)) {
    New-Item -Path $repo_path -ItemType Directory
}
