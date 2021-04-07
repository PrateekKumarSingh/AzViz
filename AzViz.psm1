$ProjectRoot = (Get-location).Path
$Path = [System.IO.Path]::Combine($PSScriptRoot, 'src')
Get-Childitem $Path -Filter *.ps1 -Recurse | Foreach-Object {
    . $_.Fullname
}

# verify dependent modules are loaded
$DependentModules = 'PSGraph', 'az'
$Installed = Import-Module $DependentModules -PassThru -ErrorAction SilentlyContinue | Where-Object { $_.name -In $DependentModules }
$Missing = $DependentModules | Where-Object { $_ -notin $Installed.name }
if ($Missing) {
    Write-Verbose "    [+] Module dependencies not found [$Missing]. Attempting to install." -ForegroundColor Green
    Install-Module $Missing -Force -AllowClobber -Confirm:$false -Scope CurrentUser
    Import-Module $Missing
} 
# Import-Module C:\Users\prasingh\Downloads\psarm.0.1.0-alpha1\PSArm.psd1

# Install GraphViz from the Chocolatey repo
if(!(Get-Package GraphViz)){
    Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/ -ErrorAction SilentlyContinue -Verbose
    Find-Package graphviz | Install-Package -ForceBootstrap -Verbose
}