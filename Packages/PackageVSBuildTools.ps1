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

Configuration PackageVSBuildTools
{
   Import-DscResource -Module cChoco
   
   Node "localhost"
   {  
      LocalConfigurationManager
      {
         # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
         DebugMode = 'ForceModuleImport'
      }
      
      cChocoPackageInstallerSet installvcredistxxxx
      {
         Ensure = "Present"
         Name = @(
         "vcredist2008"
         "vcredist2010"
         "vcredist2013"
         "vcredist2017"
		   )
      }

      cChocoPackageInstaller installvisualstudio2017buildtools
      {
         Ensure = "Present"
         Name = "visualstudio2017buildtools"
      }

      cChocoPackageInstaller installwindowssdk10
      {
         Ensure = "Present"
         Name = "windows-sdk-10.1"
         AutoUpgrade = $True
      }

      cChocoPackageInstaller installwindowssdk8
      {
         Ensure = "Absent"
         Name = "windows-sdk-8.1"
      }

   }
}

PackageVSBuildTools

Start-DscConfiguration  -Path ".\PackageVSBuildTools"  -wait -verbose -force