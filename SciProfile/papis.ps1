# ============================================================================
#   powershell-functions.papis.ps1 -------------------------------------------
# ============================================================================

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
Function Global:Set-LayoutPapis
{
    [CmdletBinding()]

    [OutputType([Void])]

    Param(
        [Parameter(Mandatory=$False)]
        [Switch] $Prompt
    ) 

    Process{

        Set-Layout -Application Papis

        if ($Prompt) {
        Start-Process pwsh "-NoExit -NoLogo -command Set-Layout -Application Papis-Default"

        }
    }
}


#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Papis-GetBib{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param(

        [ValidateSet([ValidatePapisProject])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Library,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Path,

        [Parameter(Position=3, Mandatory=$True)]
        [System.String] $Query

    )

    Process {

        If (Test-Path $Path) {
            Remove-Item -Path $Path -Force
        }
        
        Start-PocsLibrary -Name $Library

        
        write-Host "$(papis config dir)"

        $Query.split(",") | ForEach-Object {
            Write-FormattedProcess -Message "Query: $_"
            $(papis export --format bibtex --out $Path --all $_)
        }

        Stop-PocsLibrary -VirtualEnv
    }
}


#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Papis-AddFromJson {

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([Void])]

    Param(

        [ValidateSet([ValidatePapisProject])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Library,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $Path,
        
        [Parameter()]
        [System.String] $Check,
        
        [Parameter()]
        [Switch] $Edit,

        [Parameter()]
        [Switch] $Stop
    )

    Process{

        # Start a virtual and papis environment
        $(sa-pocs $Library)
    
        try{
            papis
        }
        catch{
            Write-FormattedError -Message "The term 'papis' is not recognized as the name of a cmdlet, function, script file, or operable program. Please activate a virtual environment with installed package 'papis'."
            return
        }
    
        $papisMessage = papis -l $Library config dir
        if ($papisMessage -and (Test-Path -Path $papisMessage)){
            Write-FormattedSuccess -Message "Library $Library detected."
        }
        else {
            Write-FormattedError -Message "Path or library $Library does not exist."
            return
        }

        If (-not (Test-Path -Path $Path)){
            Write-FormattedError -Message "Path $Path does not exist."
            return
        }

        $logString = ""
        if ($VerbosePreference) {
            $logString = "--log DEBUG"
        }
        $editString = "--no-edit"
        if ($Edit) {
            $editString = ""
        }

        $itemList =  Get-Content $Path | ConvertFrom-Json
        $itemList | ForEach-Object {
            $item_file_tmp = New-TemporaryFile

            $item = $_ | ConvertTo-Json  
            Write-FormattedProcess -Message "Item $item will be added to library $Library"

            $item | Out-File -FilePath $item_file_tmp 
            
            $(papis -l $Library $logString add --no-echo --from yaml $item_file_tmp $editString) 

            $checkEntry = Select-Object -ExpandProperty $Check
            if ($(papis -l $Library list  $checkEntry)){
                Write-FormattedSuccess -Message "Item was successfully added to library $Library"
            }
        }

        # Stop the virtual and papis environment if specified
        if ($Stop){
            $(sp-pocs-venv)
        }
    }
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Papis-AddFromTemp-OneDrive{
    Papis-AddFromTemp -Library pocs-paper -BibTex "A:\Downloads\Literature\" -Stop
}

#   function -----------------------------------------------------------------
# ----------------------------------------------------------------------------
function Global:Papis-AddFromTemp{

    [CmdletBinding(PositionalBinding=$True)]

    [OutputType([PSCustomObject])]

    Param(

        [ValidateSet([ValidatePapisProject])]
        [Parameter(Position=1, Mandatory=$True)]
        [System.String] $Library,

        [Parameter(Position=2, Mandatory=$True)]
        [System.String] $BibTex,

        [Parameter(Position=3, Mandatory=$False)]
        [System.String] $Pdf,

        [Parameter()]
        [Switch] $Edit,

        [Parameter()]
        [Switch] $Stop
    )
    
    Process {

        # Start a virtual and papis environment
        $(sa-pocs $Library)
    
        try{
            papis
        }
        catch{
            Write-FormattedError -Message "The term 'papis' is not recognized as the name of a cmdlet, function, script file, or operable program. Please activate a virtual environment with installed package 'papis'."
            return
        }

        $papisMessage = papis -l $Library config dir
        if ($papisMessage -and (Test-Path -Path $papisMessage)){
            Write-FormattedSuccess -Message "Library $Library detected."
        }
        else {
            Write-FormattedError -Message "Path or library $Library does not exist."
            return
        }

        if (-not $Pdf) {
            $Pdf = $BibTex
        }

        $bibDir = $BibTex
        $pdfDir = $Pdf

        # test bib-files and pdf-files path
        if ((Test-Path -Path $bibDir) -and (Test-Path -Path $pdfDir)) {
            $bibFiles = Get-ChildItem -Path $bibDir -Filter "*.bib"
            $pdfFiles = Get-ChildItem -Path $pdfDir -Filter "*.pdf"
        }
        else {
            Write-FormattedError -Message "Path for bib-files or pdf-files is not valid." -Space
            return
        }

        # loop over bib-files and add each of them with corresponding pdf-file to the library
        if (-not ($bibFiles -is [System.Object[]])){
            $bibFiles = @($bibFiles)
        }

        for ($bibIdx=0; $bibIdx -lt  $bibFiles.length; $bibIdx++){
            $bibFile = $bibFiles[$bibIdx]
            $baseName  = [System.IO.Path]::GetFileNameWithoutExtension($bibFile)
            $bibFile = [System.IO.Path]::GetFileName($bibFile)
            $pdfFile = [System.IO.Path]::GetFileName(($pdfFiles.Name | Where-Object{ $_ -match $baseName}))

            Write-Verbose "Bib-file: $bibfile and corresponding pdf-file: $pdfFile"

            $bibFile = Join-Path -Path $bibDir -ChildPath $bibFile
            $pdfFile = Join-Path -Path $pdfDir -ChildPath $pdfFile

            $papisMessage = papis -l $Library list $baseName
            
            Write-FormattedProcess -Message "Process: Adding $baseName to library." -Space

            $logString = ""
            if ($VerbosePreference) {
                $logString = "--log DEBUG"
            }
            $editString = "--no-edit"
            if ($Edit) {
                $editString = ""
            }

            $(papis -l $Library $logString add --no-echo --from bibtex $bibFile $pdfFile $editString)  

            $papisMessage = papis -l $Library list $baseName
            Write-Host
        }

        Write-FormattedMessage -Message "Transfer of bibliography finished." -Color Cyan -Space

        # Stop the virtual and papis environment if specified
        if ($Stop){
            $(sp-pocs-venv)
        }
    }
}
