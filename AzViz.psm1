$Path = [System.IO.Path]::Combine($PSScriptRoot, 'src')
Get-Childitem $Path -Filter *.ps1 -Recurse | Foreach-Object {
    . $_.Fullname
}


# verify dependent modules are loaded
$DependentModules = 'PSGraph', 'az'
$Installed = Import-Module $DependentModules -PassThru -ErrorAction SilentlyContinue | Where-Object { $_.name -In $DependentModules }
$missing = $DependentModules | Where-Object { $_ -notin $Installed.name }
if ($missing) {
    Write-host "    [+] Module dependencies not found [$missing]. Attempting to install." -ForegroundColor Green
    Install-Module $missing -Force -AllowClobber -Confirm:$false -Scope CurrentUser
    Import-Module $missing
}

# Install GraphViz from the Chocolatey repo
Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/ -ErrorAction SilentlyContinue -Verbose
Find-Package graphviz | Install-Package -ForceBootstrap -Verbose