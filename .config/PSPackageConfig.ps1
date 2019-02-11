# Copyright (c) 2017 Chocolatey Software, Inc.
# Copyright (c) 2013 - 2017 Lawrence Gripper & original authors/contributors from https://github.com/chocolatey/cChoco
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Configuration PSPackageMgmtConfig
{

    Import-DscResource -Module PSPackageManager

    Node "localhost"

    LocalConfigurationManager
    {
       # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
       DebugMode = "ForceModuleImport"
    }


    PSPackageMgmt PkgcChoco
    {
        Ensure      = "Present"
        Name        = "cChoco"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPackageManagement
    {
        Ensure      = "Present"
        Name        = "PackageManagement"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPester
    {
        Ensure      = "Present"
        Name        = "Pester"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPoshGit
    {
        Ensure      = "Present"
        Name        = "posh-git"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPowerShellGet
    {
        Ensure      = "Present"
        Name        = "PowerShellGet"
        Source      = "PSGallery"
        DependsOn   = "[PSPackageMgmt]PkgPackageManagement"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPowerShellYaml
    {
        Ensure      = "Present"
        Name        = "powershell-yaml"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgPSConsoleTheme
    {
        Ensure      = "Present"
        Name        = "PSConsoleTheme"
        Source      = "PSGallery"
        AutoUpgrade = $False
    }

    PSPackageMgmt PkgPSReadLine
    {
        Ensure      = "Present"
        Name        = "PSReadLine"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageMgmt PkgVSSetup
    {
        Ensure      = "Present"
        Name        = "VSsetup"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

}

PSPackageMgmtConfig

Start-DscConfiguration .\.config -Wait -Verbose -Force