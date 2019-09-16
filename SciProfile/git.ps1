# ===========================================================================
#   psfunctions-git.ps1 -----------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Update-Repository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param (
        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Name,

        [Parameter(Position=2, Mandatory=$False)]
        [System.String] $Branch,

        [Parameter(Position=3, Mandatory=$True)]
        [System.String] $Message,

        [Parameter()]
        [Switch] $Silent
    )
    
    # Switch to location of the repository and check whether there exist a valid repository
    $CurrentLocation = Get-Location
    Set-ProjectLocation -Name $Name
    
    if (-not ("$(git rev-parse --is-inside-work-tree)" -eq "true" )){
        Write-FormattedError -Message "In location $CurrentLocation of workspace $Name exists no valid repository." -Space
        return 1
    }

    # Check whether the repository has activated the defined branch
    if ($Branch) {
        $CurrentBranch = $(git symbolic-ref -q HEAD)
        $CurrentBranch = $CurrentBranch.replace("refs/heads/","")
        if ( -not ($CurrentBranch -eq $Branch)){
            if (-not $(git show-ref refs/heads/$Branch)) {
                Write-FormattedError -Message "Branch $Branch does not exist for repository $Name." -Space
                return 1
            }

            Write-FormattedProcess -Message "Checkout to branch $Branch from current branch $CurrentBranch." -Space

            git checkout $Branch
        }
    }
    # Commit changes in workspace and push to repository
    Write-FormattedProcess -Message "Commit changes in workspace $Name and push to repository." -Space

    $(git add *)
    $(git commit -m $Message)
    $(git push)

    Write-FormattedSuccess -Message "Updated changes in workspace $Name."  -Space

    # Switch to predefined location
    Set-Location $CurrentLocation

    return $Null
}