# [PowerShellProject](https://github.com/wbrandenburger/PowerShellProject)

## Table of Contents

- [PowerShellProject](#powershellproject)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Arrangement](#arrangement)
    - [Proceeding](#proceeding)
  - [PowerShell Modules](#powershell-modules)
  - [Authors/Contributors](#authorscontributors)
    - [Author](#author)

## Description

This repository contains a PowerShell profile with the focus on scientific work with Python and C++.

## Installation

### Prerequisites

For full functionality, the following packages have to be installed:

- [PowerShell Core](https://github.com/PowerShell/PowerShell)
- [Python 3](https://www.python.org/)
- [Git](https://git-scm.com/)

### Arrangement

Set following environment variables manually

- `XDG_CONFIG_HOME` to existing default configuration folder, e.g. `C:\Users\Name\.config`
- `PYTHONHOME` to existing folder of system's python distribution

### Proceeding

- Clone this repository into the local powershell path, generally `C:\Users\User\Documents\PowerShell`
- Start a new powershell session and invoke file `.\Settings\install.ps1` via dot sourcing. Do not forget to change execution policy of powershell.

## PowerShell Modules

The following PowerShell module will be automatically installed:

- [SciProfile](https://github.com/wbrandenburger/SciProfile)
- [PSPocs](https://github.com/wbrandenburger/PSPocs)
- [PSVirtualEnv](https://github.com/wbrandenburger/PSVirtualEnv)
- [PSIni](https://github.com/lipkau/PsIni)

## Authors/Contributors

### Author

- [Wolfgang Brandenburger](https://github.com/wbrandenburger)
