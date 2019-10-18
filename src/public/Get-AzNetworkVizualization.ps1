<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ResourceGroups
Parameter description

.PARAMETER ShowGraph
Parameter description

.PARAMETER OutputFormat
Parameter description

.EXAMPLE
Target an Azure resource group and visualize the Network Topology 

Get-AzNetworkVizualization -ResourceGroups 'test-resource-group'


.EXAMPLE
An example

Get-AzNetworkVizualization -ResourceGroups 'test-resource-group' -ShowGraph -OutputFormat png -Verbose

.NOTES
Project URL: https://github.com/PrateekKumarSingh/azviz
#>

function Get-AzNetworkVizualization {
    [alias("AzViz")]
    [CmdletBinding()]
    param (
        # Resource Groups 
        [string[]]
        $ResourceGroups = (Get-AzResourceGroup).ResourceGroupName,
        # Shows Visualization Graph
        [switch] $ShowGraph,
        # Output format of the image
        [ValidateSet('png', 'svg')]
        [string]
        $OutputFormat = 'png',
        [switch] $DarkMode
    )
        
    #region defaults

    if ($ShowGraph) {
        $ShowGraph = $true
    }
    else {
        $ShowGraph = $false
    }

    if ($DarkMode) {
        Write-Verbose "`'Dark mode`' is enabled."
        $GraphColor = 'Black'
        $SubGraphColor = 'White'
        $GraphFontColor = 'White'
        $EdgeColor = 'White'
        $EdgeFontColor = 'White'
        $NodeColor = 'White'
        $NodeFontColor = 'White'
    }
    else {
        $GraphColor = 'White'
        $SubGraphColor = 'Black'
        $GraphFontColor = 'Black'
        $EdgeColor = 'Black'
        $EdgeFontColor = 'Black'
        $NodeColor = 'Black'
        $NodeFontColor = 'Black'
    }

    $rank = @{
        publicIPAddresses     = 0
        loadBalancers         = 1
        virtualNetworks       = 2 
        networkSecurityGroups = 3
        networkInterfaces     = 4
        virtualMachines       = 5
    }

    $UniqueIdentifier = 0

    #endregion defaults

    #region graph-generation
    Write-Verbose "Starting topology graph generation"
    Write-Verbose "Target resource groups: $($ResourceGroups.ForEach({"'{0}'" -f $_}) -join ', ')"
    Graph 'AzureTopology' @{overlap = 'false'; splines = 'true' ; rankdir = 'TB'; color = $GraphColor; bgcolor = $GraphColor; fontcolor = $GraphFontColor } {
        
        edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
        node @{color = $NodeColor ; fontcolor = $NodeFontColor }
        
        foreach ($ResourceGroup in $ResourceGroups) {

            if (Get-AzResource -ResourceGroupName $ResourceGroup) {
                $location = Get-AzResourceGroup -Name $ResourceGroup | % location
                $networkWatcher = Get-AzNetworkWatcher -Location $location
                Write-Verbose "Plotting graph for resource group: `"$ResourceGroup`""

                SubGraph "$($ResourceGroup.Replace('-', ''))" @{label = $ResourceGroup; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor } {
                    Write-Verbose "Fetching network topology of resource group: `"$ResourceGroup`""
                    $Topology = Get-AzNetworkWatcherTopology -NetworkWatcher $networkWatcher -TargetResourceGroupName $ResourceGroup -Verbose
            
                    #region parsing-topology-and-finding-associations

                    # parse topology to find nodes and their associations and rank them.
                    Write-Verbose "Parsing network topology objects to find associations"
                    $data = @()
                    $data += $Topology.Resources | 
                        Select-Object @{n = 'from'; e = { $_.name } }, 
                        @{n = 'FromCategory'; e = { $_.id.Split('/', 8)[-1] } },
                        Associations, 
                        @{n = 'To'; e = { ($_.AssociationText | ConvertFrom-Json) | Select-Object name, AssociationType, resourceID } } |
                        ForEach-Object {
                            if ($_.to) {
                                Foreach ($to in $_.to) {
                                    $i = 1
                                    $fromcateg = $_.FromCategory.split('/', 4).ForEach( { if ($i % 2) { $_ }; $i = $i + 1 }) -join '/'
                                    [PSCustomObject]@{
                                        fromcateg   = $fromCateg
                                        from        = $_.from
                                        to          = $to.name
                                        association = $to.associationType
                                        toCateg     = (($to.resourceID -split 'providers/')[1] -split '/')[1]
                                        rank        = $rank["$($FromCateg.split('/')[0])"]
                                    }
                                }
                            }
                            else {
                                $i = 1
                                $fromcateg = $_.FromCategory.split('/', 4).ForEach( { if ($i % 2) { $_ }; $i = $i + 1 }) -join '/'
                                [PSCustomObject]@{
                                    fromcateg   = $fromCateg
                                    from        = $_.from
                                    to          = ''
                                    association = ''
                                    toCateg     = ''
                                    rank        = $rank["$($FromCateg.split('/')[0])"]
                                }
                            }
                        } | 
                        Sort-Object Rank
                    #endregion parsing-topology-and-finding-associations
          
                    #region plotting-edges-to-nodes
                    $data | 
                        Where-Object to | 
                        ForEach-Object {
                            if ($_.Association -eq 'Contains') {
                                Edge -From "$UniqueIdentifier$($_.from)" `
                                    -to "$UniqueIdentifier$($_.to)" `
                                    -Attributes @{
                                    arrowhead = 'box';
                                    style     = 'dotted';
                                    label     = ' Contains'
                                    penwidth  = "1"
                                    fontname  = "Courier New"
                                }
                            }
                            else {
                                Edge -From "$UniqueIdentifier$($_.from)" `
                                    -to "$UniqueIdentifier$($_.to)" -Attributes @{
                                    penwidth = "1"
                                    fontname = "Courier New"
                                }
                            }
                        }
                    #endregion plotting-edges-to-nodes

                    #region plotting-all-remaining-nodes
                    $remaining = @()
                    # $ShouldMatch = 'publicIPAddresses', 'loadBalancers', 'networkInterfaces', 'virtualMachines'
                    $remaining += $data | Where-Object { $_.fromcateg -notin $ShouldMatch } | Select-Object *, @{n = 'Category'; e = { 'fromcateg' } }
                    $remaining += $data | Where-Object { $_.tocateg -notin $ShouldMatch } | Select-Object *, @{n = 'Category'; e = { 'tocateg' } }
 
                    if ($remaining) {
                        $remaining | ForEach-Object {
                            if ($_.Category -eq 'fromcateg') {
                                $from = $_.from
                                Get-ImageNode -Name "$UniqueIdentifier$from" -Rows $from -Type $_.fromCateg   
                            }
                        }
                        $UniqueIdentifier = $UniqueIdentifier + 1
                    }
                    #endregion plotting-all-remaining-nodes

                }
            }
            else {
                Write-Verbose "Skipping resource group: `"$ResourceGroup`" as no resources were found."             
            }

        } 
    } | Export-PSGraph -ShowGraph:$ShowGraph -OutputFormat $OutputFormat -OutVariable Graph
    #endregion graph-generation

    Write-Verbose "Graph Exported to path: $($Graph.fullname)"
}

Export-ModuleMember Get-AzNetworkVizualization -Alias AzViz