# ===========================================================================
#   Module-Tools.ps1 --------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Set-PocsLibrary {

    <#
    .DESCRIPTION
        Set environment variable for using literature and document manager in current session.
    
    .PARAMETER Name

    .OUTPUTS 
        None.
    #>

    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(
        [Parameter(Position=1, HelpMessage="Name of literature and document library.")]
        [System.String] $Name,

        [Parameter(Position=2, HelpMessage="Name of virtual environment, which should be started.")]
        [System.String] $VirtualEnv
    )

    Process {
        # checks whether a literature and document manager session has been already running
        $pocs_lib_old = Get-ActivePocsLib
        if($pocs_lib_old) {
            [System.Environment]::SetEnvironmentVariable($PSPocs.ProjectEnvOld, $pocs_lib_old, "process")
        }

        # start literature and document manager session
        if ($Name) {

            #set literature and document manager environment variable
            [System.Environment]::SetEnvironmentVariable($PSPocs.ProjectEnv, $Name,"process")
        }

        # start corresponding virtual environment
        if ($VirtualEnv -or $PSPocs.Library.VirtualEnv) {
            $venv = $VirtualEnv
            if (-not $venv) {
                $venv = ($PSPocs.Library | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty VirtualEnv)
            }
            Set-VirtualEnv -Name $venv
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Restore-PocsLibrary{
    <#
    .DESCRIPTION
        Restore environment variable, which are set by Set-PocsLibrary.

    .PARAMETER VirtualEnv

    .OUTPUTS 
        None.
    #>
    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param (
        [Parameter(HelpMessage="Possible running virtual environments will be stopped.")]
        [Switch] $VirtualEnv
    )

    Process {
        # stop literature and document manager session
        [System.Environment]::SetEnvironmentVariable($PSPocs.ProjectEnv, $Null,"process")

        # restart previously running literature and document manager session 
        $pocs_lib_old = [System.Environment]::GetEnvironmentVariable($PSPocs.ProjectEnvOld, "process")
        if($pocs_lib_old) {
            [System.Environment]::SetEnvironmentVariable($PSPocs.ProjectEnvOld, $Null, "process")
            Set-PocsLibrary -Name $pocs_lib_old
        }

        if ($VirtualEnv) {
            Restore-VirtualEnv
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-ActivePocsLib {

    <#
    .DESCRIPTION
        Detects activated literature and document manager session.

    .OUTPUTS 
        System.String. Activated literature and document manager session.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.String])]

    Param()
        
    Process {
        $pocs_lib = [System.Environment]::GetEnvironmentVariable($PSPocs.ProjectEnv, "process")

        if ($pocs_lib) {
            return $pocs_lib
        }
    }
}


#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function New-TemporaryConfig {

    <#
    .DESCRIPTION
        Creates a temporary file and writes libraries to this.

    .PARAMETER Library

    .PARAMETER Open

    .INPUTS
        System.Object. Library

    .OUTPUTS 
        System.String. Activated literature and document manager session.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.String])]

    Param(

        [Parameter(Position=1, ValueFromPipeline, HelpMessage="Literature and document libraries.")]
        [System.Object] $Library,

        [Parameter(Position=1, ValueFromPipeline, HelpMessage="If switch is true, the created file will be opened in system's editor.")]
        [Switch] $Open
    )
    
    Process {

        # create a config file and write specified libraries to file
        $temp_file = New-TemporaryFile -Extension ".ini"
        $Library | Out-IniFile -FilePath $temp_file -Force -Loose -Pretty
        
        # open if corresponding switch is true
        if ($Open) {
            Start-Process -FilePath "code" -NoNewWindow -ArgumentList "--new-window",  "--disable-gpu", $temp_file
        }

        return $temp_file
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function New-ConfigBackup {

    <#
    .DESCRIPTION
        Creates a backup file for configuration file.

    .PARAMETER Library

    .OUTPUTS 
        None. 
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([Void])]

    Param(

        [Parameter(Position=1, HelpMessage="Structure of library, containing details about the composition of sections.")]
        [System.Object] $Structure,

        [Parameter(HelpMessage="Performed action for logging purposes.")]
        [System.String] $Action
    )
    
    Process {
        
        $logger_length = $PSPocs.Logger.Length
        $path_list = @()
        $Structure | ForEach-Object{
            # create temporary file with content of source
            $path = @{
                "Source" = $_.Path
                "Backup" = New-TemporaryFile -Extension ".ini"
            }
        
            # copy source to backup location
            if (Test-Path -Path $path.Source) {
                Copy-Item -Path $path.Source -Destination $path.Backup -Force
            }
            $path_list += $path
        }

        # store information about backup in module logger
        $PSPocs.Logger += [PSCustomObject] @{
            "Id" =  $logger_length
            "Date" = Get-Date -Format "HH:mm:ss MM/dd/yyyy"
            "Action" = $Action
            "Files" = $path_list

        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-LocalConfigContent {

    <#
    .DESCRIPTION
       Get local config settings from specified literature and document library.

    .PARAMETER Name

    .OUTPUTS 
        System.Object. Local configuration file content.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object])]

    Param(
        [Parameter(HelpMessage="Name of document and bibliography library.")]
        [System.String] $Name
    )
    
    Process {
        # get specific document and bibliography library
        $library = $PSPocs.Library | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty "Content"

        # extract the related local configuration file and return its content
        $config_file = Get-LocalConfigFile -Library $library
        if ($config_file){
            return Get-IniContent -FilePath $config_file -IgnoreComments 
        }  
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-LocalConfigFile {

    <#
    .DESCRIPTION
       Extract local config file from document and bibliography library settings.

    .PARAMETER Library

    .OUTPUTS 
        System.String. Local config file of ocument and bibliography library.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.String])]

    Param(
        [Parameter(HelpMessage="Literature and document library.")]
        [System.Object] $Library
    )

    Process {
        # extract local config file from document and bibliography library settings
        $library = Format-FileContent -Content $Library
        if ($library.Keys -contains "local-config-file"){
            $config_file = $library["local-config-file"]
            if (Test-Path -Path $config_file){
                return $config_file
            }
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Get-LibraryStructure {

    <#
    .DESCRIPTION
        Extract Specific document and bibliography library, local configuration file content.

    .PARAMETER Name

    .OUTPUTS 
        System.Object. Structure of library.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object])]

    Param(
        [Parameter(HelpMessage="Name of document and bibliography library.")]
        [System.String] $Name
    )
    
    Process {

        if ($Name) {
            # get sepcific literature and document library
            $library = $PSPocs.Library | Where-Object {$_.Name -eq $Name} | Select-Object -ExpandProperty "Content"
            
            # create structure of library
            $structure = @( 
                [PSCustomObject] @{ 
                    "Key" = @($Name) 
                    "Path" = $PSPocs.PapisConfig
                    "Library" = @{ $Name = $library} 
                    "Source"= $PSPocs.PapisConfigContent 
                }
            )

            # get file path of local literature and document library configuration file and read its content
            $config_file = Get-LocalConfigFile -Library $library
            if ($config_file) {
                $local_library = $(Get-LocalConfigContent -Name $Name)

                # create structure of library
                $structure += [PSCustomObject] @{ 
                    "Key" = @($local_library.Keys)
                    "Path" = $config_file
                    "Library" = $local_library
                    "Source" = $local_library
                }
            }

            return $structure
        }
        else{
            # get the whole content of general literature and document library configuration file
            $library = $PSPocs.PapisConfigContent
            
            # create structure of library
            return  @( 
                [PSCustomObject] @{ 
                    "Key" = @($library.Keys)
                    "Path" = $PSPocs.PapisConfig
                    "Library" = $library
                    "Source"= $PSPocs.PapisConfigContent 
                }
            )
        }
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Update-LibraryStructure {

    <#
    .DESCRIPTION
        Update library structure from content of another library.

    .PARAMETER Library

    .PARAMETER Structure

    .OUTPUTS 
        System.Object. Structure of library.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object[]])]

    Param(
        [Parameter(HelpMessage="Literature and document library.")]
        [System.Object] $Library,

        [Parameter(Position=2, HelpMessage="Structure of library, containing details about the ocomposition of sections.")]
        [System.Object] $Structure
    )

    Process {

        # Update library structure from content of reference library.
        $Structure | ForEach-Object {
            $structure_library = $_
            # Update each section of sepcified library structure, which can be found in the reference library
            for ($i = 0; $i -lt $structure_library.Key.Length; $i++){
                $key = $structure_library.Key[$i]
                $structure_library.Library[$key] = $Library[$key]
                $structure_library.Source[$key] = $Library[$key]
            }
        }

        return $Structure
    }
}


