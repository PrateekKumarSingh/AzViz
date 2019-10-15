$Path = [System.IO.Path]::Combine($PSScriptRoot,'src')
Get-Childitem $Path -Filter *.ps1 -Recurse | Foreach-Object {
    . $_.Fullname
}