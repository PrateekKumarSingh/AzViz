# script to convert downloaded azure icon set from SVG to PNG format, so that GraphViz can consume the icons

[string]$path = '.\icons\'
[string]$exec = 'C:\Program Files\Inkscape\inkscape.exe' 

$Files = $(Get-ChildItem $path -Recurse) | ? {!$_.PSIsContainer}

foreach ($filename in $Files) { 
    if ($filename.toString().EndsWith('.svg')) { 
        echo "Converting $filename ..." 
        $filename=$filename.fullname
        $base = Split-Path $filename
        $leaf = (Split-Path $filename -Leaf).replace('.svg','.png').replace(' ','')
        $targetName = Join-Path $base $leaf
 
        $command = "& `"$exec`" --export-type='png' `"$filename`"";  
        # $command = "& `"$exec`" -z -e `"$targetName`" -w 64 `"$filename`"";
        Invoke-Expression $command; 
    } 
} 
 