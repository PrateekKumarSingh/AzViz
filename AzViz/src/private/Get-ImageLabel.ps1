Function Get-ImageLabel {
    param(
        [string]$Type,
        [string]$Row1,
        [string]$Row2
    )

    $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $IconPath = Join-Path $RootPath 'icons'
    
    return "<<TABLE border='0' cellborder='0' cellspacing='0' cellpadding='0'><TR><TD ALIGN='center' rowspan='2'><img src='{0}' /></TD><TD align='left'>  {1}</TD></TR><TR><TD align='left'>  {2}</TD></TR></TABLE>>" -f $(Join-Path $IconPath $images[$Type]), $Row1, $Row2
}