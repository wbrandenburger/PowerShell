# Installation

## UniBw

* Pulse Secure - Microsoft Store
  * `https://webvpn.unibw.de` (UniBwM)
* [Sophos](https://webvpn.unibw.de/rz/dienste-und-leistungen/it-sicherheit/,DanaInfo=www.unibw.de,SSL+virenschutz)
* TeamDrive, use `install-teamdrive.ps1`.
* TeamWire, use `install-teamwire.ps1`.
* Webex, download from `https://www.webex.com/de/downloads.html` and get further instructions from `https://wiki.unibw.de/display/FAQ/Cisco+WebEx+Meetings`
  
## PowerShell

### [PowerShell](https://github.com/PowerShell/PowerShell/releases)

### [Chocolatey](https://chocolatey.org/install)

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## [Visual Studio 2019 Build Tools](https://community.chocolatey.org/packages/visualstudio2019buildtools#install)

```PowerShell
choco install visualstudio2019buildtools
```

## [Visual Studio Code](https://community.chocolatey.org/packages/vscode)

```PowerShell
choco install vscode --params "/NoQuicklaunchIcon /NoDesktopIcon"
```

Install `Settings Sync`

## Python

Use `install-python.ps1`.

## Docker

### [Docker Desktop](https://community.chocolatey.org/packages/docker-desktop)

```PowerShell
choco install docker-desktop
```

### [Download Linux Kernel Update Package](https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-4---download-the-linux-kernel-update-package)

Use `install-docker.ps1`

### [Git](https://community.chocolatey.org/packages/git)

```PowerShell
choco install git --params "/GitAndUnixToolsOnPath  /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration /SChannel"
git config --global user.name "Wolfgang Brandenburger"
git config --global user.email "w.brandenburger@unibw.de"
```

## LaTeX

* [TeX Live Installer](https://community.chocolatey.org/packages/texlive)
* [TinyTeX](https://community.chocolatey.org/packages/tinytex)

## Miscellaneous

### Chocolatey

* [Adobe Acrobat Reader DC](https://community.chocolatey.org/packages/adobereader)
* [7zip](https://community.chocolatey.org/packages/7zip/19.0)
* [Google Earth Pro](https://community.chocolatey.org/packages/googleearthpro)
* IrfanView
  * [IrfanView](https://community.chocolatey.org/packages/IrfanView)
  * If no parameters are passed, the following is assumed: --params '/assoc=1 /group=1 /ini=%APPDATA%\IrfanView'.
  * [IrfanViewPlugins](https://community.chocolatey.org/packages/irfanviewplugins)
<!-- * [Apache OpenOffice](https://community.chocolatey.org/packages/OpenOffice) -->
* [Putty](https://community.chocolatey.org/packages/putty)
* [TCP/IP Manager](https://community.chocolatey.org/packages/tcpipmanager)
* [TeamViewer](https://community.chocolatey.org/packages/teamviewer)
* [WinSCP](https://community.chocolatey.org/packages/winscp)

```PowerShell
choco install adobereader --params "/NoUpdates /UpdateMode:4"
choco install 7zip
choco install googleearthpro
choco install irfanview
choco install irfanviewplugins
choco install putty
# choco install openoffice --params "'/locale:de'"
choco install tcpipmanager
choco install teamviewer
choco install winscp
```

### Provider

* Sophos
* MathPix