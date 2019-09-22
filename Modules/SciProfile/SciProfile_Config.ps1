# ===========================================================================
#   SciProfile_Config.ps1 ---------------------------------------------------
# ===========================================================================

#   configuration -----------------------------------------------------------
# ---------------------------------------------------------------------------

# set the default path where the virtual environments are located and their subdirectories defined in the configuration file
$SciProfile= New-Object -TypeName PSObject -Property @{
    Name = $Module.Name
    WorkDir = Get-ConfigProjectDir -Name $Module.Name
}

New-ProjectConfigDirs -Name $Module.Name.ToLower()
if (-not $(Test-Path $Module.Config)) {
    Get-Content -Path (Join-Path -Path $Module.Dir -ChildPath "default_config.ini") | Out-File -FilePath $Module.Config -Force
}
$config_raw = Get-IniContent -FilePath $Module.Config -IgnoreComments
$config_content = Format-IniContent -Content $config_raw -Substitution $SciProfile

# read module settings from module format file
$config_format = Get-Content -Path $Module.ConfigFormat | ConvertFrom-Json

Format-JsonContent -Content $config_format -Substitution $SciProfile | ForEach-Object{
    
    # write-host $_.Field $_.Default $config_content[$_.Section][$_.Field]

    $break = $False
    if ($config_content.Keys -match $_.Section){
        $sec_keys = $config_content[$_.Section].Keys
        if ($sec_keys -match $_.Name){
            
            $value = $config_content[$_.Section][$_.Field]
            if (-not $value) {
                $value = $_.Default          
            }

            if ($_.Id -in $SciProfile.PSObject.Properties.Name) {
                $SciProfile.($_.Id) = $value
            } else{
                $SciProfile | Add-Member -MemberType NoteProperty -Name $_.Id -Value $value
            }

            #write-host $_.Id $value

            if ($_.Required){
                if ($_.Folder -and $value -and -not $(Test-Path $value)) {
                    Write-FormattedWarning -Message "The path $($value) defined in field $($_.Field) of the module configuration file can not be found. Default directory $($value) will be created." -Module $Module.Name
                    New-Item -Path $value -ItemType Directory
                }
                elseif (-not $_.Folder -and -not $value ) {
                   Write-FormattedWarning -Message "Field $($_.Field) is not defined in configuration file and should be set for full module functionality." -Module $Module.Name
                }
            }
        } else {
            $break = $False
        }
    } else {
        $break = $False
    }

    if($break){
        if ($_.Required){
            Write-FormattedError -Message "Module could not be loaded due to configuration problems."

            return
        }
    }
}

Write-FormattedMessage -Message "Module config file: $($Module.Config)" -Module $SciProfile.Name -Color "White"