#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Add-LibraryStructure {

    <#
    .DESCRIPTION
        Add library to library structure.

    .PARAMETER Library

    .PARAMETER Structure

    .OUTPUTS 
        System.Object. Structure of library.
    #>
    
    [CmdletBinding(PositionalBinding)]

    [OutputType([System.Object[]])]

    Param(
        [Parameter(HelpMessage="Literature and document library.")]
        [System.Object] $Library,

        [Parameter(Position=2, HelpMessage="Structure of library, containing details about the ocomposition of sections.")]
        [System.Object] $Structure
    )

    Process {

        # Update library structure from content of reference library.
        $Structure | ForEach-Object {
            $structure_library = $_
            # Update each section of sepcified library structure, which can be found in the reference library
            foreach ($key in $Library.Keys) {
                $structure_library.Library[$key] = $Library[$key]
                $structure_library.Source[$key] = $Library[$key]
            }
        }

        return $Structure
    }
}

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Update-PocsLibraryFromInput{

    <#
    .DESCRIPTION
        Update existing literature and document libraries   
    
    .PARAMETER Library

    .PARAMETER Action

    .INPUTS
        System.Object. Structure of library.

    .OUTPUTS
        None.
    #>

    [CmdletBinding(PositionalBinding)]
    
    [OutputType([Void])]

    Param(

        [Parameter(Position=1, HelpMessage="Structure of library, containing details about the ocomposition of sections.")]
        [System.Object] $Structure,

        [Parameter(HelpMessage="Performed action for logging purposes.")]
        [System.String] $Action
    )

    Process{

        # backup for updating literature and document libraries
        New-ConfigBackup -Structure $Structure -Action $Action

        # backup for updating literature and document libraries

        $Structure | ForEach-Object{
            
            # write module config content to literature and document library file
      
            $_.Source | Out-IniFile -FilePath $_.Path -Force -Loose -Pretty

        }

        Write-FormattedSuccess -Message "Action $($Action) accomplished " -Module $PSPocs.Name

        # update module structures
        Update-PocsLibrary
    } 
}