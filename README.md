# [PowerShellProject](https://github.com/wbrandenburger/PowerShellProject)

## Table of Contents

- [PowerShellProject](#powershellproject)
  - [Table of Contents](#table-of-contents)
  - [Description](#description)
  - [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Settings](#settings)
  - [Available Commands](#available-commands)
  - [Examples](#examples)
  - [Authors/Contributors](#authorscontributors)
    - [Author](#author)

## Description

This repository contains a PowerShell profile with the focus on scientific work with python and C++.

## Installation

## Dependencies

The following PowerShell module will be automatically installed:

- [PSIni](https://github.com/lipkau/PsIni)

## Settings

PowerShellProject creates automatically a configuration file in folder `%USERPRFOFILE%\.config\powershellproject`. Moreover, PowerShellProject searches for configuration directories in environment variable `%XDG_CONFIG_HOME%` and `%XDG_CONFIG_DIRS%`. It is recommended to use a predefined configuration folder  across several projects.

```ini
[settings]

; description
field = value
```

An module specific extension of `PSIni` enables the exploitation of a reference fields `reference-field` inside a section, which can be applied via `%(reference-field)s`. This pattern will be replaced with the value defined in `reference-field`. If the defined reference field exists not in section, system's environment variables will be evaluated and, if any, used for replacing the pattern.

The other settings in section `PowerShellProject` are not relevant to standard user.

## Available Commands

| Command                  | Alias        | Description                                                                                 |
|--------------------------|--------------|---------------------------------------------------------------------------------------------|
| `function` | `alias`    | Description.                                               |

## Examples

Get an overview of all functions and aliases with powershell built-in command `Get-Command`:

```log
Get-Command -Module PSVirtualEnv

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           alias                                              0.5.0      PowerShellProject
...
Function        function                                           0.5.0      PowerShellProject
...
```

Get detailed information about module function with powershell built-in command `Get-Help`.

## Authors/Contributors

### Author

- [Wolfgang Brandenburger](https://github.com/wbrandenburger)
