[System.String[]] $a =  ((Get-VirtualEnv | Select-Object -ExpandProperty Name) + "" + "pyton")

$a