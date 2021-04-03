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
        # Level of information to included in vizualization
        [ValidateSet('level1', 'level2', 'level3')]
        [string] $Information = 'level1',
        # Output format of the image
        [ValidateSet('png', 'svg')]
        [string]
        $OutputFormat = 'png',
        [switch] $DarkMode,
        # Level of Azure Resource Sub-category to be included in vizualization
        [ValidateSet('level1', 'level2', 'level3')]
        [string] $Depth = 'level1'
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
        "Microsoft.Network/publicIPAddresses"     = 1
        "Microsoft.Network/loadBalancers"         = 2
        "Microsoft.Network/virtualNetworks"       = 3 
        "Microsoft.Network/networkSecurityGroups" = 4
        "Microsoft.Network/networkInterfaces"     = 5
        "Microsoft.Compute/virtualMachines"       = 6
    }

    switch ($Depth) {
        'level1' { $depthlevel = 2 }
        'level2' { $depthlevel = 3 }
        'level3' { $depthlevel = 4 }
    }

    #endregion defaults

    #region graph-generation
    Write-Verbose "Starting topology graph generation"
    Write-Verbose "Target resource groups: $($ResourceGroups.ForEach({"'{0}'" -f $_}) -join ', ')"
    $graph = Graph 'AzureTopology' @{overlap = 'false'; splines = 'true' ; rankdir = 'TB'; color = $GraphColor; bgcolor = $GraphColor; fontcolor = $GraphFontColor } {
        
        edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
        node @{color = $NodeColor ; fontcolor = $NodeFontColor }
        
        if (Test-AzLogin) {
            foreach ($ResourceGroup in $ResourceGroups) {
            
                if (Get-AzResource -ResourceGroupName $ResourceGroup) {

                    Write-Verbose "Plotting graph for resource group: `"$ResourceGroup`""

                    SubGraph "$($ResourceGroup.Replace('-', ''))" @{label = $ResourceGroup; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor; } {
                    
                        #region parsing-arm-template-and-finding-resource-dependencies
                        $data = @()

                        $template = Export-AzResourceGroup -ResourceGroupName $ResourceGroup -SkipAllParameterization -Force -Path $env:TEMP\template.json
                        $arm = ConvertFrom-ArmTemplate -Path $template.Path
                        # $excluded_types = @("scheduledqueryrules","containers","solutions","modules","savedSearches")
                    
                        $data += $arm.Resources |
                        Where-Object { $_.type.tostring().split("/").count -le $depthlevel } |
                        ForEach-Object {
                            $dependson = $null
                            if ($_.dependson) {
                                $dependson = $_.DependsOn #| ForEach-Object { $_.ToString().split("parameters('")[1].split("')")[0]}
                                foreach ($dependency in $dependson) {                            
                                    $r = $rank["$($_.type.ToString())"]
                                    [PSCustomObject]@{
                                        fromcateg   = $_.type.ToString() #.split('/')[-1]
                                        from        = $_.name.ToString() #.split('/')[-1] #.split("parameters('")[1].split("')")[0]
                                        to          = $dependency.tostring().replace("[resourceId(", "").replace(")]", "").Split(",")[1].replace("'", "").trim() # -join '/' #.split('/')[-1]
                                        tocateg     = $dependency.tostring().replace("[resourceId(", "").replace(")]", "").Split(",")[0].replace("'", "").trim().Split("/")[0..1] -join '/' #.split('/')[-1]
                                        isdependent = $true
                                        rank        = if ($r) { $r }else { 9999 }
                                    }
                                }
                            }
                            else {
                                $r = $rank["$($_.type.ToString())"]
                                [PSCustomObject]@{
                                    fromcateg   = $_.type.ToString() #.split('/')[-1]
                                    from        = $_.name.ToString() #.split("parameters('")[1].split("')")[0]
                                    to          = ''
                                    tocateg     = ''
                                    isdependent = $false
                                    rank        = if ($r) { $r }else { 9999 }
                                }
                            }
                        } | 
                        Sort-Object Rank
                        #endregion parsing-arm-template-and-finding-resource-associations

                        #region plotting-edges-to-nodes

                        $data | 
                        Where-Object to | 
                        ForEach-Object {
                            $from = $_.from
                            $fromcateg = $_.fromcateg
                            $to = $_.to
                            $tocateg = $_.tocateg
                            if ($_.isdependent) {
                                Edge -From "$fromcateg$from".ToUpper() `
                                    -to "$tocateg$to".ToUpper() `
                                    -Attributes @{
                                    arrowhead = 'none';
                                    style     = 'dashed';
                                    label     = ''
                                    penwidth  = "1"
                                    fontname  = "Courier New"
                                }

                                if ($Information -eq 'level1') {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   
                                    Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows $to -Type $tocateg   
                                }
                                elseif ($Information -eq 'level2') {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                                    Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows ($to, $toCateg) -Type $tocateg   
                                }
                            }
                            else {
                                if ($Information -eq 'level1') {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   
                                }
                                elseif ($Information -eq 'level2') {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                                }
                            }
                        }
                        #endregion plotting-edges-to-nodes

                        # foreach($item in $data | Group-Object rank){
                        #     $nodes = foreach($group in $item.Group){
                        #         $from = $group.from
                        #         $fromcateg = $group.fromcateg
                        #         $to = $group.to
                        #         $tocateg = $group.tocateg
                        #         "`"$fromcateg$from`"".ToUpper()
                        #     }
                            
                        #     "{rank = `"same`"; $($nodes -join '; ')}"
                        # }
                    }
                    #endregion plotting-all-remaining-nodes
            
                }
                else {
                    Write-Verbose "Skipping resource group: `"$ResourceGroup`" as no resources were found."             
                }
            }
        } 
    }
    
    @"
strict $graph
"@ | Export-PSGraph -ShowGraph:$ShowGraph -OutputFormat $OutputFormat -DestinationPath C:\temp\out.png -OutVariable output
    #endregion graph-generation

    Write-Verbose "Graph Exported to path: $($output.fullname)"
}

Export-ModuleMember Get-AzViz