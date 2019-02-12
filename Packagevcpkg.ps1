# Copyright (c) 2017 vcpkglatey Software, Inc.
# Copyright (c) 2013 - 2017 Lawrence Gripper & original authors/contributors from https://github.com/vcpkglatey/vcpkg
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

Configuration Packagevcpkg
{
   Import-DscResource -Module vcpkg
   
   Node "localhost"
   {  
      LocalConfigurationManager
      {
         # https://docs.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig
         DebugMode = 'ForceModuleImport'
      }
      
      vcpkgInstaller installvcpkg
      {
        InstallDir = $env:Repositories
      }

      vcpkgPackageInstaller installgdal
      {
         Ensure = "Present"
         Name = "gdal"
         vcpkgParams = ""
         AutoUpgrade = $True
         DependsOn = "[vcpkgInstaller]installvcpkg"
      }

      vcpkgPackageInstaller installeigen3
      {
         Ensure = "Present"
         Name = "eigen3"
         vcpkgParams = "/NoUpdates"
         AutoUpgrade = $True
         DependsOn = "[vcpkgInstaller]installvcpkg"
      }

      vcpkgPackageInstaller installopencv
      {
         Ensure = "Present"
         Name = "gdal"
         vcpkgParams = ""
         AutoUpgrade = $True
         DependsOn = "[vcpkgInstaller]installvcpkg"
      }

      vcpkgPackageInstaller installopencvvtk
      {
         Ensure = "Present"
         Name = "opencv[vtk]"
         vcpkgParams = ""
         AutoUpgrade = $True
         DependsOn = "[vcpkgPackageInstaller]installopencv"
      }   
}

Packagevcpkg

Start-DscConfiguration  -Path ".\Packagevcpkg"  -Wait -Verbose -Force