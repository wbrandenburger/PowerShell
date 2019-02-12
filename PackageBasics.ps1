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

Configuration PackageBasics
{
   Import-DscResource -Module cChoco
   
   Node "localhost"
   {  
      LocalConfigurationManager
      {
         # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
         DebugMode = 'ForceModuleImport'
      }
      
      cChocoInstaller installchoco
      {
        InstallDir = "C:\Packages"
      }

      cChocoPackageInstaller install7zip
      {
         Ensure = "Present"
         Name = "7zip.portable"
         AutoUpgrade = $True
         DependsOn = "[cChocoInstaller]installChoco"
      }

      cChocoPackageInstaller installadobereader
      {
         Ensure = "Present"
         Name = "adobereader"
         chocoParams = "/NoUpdates"
         AutoUpgrade = $True
         DependsOn = "[cChocoInstaller]installChoco"
      }

      cChocoPackageInstaller installcmail
      {
         Ensure = "Present"
         Name = "cmail"
         AutoUpgrade = $True
         DependsOn = "[cChocoInstaller]installChoco"
      }

      cChocoPackageInstaller installedgedeflector
      {
         Ensure = "Present"
         Name = "edgedeflector"
         AutoUpgrade = $True
         DependsOn = "[cChocoInstaller]installChoco"
      }      

      cChocoPackageInstaller installfirefox
      {
         Ensure = "Present"
         Name = "firefox"
         AutoUpgrade = $True
         DependsOn = "[cChocoInstaller]installChoco"
      }

      cChocoPackageInstaller installirfanview
      {
         Ensure = "Present"
         Name = "irfanview"
         AutoUpgrade = $True
         chocoParams = "/assoc=1	/ini=%APPDATA%\IrfanView"
         DependsOn = "[cChocoInstaller]installChoco"
      }
   }
}

PackageBasics

Start-DscConfiguration  -Path ".\PackageBasics"  -Wait -Verbose -Force