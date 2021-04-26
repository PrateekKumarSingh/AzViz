Function Get-ASCIIArt {
    $mid = [char]9552
    $full = [char]9553
    $tl = [char]9556
    $tr = [char]9559
    $bl = [char]9562
    $br = [char]9565
    $b = [char]9608

    
    $ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $ModuleVersion = (Import-PowerShellDataFile (Join-Path $ProjectRoot "AzViz.psd1")).ModuleVersion  

    $ASCIIArt = @"

    $b$b$b$b$b$tr $b$b$b$b$b$b$b$tr$b$b$tr   $b$b$tr$b$b$tr$b$b$b$b$b$b$b$tr   
   $b$b$tl$mid$mid$b$b$tr$bl$mid$mid$b$b$b$tl$br$b$b$full   $b$b$full$b$b$full$bl$mid$mid$b$b$b$tl$br   Author    : Prateek Singh (Twitter @singhprateik)
   $b$b$b$b$b$b$b$full  $b$b$b$tl$br $b$b$full   $b$b$full$b$b$full  $b$b$b$tl$br    Module    : Azure Visualizer $(if($ModuleVersion){"v$ModuleVersion"})
   $b$b$tl$mid$mid$b$b$full $b$b$b$tl$br  $bl$b$b$tr $b$b$tl$br$b$b$full $b$b$b$tl$br     Github    : https://github.com/PrateekKumarSingh/AzViz
   $b$b$full  $b$b$full$b$b$b$b$b$b$b$tr $bl$b$b$b$b$tl$br $b$b$full$b$b$b$b$b$b$b$tr   Document  : https://azviz.readthedocs.io
   $bl$mid$br  $bl$mid$br$bl$mid$mid$mid$mid$mid$mid$br  $bl$mid$mid$mid$br  $bl$mid$br$bl$mid$mid$mid$mid$mid$mid$br  
"@

    $ASCIIArt.ToCharArray().foreach({
        if($_ -eq $b){
            Write-Host $_ -ForegroundColor Yellow -NoNewline
        }
        elseif($_ -in $($mid, $full, $tl, $tr, $bl, $br)){
            Write-Host $_ -ForegroundColor Gray -NoNewline
        }
        else{
            Write-Host $_ -ForegroundColor Gray -NoNewline
        }
    })


}