# ===========================================================================
#   remote.ps1 --------------------------------------------------------------
# ===========================================================================

# #   function ----------------------------------------------------------------
# # ---------------------------------------------------------------------------
# function Global:Test-PulseSecure {

#     [CmdletBinding(PositionalBinding=$True)]
    
#     [OutputType([Int])]

#     Param (
#     )

#     Process{

#         $out = Start-Process -FilePath pulselauncher.exe -ArgumentList "-version" -NoNewWindow -Wait -PassThru
#     }
# }

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Start-PulseSecure {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Int])]

    Param (        
        
        [ValidateSet("https://webvpn.unibw.de")]
        [Parameter(Position=0, HelpMessage="Password.")]
        [System.String] $Url = "https://webvpn.unibw.de"
    )

    Process{

        # if (Test-PulseSecure){
        #     return
        # }

        $password = Read-Host "What is user's password of server '$Url'?" -AsSecureString
        $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

        Start-Process -FilePath pulselauncher.exe -ArgumentList "-url", $Url, "-u", "i41bwobr", "-p", "$pw", "-r", "Users" -NoNewWindow -Wait -PassThru

        # if ($out -match "Connected."){
        #     Write-FormattedSuccess -Message "Connection to '$Url' established." -Module "PulseSecure" -Space
        #     return 0
        # }
        # elseif ($out -match "Already connected."){
        #     Write-FormattedWarning -Message "Connection to '$Url' has been already established." -Module "PulseSecure" -Space
        #     return 0
        # }

        # Write-FormattedError -Message "Connection to '$Url' not established." -Module "PulseSecure" -Space
        # return 1
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Stop-PulseSecure {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Int])]

    Param (        
        
        [ValidateSet("https://webvpn.unibw.de")]
        [Parameter(Position=0, HelpMessage="Password.")]
        [System.String] $Url = "https://webvpn.unibw.de"
    )

    Process{

        # if (Test-PulseSecure){
        #     return
        # }

        Start-Process -FilePath pulselauncher.exe -ArgumentList "-signout", "-url", $Url -NoNewWindow -Wait -PassThru

        # if ($out -match "Pulse disconnected."){
        #     Write-FormattedSuccess -Message "Connection to '$Url' terminated." -Module "PulseSecure" -Space
        #     return 0
        # }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Start-TeamViewer {

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Int])]

    Param (        
        
        [ValidateSet("1598911415")]
        [Parameter(Position=0, HelpMessage="Id.")]
        [System.String] $Id = "1598911415"
    )

    Process{

        $password = Read-Host "What is user's password of computer '$Id'?" -AsSecureString
        $pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

        Start-Process -FilePath teamviewer.exe -ArgumentList "-i",  $Id, "-p", "$pw" -NoNewWindow -Wait
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Start-RemoteWBDesktop1 {
    
    Start-PulseSecure -Url "https://webvpn.unibw.de"

    Start-TeamViewer -Id "1598911415"
}