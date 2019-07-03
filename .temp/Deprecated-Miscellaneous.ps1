=============================================================================
   PowerShell Cmdlets
=============================================================================

@ToDo Choco Install - Add copy Tab-Completion folder

@Note[Regex] "([^\\]*)\.[^\.]*$" Get Filename with multiple dot without extensionq
@Note[Regex] "([^\\]*)$" Get Filename with multiple dot
@Note[Regex] "\\.+\\" Get the content between directory and Filename
    If(Test-Path -Path $PathVcPkg ) {
        Write-Verbose "Path $PathVcPkg exists." 
    }
    Else {
        Write-Verbose "Path $PathVcPkg does not exists."
        
        # New-Item -Path  $env:Repositories -Name $VcPkg -ItemType Directory
        # If(Test-Path -Path $PathVcPkg ) {
        #     Write-Verbose "Directory $PathVcPkg created." 
        # }
    }


function ConvertTo-ArrayList ( [PSCustomObject] $CustomObject, [System.String] $Property) {

        #$ObjectProperties = $CustomObject.PSObject.Properties
    
        #$IntermediateHashtable = @{}
    
        #foreach ( $Property in $ObjectProperties ) {
    
        #    $IntermediateHashtable."$($Property.Name)" = $Property.Value
    
        #}
    
        #$ArrayList = [System.Collections.ArrayList]$IntermediateHashtable
        $array_list = [System.Collections.ArrayList]::New()
        foreach ($bla in $CustomObject.Name) {
            [Void] $array_list.Add($bla)
        }
        
        return $array_list
    
}

Function Move-TempToProject 
{
    
    [CmdletBinding(PositionalBinding=$True, ConfirmImpact="Medium", SupportsShouldProcess=$True)]
    
    [OutputType([Void])]
    
    Param (
        [Parameter(Position=1, HelpMessage="Name of the Project, where the file shall be moved")]
        [System.String] $Project,

        [Parameter(HelpMessage="Folder literature in the project")]
        [Switch] $Bib,

        [Parameter(HelpMessage="Folder Images in the project")]
        [Switch] $Img
    )
    
    Process {

        Write-Host (Get-Clipboard -Format Text)
        If ($Bib) {
            $Folder = "Literature"
        }

        If ($Img) {
            $Folder = "Images"
        } 
        
        $File = (Get-ChildItem -Path $env:SHARED_TEMP | Sort-Object -Property LastWriteTime -Descend)[0].Name
        $FilePath = Join-Path -Path $env:SHARED_TEMP -ChildPath $File

        $DestinationPath = Join-Path -Path $env:SHARED_WORK -ChildPath "$Project"
        If( -not (Test-Path $DestinationPath)) {
            Write-Error "Project $Project does not exist. Specify exisiting project."
        }

        $Destination = Join-Path -Path $DestinationPath -ChildPath "$Folder\$File"

        If ($PSCmdlet.ShouldProcess("Should the file be moved?")) {
            Move-Item -Path $FilePath -Destination $Destination -Verbose:$VerbosePreference -Force
        }
    }
}

#-------------------------------------------------------------------------------
#   Set-Environment
#-------------------------------------------------------------------------------
Function Set-Environment
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None", PositionalBinding=$True)]
    
    [OutputType([Void])]

    Param
    (
    )

    If ($PSCmdlet.ShouldProcess("Should environment variables get changed?")){
    . "$Env:LOCAL_PS\Environment.ps1"
    }
}

#-------------------------------------------------------------------------------
#   Open-VSProject
#-------------------------------------------------------------------------------
Function Open-VSProject
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param
    (
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="Path, which contains a project folder")]
        [System.String] $Path = $Null,

        [Parameter(Mandatory=$False, ValueFromPipeline=$True, HelpMessage="Workspace, which contains a project folder")]
        [System.String] $Project = $Null
    )

    Process {

        If ($Project) {
            $Path = Join-Path -Path $env:SHARED_WORK -ChildPath $Project
        }

        If ($Path) {
            Start-Process -FilePath Code -ArgumentList "--new-window  $Path" -NoNewWindow
        }
# @Question Do I need opening multirootfolders --add <dir>
    }
}

#-------------------------------------------------------------------------------
#   Update-PSGit
#-------------------------------------------------------------------------------
Function Update-PSGit
{
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact="None",PositionalBinding=$True)]

    [OutputType([Void])]

    Param (
        [Parameter(Position=1, Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Name of file, which contains a documentation file")]
        [Alias("m")]
        [System.String] $Message 
    )

    Process {
        If ($PSCmdlet.ShouldProcess("Push changes of local powershell workspace to remote repository?")) {
            Start-Process -FilePath sh.exe -ArgumentList "GitAddCommitPush.sh $Env:LOCAL_PS $Message" -Wait -NoNewWindow
        }
    }

}
