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

Configuration PackagePSModule
{

    Import-DscResource -Module PSModule

    Node "localhost"

    LocalConfigurationManager
    {
       # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
       DebugMode = "ForceModuleImport"
    }


    PSPackageInstaller installcChoco
    {
        Ensure      = "Present"
        Name        = "cChoco"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPackageManagement
    {
        Ensure      = "Present"
        Name        = "PackageManagement"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPester
    {
        Ensure      = "Present"
        Name        = "Pester"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installposhgit
    {
        Ensure      = "Present"
        Name        = "posh-git"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPowerShellForGitHub
    {
        Ensure      = "Present"
        Name        = "PowerShellForGitHub"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPowerShellGet
    {
        Ensure      = "Present"
        Name        = "PowerShellGet"
        Source      = "PSGallery"
        DependsOn   = "[PSPackageInstaller]InstallPackageManagement"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPowerShellYaml
    {
        Ensure      = "Present"
        Name        = "powershell-yaml"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installPSReadLine
    {
        Ensure      = "Present"
        Name        = "PSReadLine"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }

    PSPackageInstaller installVSSetup
    {
        Ensure      = "Present"
        Name        = "VSsetup"
        Source      = "PSGallery"
        AutoUpgrade = $True
    }
}

PackagePSModule

Start-DscConfiguration ".\PackagePSModule" -Wait -Verbose -Force