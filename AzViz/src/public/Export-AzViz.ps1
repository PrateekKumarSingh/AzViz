<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ResourceGroup
Target resource groups 

.PARAMETER Show
Launches visualization image

.PARAMETER LabelVerbosity
Level of information to included in vizualization

.PARAMETER CategoryDepth
Level of Azure Resource Sub-category to be included in vizualization

-CategoryDepth 'level1' only allow resource catergores like: Microsoft.EventGrid/topics and  Microsoft.ServiceBus/namespaces
-CategoryDepth 'level2' only allow resource catergores like: Microsoft.ServiceBus/namespaces/AuthorizationRules and  Microsoft.ServiceBus/namespaces/networkRuleSets

.PARAMETER OutputFormat
Output format of the vizualization, i.e, .png or .svg

.PARAMETER Theme
Changes the color theme, i.e 'light', 'dark' or 'neon'. Default is 'light'.

.PARAMETER Direction
Direction in which resource groups are plotted on the visualization

.PARAMETER OutputFilePath
Output file path

.PARAMETER Splines
Controls how edges appear in visualization

.EXAMPLE
Visualizing a single resource group

Export-AzViz -ResourceGroup demo-2 -Theme light -Verbose -OutputFormat png -Show

.EXAMPLE
Visualizing a single resource group with more sub-categories

Export-AzViz -ResourceGroup demo-2 -Theme light -Verbose -OutputFormat png -Show -CategoryDepth 2

.EXAMPLE
Visualizing multiple resource groups

Export-AzViz -ResourceGroup demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Verbose -Show -OutputFormat png

.EXAMPLE
Add more information in resource label like: Name, type, Provider etc using the '-LabelVerbosity' parameter

Export-AzViz -ResourceGroup demo-2 -Theme light -Verbose -OutputFormat png -Show -LabelVerbosity 2

