# ===========================================================================
#   project.ps1 -------------------------------------------------------------
# ===========================================================================

#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:Get-Repository {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]

    Param (

        [ValidateSet([ValidateProjectAlias])]
        [Parameter(Position=1)]
        [System.String] $Alias,

        [Switch] $Unformatted
    )

    $result = Get-ProjectList -Type repository -Unformatted 
    if ($Alias) {
        
        $result = $result | Where-Object{
            $_.Alias -eq $Alias
        }

    }
    
    if ($Unformatted){
        return $result
    }

    return $result | Format-Table Name, Alias, Url
}


#   function ----------------------------------------------------------------
# ---------------------------------------------------------------------------
function Global:CocoJson2SingleJson {

    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]

    Param (
        [System.String] $FileName="train_anno.json",
        [System.String] $DstDir="label_json",
        [System.String] $SrcDir="A:\Datasets\GAOFEN\train"  
    )

    $src_file_path = Join-Path -Path $SrcDir -ChildPath $FileName
    $dst_path = Join-Path -Path $SrcDir -ChildPath $DstDir

    $obj = Get-Content -Path $src_file_path | ConvertFrom-Json
    # Write-Host $obj.images
    $obj.images | ForEach-Object {
        # Write-Host $_.file_name
        $image_id = $_.id
        $file_name = $_.file_name
        $obj_anno = $obj.annotations | Where-Object{$_.image_id -eq $image_id}
        # Write-Host $obj_anno

        $dst_file_path = Join-Path -Path $dst_path -ChildPath ((Split-Path $file_name -leafBase) + ".json")
        Write-FormattedProcess -Message "Write file $dst_file_path"
        $obj_anno | ConvertTo-Json | Out-File $dst_file_path
    }
}
