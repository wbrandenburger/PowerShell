# ============================================================================
#   psfunctions-latex.ps1 ----------------------------------------------------
# ============================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Move-LaTeXBuild {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param(

        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Path,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Build
    )

    Process {

        $libraryLfs = Join-Path -Path "A:\Dropbox\Literature\Documents-Pdf" -ChildPath (Split-Path -Path $Path -Leaf)
        $buildDirectory = $Build

        If (-not (Test-Path $buildDirectory) -and -not (Test-Path $libraryLfs)) {
            Return
        }


        Get-ChildItem -Path $buildDirectory -Include "*.pdf" -Recurse | ForEach-Object{

            $destination = Join-Path -Path $libraryLfs -ChildPath (Split-Path -Path $_ -Leaf)
            If (Test-Path $destination) {
                Remove-Item -Path $destination -Recurse -Force
            }

            #$file_relative_old = $_ -replace ($Path -replace "\\", "\\"), ""
            Write-FormattedProcess -Message "[MV] '$_' to '$destination"

            Copy-Item -Path $_ -Destination $destination -Force
        }


        Get-ChildItem -Path $buildDirectory -Directory | ForEach-Object{

            $destination = Join-Path -Path $libraryLfs -ChildPath (Split-Path -Path $_ -Leaf)
            If (Test-Path $destination) {
                Remove-Item -Path $destination -Recurse -Force
            }

            Write-FormattedProcess -Message "[MV] '$_' to '$destination"

            Move-Item -Path $_ -Destination $destination -Force 
        }

    }
}