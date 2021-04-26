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
Controls how edges appear in visualization, default is 'spline' and other supported values are 'polyline', 'curved', 'ortho', 'line'

.PARAMETER ExcludeTypes
String array of Azure resource types and providers to exclude from the visualization. 
Can contain wild cards like: "Microsoft.Network*" or "*network*"

.EXAMPLE
Visualizing a single resource group

Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show

.EXAMPLE
Visualizing a single resource group with more sub-categories

Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -CategoryDepth 2

.EXAMPLE
Visualizing multiple resource groups

Export-AzViz -ResourceGroup demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Show -OutputFormat png

.EXAMPLE
Add more information in resource label like: Name, type, Provider etc using the '-LabelVerbosity' parameter

Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -LabelVerbosity 2

.EXAMPLE
Exclude Azure resources/providers from the visualization by passing them as an argument to the '-ExcludeTypes' parameter

Export-AzViz -ResourceGroup prateek -Show -ExcludeTypes "*workspace*", "Microsoft.Storage*" -Theme Neon
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
        [string] $Splines = 'spline',

        # type of resources to be excluded in the visualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateNotNullOrEmpty()]
        [string[]] $ExcludeTypes
    )


    try {

        $StartTime =  [datetime]::Now

        #region defaults
        $ErrorActionPreference = 'stop'

        Get-ASCIIArt             

        Write-Host ""
        Write-CustomHost "Testing Graphviz installation..." -Indentation 0 -color Magenta -AddTime

        # test graphviz installation

        $GraphViz = Get-DOTExecutable

        if ( $null -eq $GraphViz ) {
            Write-Error "'GraphViz' is not installed on this system and is a prerequisites for this module to work. Please download and install from here: https://graphviz.org/download/ and re-run this command." -ErrorAction Stop
        }
        else {
            Write-CustomHost "GraphViz installation path : $GraphViz" -Indentation 1 -color Green
        }

        switch ($Theme) {
            'light' { 
                $VisualizationGraphColor = 'White'
                $MainGraphBGColor = 'ivory1'
                $ResourceGroupGraphColor = 'black'
                $ResourceGroupGraphBGColor = 'ghostwhite'
                $VNetGraphColor = 'mintcream'
                $SubnetGraphBGColor = 'whitesmoke'
                $SubnetGraphColor = 'black'
                $GraphFontColor = 'black'
                $DependencyEdgeColor = 'lightslategrey'
                $NetworkEdgeColor = 'royalblue2'
                $EdgeFontColor = 'black'
                $NodeColor = 'black'
                $NodeFontColor = 'black'
                break
            }
            'dark' { 
                $VisualizationGraphColor = 'White'
                $MainGraphBGColor = 'Black'
                $ResourceGroupGraphColor = 'white'
                $ResourceGroupGraphBGColor = 'grey7'
                $VNetGraphColor = 'white'
                $VNetGraphBGColor = 'grey15'
                $SubnetGraphColor = 'white'
                $SubnetGraphBGColor = 'grey23'
                $GraphFontColor = 'white'
                $DependencyEdgeColor = 'lightslategrey'
                $NetworkEdgeColor = 'royalblue2'
                $EdgeFontColor = 'white'
                $NodeColor = 'white'
                $NodeFontColor = 'white'
                break
            }
            'neon' {
                $VisualizationGraphColor = 'White'
                $MainGraphBGColor = 'grey14'
                $ResourceGroupGraphColor = 'white'
                $ResourceGroupGraphBGColor = 'midnightblue'
                $VNetGraphColor = 'white'
                $VNetGraphBGColor = 'darkslategray'
                $SubnetGraphColor = 'white'
                $SubnetGraphBGColor = 'maroon4'
                $GraphFontColor = 'gold2'
                $DependencyEdgeColor = 'olivedrab1'
                $NetworkEdgeColor = 'lightpink2'
                $EdgeFontColor = 'gold2'
                $NodeColor = 'gold2'
                $NodeFontColor = 'gold2'
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

        Write-CustomHost "Configuring Defaults..." -Indentation 0 -color Magenta -AddTime
        Write-CustomHost " Target Type            : $TargetType"-Indentation 1 -color Green
        Write-CustomHost " Output Format          : $OutputFormat"-Indentation 1 -color Green
        Write-CustomHost " Exluded Resource Types : $($ExcludeTypes.foreach({"`'$_`'"}))"-Indentation 1 -color Green
        Write-CustomHost " Output File Path       : $OutputFilePath"-Indentation 1 -color Green
        Write-CustomHost " Label Verbosity        : $LabelVerbosity"-Indentation 1 -color Green
        Write-CustomHost " Category Depth         : $CategoryDepth"-Indentation 1 -color Green
        Write-CustomHost " Sub-graph Direction    : $Direction"-Indentation 1 -color Green
        Write-CustomHost " Theme                  : $Theme"-Indentation 1 -color Green
        Write-CustomHost " Launch Visualization   : $Show"-Indentation 1 -color Green
        
        switch ($TargetType) {
            'Azure Resource Group' { $Targets = $ResourceGroup }
            'File' { $Targets = $path }
            'Url' { $Targets = $url }
        }
          
        Write-CustomHost "Target ${TargetType}s... " -Indentation 0 -color Magenta -AddTime
        $Targets.ForEach( { Write-CustomHost $_ -Indentation 1 -color Green } ) 
        #endregion defaults

        #region graph-generation
        Write-CustomHost "Starting to generate Azure visualization..." -Indentation 0 -color Magenta -AddTime
    
        $graph = ConvertTo-DOTLanguage -TargetType $TargetType -Targets $Targets -CategoryDepth $CategoryDepth -LabelVerbosity $LabelVerbosity -Splines $Splines -ExcludeTypes $ExcludeTypes

        if ($graph) {
            @"
strict $graph
"@ | Export-PSGraph -ShowGraph:$Show -OutputFormat $OutputFormat -DestinationPath $OutputFilePath -OutVariable output |
            Out-Null
            Write-CustomHost "Visualization exported to path: $($output.fullname)" -Indentation 0 -color Magenta -AddTime
            Write-CustomHost "Finished Azure visualization." -Indentation 0 -color Magenta -AddTime
        }
        #endregion graph-generation
    }
    catch {
        $_
    }
}

Export-ModuleMember Export-AzViz