# $env:AutoInstall = $Null
# $env:AutoSetEnvironment = $Null

function getInstaller {
    Param(
        [String] $Path,
        [String] $Url,
        [String] $Identifier = 'Installer'
    )

    if (-not (Test-Path -Path $Path)) {
        Write-FormattedProcess -Message "Download of $($Identifier)"
        Write-FormattedProcess -Message "$($Url) -> $($Path)"

        $webclient = New-Object System.Net.WebClient 
        $webclient.DownloadFile($Url, $Path)    
        # curl --output $Path --url $Url
        if (-not (Test-Path -Path $Path)) {
            Write-FormattedError -Message "Download of $($Identifier) failed"
            return 1
        }
        else {
            Write-FormattedSuccess -Message "$($Identifier) successfully downloaded"
        }        
    }
    else {
        Write-FormattedWarning -Message "$($Identifier) has already been downloaded"
    }
}

$temp_path = './.temp'

if (-not (Test-Path -Path $temp_path)) {
    New-Item -Path $temp_path -ItemType Directory
}