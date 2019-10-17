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
An example

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
        [ValidateSet('png','svg')]
        [string]
        $OutputFormat = 'png',
        [switch] $DarkMode
    )

    if($ShowGraph){
        $ShowGraph= $true
    }
    else{
        $ShowGraph= $false
    }

    if($DarkMode){
        Write-Verbose "`'Dark mode`' is enabled."
        $GraphColor = 'Black'
        $SubGraphColor = 'White'
        $GraphFontColor = 'White'
        $EdgeColor = 'White'
        $EdgeFontColor = 'White'
        $NodeColor = 'White'
        $NodeFontColor = 'White'
    }
    else{
        $GraphColor = 'White'
        $SubGraphColor = 'Black'
        $GraphFontColor = 'Black'
        $EdgeColor = 'Black'
        $EdgeFontColor = 'Black'
        $NodeColor = 'Black'
        $NodeFontColor = 'Black'
    }

    #region defaults
    $rank = @{
        publicIPAddresses     = 0
        loadBalancers         = 1
        virtualNetworks       = 2 
        networkSecurityGroups = 3
        networkInterfaces     = 4
        virtualMachines       = 5
    }

    $UniqueIdentifier = 0
    $Tier = 0

    $Shapes = @{
        loadBalancers                            = 'diamond'
        publicIPAddresses                        = 'octagon'
        networkInterfaces                        = 'component'
        virtualMachines                          = 'box3d'
        'loadBalancers/backendAddressPools'      = 'rect'
        'loadBalancers/frontendIPConfigurations' = 'rect'
        'virtualNetworks'                        = 'oval'
        'networkSecurityGroups'                  = 'oval'
    }

    $Style = @{
        loadBalancers                            = 'filled'
        publicIPAddresses                        = 'filled'
        networkInterfaces                        = 'filled'
        virtualMachines                          = 'filled'
        'loadBalancers/backendAddressPools'      = 'filled'
        'loadBalancers/frontendIPConfigurations' = 'filled'
        'virtualNetworks'                        = 'dotted'
        'networkSecurityGroups'                  = 'filled'
    }

    $Color = @{
        loadBalancers                            = 'greenyellow'
        publicIPAddresses                        = 'gold'
        networkInterfaces                        = 'skyblue'
        'loadBalancers/frontendIPConfigurations' = 'lightsalmon'
        virtualMachines                          = 'darkolivegreen3'
        'loadBalancers/backendAddressPools'      = 'crimson'
        'virtualNetworks'                        = 'navy'
        'networkSecurityGroups'                  = 'azure'
    }
    #endregion defaults

    #region graph-generation
    Write-Verbose "Starting topology graph generation"
    Write-Verbose "Target Resource Groups: [$ResourceGroups]"
    Graph 'AzureTopology' @{overlap = 'false'; splines = 'true' ; rankdir = 'TB'; color= $GraphColor; bgcolor = $GraphColor; fontcolor = $GraphFontColor } {
        
        edge @{color=$EdgeColor;fontcolor=$EdgeFontColor}
        node @{color=$NodeColor ;fontcolor= $NodeFontColor}
        
        foreach ($ResourceGroup in $ResourceGroups) {
            $location = Get-AzResourceGroup -Name $ResourceGroup | % location
            $networkWatcher = Get-AzNetworkWatcher -Location $location
            Write-Verbose "Working on `"Graph$UniqueIdentifier`" for ResourceGroup: `"$ResourceGroup`""
            SubGraph "$($ResourceGroup.Replace('-', ''))" @{label = $ResourceGroup; labelloc = 'b';penwidth="1";fontname="Courier New" ; color= $SubGraphColor} {
                Write-Verbose "Fetching Network topology of ResourceGroup: `"$ResourceGroup`""
                $Topology = Get-AzNetworkWatcherTopology -NetworkWatcher $networkWatcher -TargetResourceGroupName $ResourceGroup -Verbose
            
                #region parsing-topology-and-finding-associations

                # parse topology to find nodes and their associations and rank them.
                Write-Verbose "Parsing Network topology objects to find associations"
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
          
                #region test

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
                                penwidth="1"
                                fontname="Courier New"
                            }
                        }
                        else {
                            Edge -From "$UniqueIdentifier$($_.from)" `
                                -to "$UniqueIdentifier$($_.to)" -Attributes @{
                                    penwidth="1"
                                    fontname="Courier New"
                                }
                        }
                    }
                #endregion plotting-edges-to-nodes

                #region plotting-all-remaining-nodes
                $remaining = @()
                # $ShouldMatch = 'publicIPAddresses', 'loadBalancers', 'networkInterfaces', 'virtualMachines'
                $remaining += $data | Where-Object { $_.fromcateg -notin $ShouldMatch } |
                Select-Object *, @{n = 'Category'; e = { 'fromcateg' } }
            $remaining += $data | Where-Object { $_.tocateg -notin $ShouldMatch } |
            Select-Object *, @{n = 'Category'; e = { 'tocateg' } }
 
        if ($remaining) {
            $remaining | ForEach-Object {
                if ($_.Category -eq 'fromcateg') {
                    $from = $_.from
                    Get-ImageNode -Name "$UniqueIdentifier$from" -Rows $from -Type $_.fromCateg   
                    
                    # Write-Verbose 'fromcateg: ' $_.fromcateg "Name: $From"
                    # Write-Verbose $Node
                }
                # else {
                #     $to = $_.to
                #     if (![string]::IsNullOrEmpty($to)) {
                #     $node =   Get-ImageNode -Name "$UniqueIdentifier$to" -Rows $to -Type $_.toCateg   
                #         $node
                #         Write-Verbose 'tocateg: ' $_.tocateg "Name: $To" 
                #         Write-Verbose $Node

                #     }
                # }
            }
        }
        #endregion plotting-all-remaining-nodes

    }
    $UniqueIdentifier = $UniqueIdentifier + 1
} 
} | Export-PSGraph -ShowGraph:$ShowGraph -OutputFormat $OutputFormat -OutVariable Graph | Out-Null
#endregion graph-generation

Write-Verbose "Graph Exported to path: $($Graph.fullname)"
}

Export-ModuleMember Get-AzNetworkVizualization -Alias AzViz