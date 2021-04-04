<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ResourceGroups
Target resource groups 

.PARAMETER ShowGraph
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

.EXAMPLE
An example

Get-AzViz -ResourceGroups demo-2 -LabelVerbosity 2 -CategoryDepth 2 -Theme light -Verbose -ShowGraph -OutputFormat png

.NOTES
Project URL: https://github.com/PrateekKumarSingh/azviz
Author: 
    https://twitter.com/singhprateik
    https://www.linkedin.com/in/prateeksingh1590
#>
function Get-AzViz {
    [alias("AzViz")]
    [CmdletBinding()]
    param (
        # Target resource groups 
        [string[]]
        $ResourceGroups = (Get-AzResourceGroup).ResourceGroupName,
        # Launches visualization image
        [switch] $ShowGraph,
        # Level of information to included in vizualization
        [ValidateSet(1, 2, 3)]
        [int] $LabelVerbosity = 1,
        # Level of Azure Resource Sub-category to be included in vizualization
        [ValidateSet(1, 2, 3)]
        [int] $CategoryDepth = 1,
        # Output format of the vizualization
        [ValidateSet('png', 'svg')]
        [string]
        $OutputFormat = 'png',
        # Changes the color theme, i.e light or dark
        [ValidateSet('light', 'dark', 'neon')]
        [string] $Theme = 'light'
    )
        
    #region defaults

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
            $SubGraphColor = 'x11green'
            $GraphFontColor = 'x11green'
            $EdgeColor = 'x11green'
            $EdgeFontColor = 'x11green'
            $NodeColor = 'x11green'
            $NodeFontColor = 'x11green'
            break
        }
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
    Write-Verbose " [+] Label Verbosity      : $LabelVerbosity"
    Write-Verbose " [+] Category Depth       : $CategoryDepth"
    Write-Verbose " [+] Theme                : $Theme"
    Write-Verbose " [+] Output Format        : $OutputFormat"
    Write-Verbose " [+] Launch Visualization : $ShowGraph"

    #endregion defaults

    #region graph-generation
    Write-Verbose "Starting to generate Azure visualization..."
    Write-Verbose "Target resource groups: $($ResourceGroups.ForEach({"'{0}'" -f $_}) -join ', ')"
    $graph = Graph 'Visualization' @{overlap = 'false'; splines = 'true' ; rankdir = 'TB'; color = $GraphColor; bgcolor = $GraphColor; fontcolor = $GraphFontColor } {
        
        edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
        node @{color = $NodeColor ; fontcolor = $NodeFontColor }
        
        if (Test-AzLogin) {
            foreach ($ResourceGroup in $ResourceGroups) {
                
                $resources = Get-AzResource -ResourceGroupName $ResourceGroup
                if ($resources) {

                    Write-Verbose " [+] Plotting sub-graph for resource group: `"$ResourceGroup`""
                    # Write-Verbose " [+] Total resources found: $($resources.count)"

                    SubGraph "$($ResourceGroup.Replace('-', ''))" @{label = $ResourceGroup; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor; } {
                    
                        #region parsing-arm-template-and-finding-resource-dependencies
                        $data = @()

                        $template = Export-AzResourceGroup -ResourceGroupName $ResourceGroup -SkipAllParameterization -Force -Path $env:TEMP\template.json
                        $arm = ConvertFrom-ArmTemplate -Path $template.Path
                        # $excluded_types = @("scheduledqueryrules","containers","solutions","modules","savedSearches")
                    
                        $data += $arm.Resources |
                        Where-Object { $_.type.tostring().split("/").count -le $($CategoryDepth+1) } |
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
                        Tee-Object -Variable pipe_var |
                        ForEach-Object {
                            $from = $_.from
                            $fromcateg = $_.fromcateg
                            $to = $_.to
                            $tocateg = $_.tocateg
                            if ($_.isdependent) {
                                Edge -From "$fromcateg$from".ToUpper() `
                                    -to "$tocateg$to".ToUpper() `
                                    -Attributes @{
                                    arrowhead = 'normal';
                                    style     = 'dotted';
                                    label     = 'dependsOn'
                                    penwidth  = "1"
                                    fontname  = "Courier New"
                                }

                                Write-Verbose "   > Creating Edge: $from -> $to"

                                if ($LabelVerbosity -eq 1) {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   
                                    Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows $to -Type $tocateg
    
                                    Write-Verbose "   > Creating Node: $from"
                                    Write-Verbose "   > Creating Node: $to"
                                }
                                elseif ($LabelVerbosity -eq 2) {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                                    Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows ($to, $toCateg) -Type $tocateg   

                                    Write-Verbose "   > Creating Node: $from"
                                    Write-Verbose "   > Creating Node: $to"
                                }
                            }
                            else {
                                if ($LabelVerbosity -eq 1) {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   

                                    Write-Verbose "   > Creating Node: $from"
                                }
                                elseif ($LabelVerbosity -eq 2) {
                                    Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                                    Write-Verbose "   > Creating Node: $to"
                                }
                            }
                        }

                        # Write-Verbose " [+] Total resources filtered: $($pipe_var.count)"
                        if(!$pipe_var){
                            Write-Warning " [-] No resources found.. re-run the command and try increasing the category depth using -Depth level2 or -Depth level3 cmdlet parameters." -Verbose
                        }
                        #endregion plotting-edges-to-nodes

                        #region ranking-nodes

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

                        #endregion ranking-nodes

                    }
                    #endregion plotting-all-remaining-nodes
                }
                else {
                    Write-Verbose " [-] Skipping resource group: `"$ResourceGroup`" as no resources were found."             
                }
            }
        } 
    }
    
    @"
strict $graph
"@ | 
    Export-PSGraph -ShowGraph:$ShowGraph -OutputFormat $OutputFormat -DestinationPath C:\temp\out.png -OutVariable output |
    Out-Null
    #endregion graph-generation

    Write-Verbose "Graph Exported to path: $($output.fullname)"
    Write-Verbose "Finished Azure visualization."
}

Export-ModuleMember Get-AzViz