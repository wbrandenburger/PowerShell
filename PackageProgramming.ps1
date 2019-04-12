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

Configuration PackageProgramming
{
   Import-DscResource -Module cChoco
   
   Node "localhost"
   {  
      LocalConfigurationManager
      {
         # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
         DebugMode = 'ForceModuleImport'
      }
      
      cChocoPackageInstaller installcmake
      {
         Ensure = "Present"
         Name = "cmake.portable"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installcmake
      {
         Ensure = "Present"
         Name = "jre8"
         chocoParams = "/exclude:32"
         AutoUpgrade = $True
      }     

      cChocoPackageInstaller installgit
      {
         Ensure = "Present"
         Name = "git"
         chocoParams = "/GitAndUnixToolsOnPath /SChannel	/WindowsTerminal"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installnodejs
      {
         Ensure = "Absent"
         Name = "nodejs"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installnvm
      {
         Ensure = "Absent"
         Name = "nvm.portable"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installpandoc
      {
         Ensure = "Present"
         Name = "pandoc"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installpowershellcore
      {
         Ensure = "Present"
         Name = "powershell-core"
         chocoParams = "/CleanUpPath"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installsumatrapdf
      {
         Ensure = "Present"
         Name = "sumatrapdf.commandline"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installvscode
      {
         Ensure = "Present"
         Name = "vscode"
         chocoParams = "/NoDesktopIcon	/NoQuicklaunchIcon /NoContextMenuFiles	/NoContextMenuFolders"
      }

   }
}

PackageProgramming

Start-DscConfiguration -Path ".\PackageProgramming" -Wait -Verbose -Force