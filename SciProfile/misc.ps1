# ===========================================================================
#   misc.ps1 ----------------------------------------------------------------
# ===========================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Pull-Repositories
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(

        [System.String[]] $Repository = $Null,
        [System.String[]] $Repositories = ("config", "venv-config"),
        [System.String] $Branch = "master",
        [System.String] $Message = "automatical commit before pull",
        [Switch] $NoCommit
    ) 

    Process{

        if ($Repository) {
            $Repositories = ($Repository)
        }
        
        $Repositories | ForEach-Object {
            Write-FormattedWarning -Message "Pull repository $($_)..." -Module "GIT"

            cdx $_
            
            $git_status = git status --short
            if  ($git_status -and -not $NoCommit){
                if ($NoCommit){
                    Write-FormattedError -Message "Pending commitments." -Module "GIT"
                    return
                }
                git add *
                git commit -m $Message

            }

            git pull origin $Branch
        }
    }
}