.NOTES
Github    : https://github.com/PrateekKumarSingh/azviz
Document  : https://azviz.readthedocs.io/
Author    : https://www.linkedin.com/in/prateeksingh1590
#>
function Export-AzViz {
    [CmdletBinding()]
    param (
        # Names of target resource groups 
        [Parameter(ParameterSetName = 'AzLogin', Mandatory = $true, Position = 0)]
        [string[]] $ResourceGroup,

        # # File paths to target ARM templates
        # [Parameter(ParameterSetName = 'FilePath', Mandatory = $true, Position = 0)]
        # [System.IO.Path[]] $Path,

        # # URLs to target ARM templates
        # [Parameter(ParameterSetName = 'Url', Mandatory = $true, Position = 0)]
        # [uri[]] $Url,
        
        # Launches visualization image
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [switch] $Show,
        
        # Level of information to included in vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet(1, 2, 3)]
        [int] $LabelVerbosity = 1,
        
        # Level of Azure Resource Sub-category to be included in vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet(1, 2, 3)]
        [int] $CategoryDepth = 1,
        
        # Output format of the vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('png', 'svg')]
        [string] $OutputFormat = 'png',
        
        # Changes the color theme, i.e light or dark
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('light', 'dark', 'neon')]
        [string] $Theme = 'light',

        # Direction in which resource groups are plotted on the visualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('left-to-right', 'top-to-bottom')]
        [string] $Direction = 'top-to-bottom',

        # Output file path
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateScript( { Test-Path -Path $_ -IsValid })]
        [string] $OutputFilePath = (Join-Path ([System.IO.Path]::GetTempPath()) "output.$OutputFormat"),

        # Controls how edges appear in visualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('polyline', 'curved', 'ortho', 'line', 'spline')]
        [string] $Splines = 'spline'
    )
    
    try {

        #region defaults
        $ErrorActionPreference = 'stop'

        $ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $ModuleVersion = (Import-PowerShellDataFile (Join-Path $ProjectRoot "AzViz.psd1")).ModuleVersion
        if ($ModuleVersion) {

            $ASCIIArt = Get-ASCIIArt  
            $ASCIIArt += "`n   Module    : Azure Visualizer v$ModuleVersion"                       
            $ASCIIArt += "`n   Github    : https://github.com/PrateekKumarSingh/AzViz"                       
            $ASCIIArt += "`n   Document  : https://azviz.readthedocs.io/" 
            $ASCIIArt += "`n   Questions : https://github.com/PrateekKumarSingh/AzViz/discussions/new" 
            $ASCIIArt += "`n   Author    : Prateek Singh (Twitter @singhprateik)`n" 
        
            if($PSBoundParameters.ContainsKey('Verbose')){
                Write-Verbose $ASCIIArt
                Write-Verbose ""
            }
            else{
                Write-Host $ASCIIArt
                Write-Host ""
            }
            
        }

        Write-Verbose "Testing Graphviz installation..."

        # test graphviz installation

        $GraphViz = Get-DOTExecutable

        if ( $null -eq $GraphViz ) {
            Write-Error "'GraphViz' is not installed on this system and is a prerequisites for this module to work. Please download and install from here: https://graphviz.org/download/ and re-run this command." -ErrorAction Stop
        }
        else {
            Write-Verbose " [+] GraphViz installation path : $GraphViz"
        }

        switch ($Theme) {
            'light' { 
                $GraphColor = 'White'
                $SubGraphColor = 'Black'
                $GraphFontColor = 'Black'
                $EdgeColor = 'Black'
                $EdgeFontColor = 'Black'
                $NodeColor = 'Black'
                $NodeFontColor = 'Black'
                break
            }
            'dark' { 
                $GraphColor = 'Black'
                $SubGraphColor = 'White'
                $GraphFontColor = 'White'
                $EdgeColor = 'White'
                $EdgeFontColor = 'White'
                $NodeColor = 'White'
                $NodeFontColor = 'White'
                break
            }
            'neon' {
                $GraphColor = 'Black'
                $SubGraphColor = 'YellowGreen'
                $GraphFontColor = 'YellowGreen'
                $EdgeColor = 'YellowGreen'
                $EdgeFontColor = 'YellowGreen'
                $NodeColor = 'YellowGreen'
                $NodeFontColor = 'YellowGreen'
                break
            }
        }

        if ($PSBoundParameters.ContainsKey('ResourceGroup')) {
            $TargetType = 'Azure Resource Group'
        }
        elseif ($PSBoundParameters.ContainsKey('Path')) {
            $TargetType = 'File'
        }
        elseif ($PSBoundParameters.ContainsKey('URL')) {
            $TargetType = 'URL'
        }

        $rank = @{
            "Microsoft.Network/publicIPAddresses"     = 1
            "Microsoft.Network/loadBalancers"         = 2
            "Microsoft.Network/virtualNetworks"       = 3 
            "Microsoft.Network/networkSecurityGroups" = 4
            "Microsoft.Network/networkInterfaces"     = 5
            "Microsoft.Compute/virtualMachines"       = 6
        }

        Write-Verbose "Configuring Defaults..."
        Write-Verbose " [+] Target Type          : $TargetType"
        Write-Verbose " [+] Output Format        : $OutputFormat"
        Write-Verbose " [+] Output File Path     : $OutputFilePath"
        Write-Verbose " [+] Label Verbosity      : $LabelVerbosity"
        Write-Verbose " [+] Category Depth       : $CategoryDepth"
        Write-Verbose " [+] Sub-graph Direction  : $Direction"
        Write-Verbose " [+] Theme                : $Theme"
        Write-Verbose " [+] Launch Visualization : $Show"
        
        switch ($TargetType) {
            'Azure Resource Group' { $Targets = $ResourceGroup }
            'File' { $Targets = $path }
            'Url' { $Targets = $url }
        }
          
        Write-Verbose "Target ${TargetType}s: "
        $Targets.ForEach( { Write-Verbose "   > '$_'" } )
        #endregion defaults

        #region graph-generation
        Write-Verbose "Starting to generate Azure visualization..."
    
        $graph = ConvertTo-DOTLanguage -TargetType $TargetType -Targets $Targets -Verbose -CategoryDepth $CategoryDepth -LabelVerbosity $LabelVerbosity -Splines $Splines

        if ($graph) {
            @"
strict $graph
"@ | Export-PSGraph -ShowGraph:$Show -OutputFormat $OutputFormat -DestinationPath $OutputFilePath -OutVariable output |
            Out-Null
            Write-Verbose "Visualization exported to path: $($output.fullname)"

            if (!$PSBoundParameters.ContainsKey('Verbose')) {
                Write-Host "`nVisualization exported to path: $($output.fullname)`n"
            }
            Write-Verbose "Finished Azure visualization."
        }
        #endregion graph-generation
    }
    catch {
        $_
    }
}

Export-ModuleMember Export-AzViz