Function Get-ASCIIArt {
    $mid = [char]9552
    $full = [char]9553
    $tl = [char]9556
    $tr = [char]9559
    $bl = [char]9562
    $br = [char]9565
    $b = [char]9608

    return @"

    $b$b$b$b$b$tr $b$b$b$b$b$b$b$tr$b$b$tr   $b$b$tr$b$b$tr$b$b$b$b$b$b$b$tr
   $b$b$tl$mid$mid$b$b$tr$bl$mid$mid$b$b$b$tl$br$b$b$full   $b$b$full$b$b$full$bl$mid$mid$b$b$b$tl$br
   $b$b$b$b$b$b$b$full  $b$b$b$tl$br $b$b$full   $b$b$full$b$b$full  $b$b$b$tl$br 
   $b$b$tl$mid$mid$b$b$full $b$b$b$tl$br  $bl$b$b$tr $b$b$tl$br$b$b$full $b$b$b$tl$br  
   $b$b$full  $b$b$full$b$b$b$b$b$b$b$tr $bl$b$b$b$b$tl$br $b$b$full$b$b$b$b$b$b$b$tr
   $bl$mid$br  $bl$mid$br$bl$mid$mid$mid$mid$mid$mid$br  $bl$mid$mid$mid$br  $bl$mid$br$bl$mid$mid$mid$mid$mid$mid$br 
    
"@

}