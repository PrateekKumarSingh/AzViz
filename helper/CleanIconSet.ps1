[string]$path = 'D:\Workspace\Repository\AzViz\src\icons\'
[string]$exec = 'C:\Program Files\Inkscape\inkscape.exe' 

$Files = $(Get-ChildItem $path -Recurse) | ? {!$_.PSIsContainer}
# $Files | %{ Rename-Item -path $_.FullName -NewName $($_.BaseName+'.png') -Verbose -ErrorAction SilentlyContinue}

foreach ($filename in $Files) { 
    if ($filename.toString().EndsWith('.svg')) { 
        echo "Converting $filename ..." 
        $filename=$filename.fullname
        $base = Split-Path $filename
        $leaf = (Split-Path $filename -Leaf).replace('.svg','.png').replace(' ','')
        $targetName = Join-Path $base $leaf
 
        $command = "& `"$exec`" -z -e `"$targetName`" -w 64 `"$filename`"";  
        Invoke-Expression $command; 
    } 
} 
 