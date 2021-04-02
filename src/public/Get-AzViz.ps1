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

Get-AzViz -ResourceGroups 'test-resource-group'


.EXAMPLE
An example

Get-AzViz -ResourceGroups 'test-resource-group' -ShowGraph -OutputFormat png -Verbose

.NOTES
Project URL: https://github.com/PrateekKumarSingh/azviz
#>

function Get-AzViz {
    [alias("AzViz")]
    [CmdletBinding()]
    param (
        # Resource Groups 
        [string[]]
        $ResourceGroups = (Get-AzResourceGroup).ResourceGroupName,
        # Shows Visualization Graph
        [switch] $ShowGraph,
        # Include category information
        [switch] $IncludeCategory,
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
    $graph = Graph 'AzureTopology' @{overlap = 'false'; splines = 'true' ; rankdir = 'TB'; color = $GraphColor; bgcolor = $GraphColor; fontcolor = $GraphFontColor } {
        
        edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
        node @{color = $NodeColor ; fontcolor = $NodeFontColor }
        
        foreach ($ResourceGroup in $ResourceGroups) {

            if (Get-AzResource -ResourceGroupName $ResourceGroup) {

                Write-Verbose "Plotting graph for resource group: `"$ResourceGroup`""

                SubGraph "$($ResourceGroup.Replace('-', ''))" @{label = $ResourceGroup; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor } {
                    
                    #region parsing-arm-template-and-finding-resource-dependencies
                    $data = @()
                    $template = Export-AzResourceGroup -ResourceGroupName $ResourceGroup -SkipAllParameterization -Force -Path $env:TEMP\template.json
                    $arm = ConvertFrom-ArmTemplate -Path $template.Path
                    # $excluded_types = @("scheduledqueryrules","containers","solutions","modules","savedSearches")
                    
                    $data += $arm.Resources | ForEach-Object {
                        $dependson = $null
                        if($_.dependson){
                            $dependson = $_.DependsOn #| ForEach-Object { $_.ToString().split("parameters('")[1].split("')")[0]}
                            foreach ($dependency in $dependson) {                            
                                [PSCustomObject]@{
                                    fromcateg = $_.type.ToString() #.split('/')[-1]
                                    from = $_.name.ToString() #.split('/')[-1] #.split("parameters('")[1].split("')")[0]
                                    to = $dependency.tostring().replace("[resourceId(","").replace(")]","").Split(",")[1].replace("'","").trim() #.split('/')[-1]
                                    tocateg = $dependency.tostring().replace("[resourceId(","").replace(")]","").Split(",")[0].replace("'","").trim() #.split('/')[-1]
                                    association = 'associated'
                                    rank = $rank["$($_.type.ToString().split('/')[1])"]
                                }
                            }
                        }
                        else{
                            [PSCustomObject]@{
                                fromcateg = $_.type.ToString() #.split('/')[-1]
                                from = $_.name.ToString() #.split("parameters('")[1].split("')")[0]
                                to = ''
                                tocateg = ''
                                association = ''
                                rank = $rank["$($_.type.ToString().split('/')[1])"]
                            }
                        }
                    }

                    # $location = Get-AzResourceGroup -Name $ResourceGroup | % location
                    # $networkWatcher = Get-AzNetworkWatcher -Location $location
                    # $Topology = Get-AzNetworkWatcherTopology -NetworkWatcher $networkWatcher -TargetResourceGroupName $ResourceGroup -Verbose
                    # Write-Verbose "Parsing network topology objects to find associations"
                    # $data += $Topology.Resources | 
                    #     Select-Object @{n = 'from'; e = { $_.name } }, 
                    #     @{n = 'FromCategory'; e = { $_.id.Split('/', 8)[-1] } },
                    #     Associations, 
                    #     @{n = 'To'; e = { ($_.AssociationText | ConvertFrom-Json) | Select-Object name, AssociationType, resourceID } } |
                    #     ForEach-Object {
                    #         if ($_.to) {
                    #             Foreach ($to in $_.to) {
                    #                 $i = 1
                    #                 $fromcateg = $_.FromCategory.split('/', 4).ForEach( { if ($i % 2) { $_ }; $i = $i + 1 }) -join '/'
                    #                 [PSCustomObject]@{
                    #                     fromcateg   = $fromCateg
                    #                     from        = $_.from
                    #                     to          = $to.name
                    #                     association = $to.associationType
                    #                     toCateg     = (($to.resourceID -split 'providers/')[1] -split '/')[1]
                    #                     rank        = $rank["$($FromCateg.split('/')[0])"]
                    #                 }
                    #             }
                    #         }
                    #         else {
                    #             $i = 1
                    #             $fromcateg = $_.FromCategory.split('/', 4).ForEach( { if ($i % 2) { $_ }; $i = $i + 1 }) -join '/'
                    #             [PSCustomObject]@{
                    #                 fromcateg   = $fromCateg
                    #                 from        = $_.from
                    #                 to          = ''
                    #                 association = ''
                    #                 toCateg     = ''
                    #                 rank        = $rank["$($FromCateg.split('/')[0])"]
                    #             }
                    #         }
                    #     } | 
                    #     Sort-Object Rank

                    $data = $data | Sort-Object Rank
                    #endregion parsing-arm-template-and-finding-resource-associations
               
                    #region plotting-edges-to-nodes
                    $data | 
                    Where-Object to | 
                    ForEach-Object {
                        if ($_.Association -eq 'Associated') {
                            Edge -From "$UniqueIdentifier$($_.from)" `
                            -to "$UniqueIdentifier$($_.to)" `
                            -Attributes @{
                                arrowhead = 'box';
                                style     = 'dotted';
                                    label     = ' DependsOn'
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
                            $remaining = $data
                    # # $remaining = @()
                    # # $ShouldMatch = 'publicIPAddresses', 'loadBalancers', 'networkInterfaces', 'virtualMachines'
                    # $remaining += $data | Where-Object { $_.fromcateg -notin $ShouldMatch } | Select-Object *, @{n = 'Category'; e = { 'fromcateg' } }
                    # $remaining += $data | Where-Object { $_.tocateg -notin $ShouldMatch } | Select-Object *, @{n = 'Category'; e = { 'tocateg' } }
 
                    if ($remaining) {
                        $remaining | ForEach-Object {
                            # if ($_.Category -eq 'fromcateg') {
                                $from = $_.from
                                if($IncludeCategory){
                                    Get-ImageNode -Name "$UniqueIdentifier$from" -Rows ($from,$_.fromCateg) -Type $_.fromCateg   
                                }
                                else {
                                    Get-ImageNode -Name "$UniqueIdentifier$from" -Rows $from -Type $_.fromCateg   
                                }
                            # }
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
    }
    
    $graph | Export-PSGraph -ShowGraph:$ShowGraph -OutputFormat $OutputFormat -DestinationPath C:\temp\out.png -OutVariable output
    #endregion graph-generation

    Write-Verbose "Graph Exported to path: $($output.fullname)"
}

Export-ModuleMember Get-AzViz -Alias AzViz