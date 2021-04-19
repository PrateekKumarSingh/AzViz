function ConvertTo-DOTLanguage {
    [CmdletBinding()]
    param (
        [string[]] $Targets,
        [ValidateSet('Azure Resource Group')]
        [string] $TargetType = 'Azure Resource Group',
        [int] $LabelVerbosity = 1,
        [int] $CategoryDepth = 1,
        [string] $Direction = 'top-to-bottom',
        [string] $Splines = 'spline'
    )
    
    begin {
        switch ($Direction) {
            'left-to-right' { $rankdir = "LR" }
            'top-to-bottom' { $rankdir = "TB" }
        }
    }
    
    process {

        if (!(Test-AzLogin)) {
            break
        }
        
        $GraphObjects = @()

        $ARMObjects = ConvertFrom-ARM -TargetType $TargetType -Targets $Targets -CategoryDepth $CategoryDepth
        $GraphObjects += $ARMObjects
        $NetworkObjects = ConvertFrom-Network -TargetType $TargetType -Targets $Targets -CategoryDepth $CategoryDepth
        $GraphObjects += $NetworkObjects

        $GraphObjects = $GraphObjects | 
        Group-Object Name | 
        ForEach-Object {
            [PSCustomObject]@{
                Name      = $_.Name
                Type      = $_.group.type | Select-Object -First 1
                Resources = $_.group.Resources
            }
        } | 
        Sort-Object Rank
        
        $Counter = 0
        $subgraphs = foreach ($Target in $GraphObjects) {
            $Counter = $Counter + 1              
            Write-Verbose " [+] Plotting sub-graph for $($Target.Type): `"$($Target.Name)`""  

            $VNet = Get-AzVirtualNetwork -ResourceGroupName $Target.Name

            if ($VNet) {

                $VMs_and_NICs = @()
                $VMs = Get-AzVM -ResourceGroupName $Target.Name
                $NICs = Get-AzNetworkInterface -ResourceGroupName $Target.Name

                $VMs_and_NICs += $VMs
                $VMs_and_NICs += $NICs
    
                $VNet_Label = Get-ImageLabel -Type "Microsoft.Network/virtualNetworks" -Row1 "$($VNet.Name)" -Row2 "$([string]$VNet.AddressSpace.AddressPrefixes)"

                $network_layout = SubGraph $VNet.Name @{label = $VNet_Label; labelloc = 't'; penwidth = "1"; fontname = "Courier New" ; style = "rounded,dashed"; bgcolor = "mintcream" } {
                    foreach ($subnet in $VNet.Subnets) {
                        $Subnet_Label = Get-ImageLabel -Type "Subnets" -Row1 "$($Subnet.Name)" -Row2 "$([string]$Subnet.AddressPrefix)"
                        SubGraph $subnet.Name.Replace('-', '') @{label = $Subnet_Label; labelloc = 't'; penwidth = "1"; fontname = "Courier New" ; style = "rounded,dashed"; bgcolor = "whitesmoke"; } {    

                            $resources_in_subnet = foreach ($item in $VMs_and_NICs) {

                                switch ($item.Type) {
                                    'Microsoft.Compute/virtualMachines' {
                                        $networkInterface = $NICs.Where( { $_.name -eq ($item.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1]) })
                                        $subnetName = $networkInterface.IpConfigurations[0].Subnet.Id.split('/')[-1] 
                                    }
                                    'Microsoft.Network/networkInterfaces' {
                                        $subnetName = $item.IpConfigurations[0].Subnet.Id.split('/')[-1] 
                                    }
                                }

                                if ($subnetName -eq $subnet.Name) {
                                    $item | Select-Object Name, Type
                                }
                            }

                            $resources_in_subnet |
                            ForEach-Object {
                                Get-ImageNode -Name "$($_.Type)$($_.Name)".ToUpper() -Rows $_.Name -Type $_.Type
                            }
                        }
                    }
                }
            }

            #region plotting-edges-to-nodes
            $nodes_and_edges = $Target.Resources |
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
                        style     = 'dashed';
                        # label     = 'dependsOn'
                        penwidth  = "1"
                        fontname  = "Courier New"
                        color     = "lightslategrey"
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
                if ($_.association) {
                    Edge -From "$fromcateg$from".ToUpper() `
                        -to "$tocateg$to".ToUpper() `
                        -Attributes @{
                        arrowhead = 'normal';
                        style     = 'solid';
                        penwidth  = "1"
                        fontname  = "Courier New"
                        color     = "royalblue2"
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
            } | 
            Select-Object -Unique
                    
                
            # Write-Verbose " [+] Total resources filtered: $($pipe_var.count)"
            if (!$nodes_and_edges) {
                Write-Warning " [-] No resources found.. re-run the command and try increasing the category depth using -CategoryDepth 2 or -CategoryDepth 3 cmdlet parameters." -Verbose
            }
            else {
                $resourcegroup_location = (Get-AzResourceGroup -Name $Target.Name).Location
                $SubGraphName_Label = Get-ImageLabel -Type "ResourceGroups" -Row1 "Subscription: $($Target.Name)" -Row2 "Id: $($resourcegroup_location)"

                SubGraph "$($($Target.Type).Replace(' ',''))$Counter" @{label = $SubGraphName_Label; labelloc = 't'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor; style = "rounded, dashed"; bgcolor = "ghostwhite"; fontsize = "9"; } {

                    $network_layout
                    $nodes_and_edges
                }
            }
            #endregion plotting-edges-to-nodes
        }

        $Legend = @()
        $Legend += '    subgraph clusterLegend {'
        $Legend += '        label = "Legend\n\n";'
        $Legend += '        rank = 9999999999999'
        $Legend += '        bgcolor = aliceblue'
        $Legend += '        fontcolor = Black'
        $Legend += '        fontsize = 11'
        $Legend += '        node [shape=point]'
        $Legend += '        {'
        $Legend += '            rank=same'
        $Legend += '            d0 [style = invis];'
        $Legend += '            d1 [style = invis];'
        $Legend += '            p0 [style = invis];'
        $Legend += '            p1 [style = invis];'
        $Legend += '        }'
        $Legend += '        d0 -> d1 [arrowhead="normal";style="dashed";label="Resource\nDependency";color="lightslategrey";fontname="Courier New";penwidth="1";fontsize="9"]'
        $Legend += '        p0 -> p1 [style="solid";fontname="Courier New";label="Netowrk\nAssociation";arrowhead="normal";color="royalblue2";penwidth="1";fontsize="9"]'
        $Legend += '    }'



        if ($subgraphs) {
            $Subscription = (Get-AzContext).Subscription
            $graph = Graph 'Visualization' @{sep = 15; rankdir = $rankdir; overlap = 'false'; splines = $Splines ; color = $GraphColor; bgcolor = $GraphColor; penwidth = "1"; fontname = "Courier New" ; fontcolor = $GraphFontColor; fontsize = "9"; } {
                
                $MainGraph_Label = Get-ImageLabel -Type "Subscriptions" -Row1 "Subscription: $($Subscription.name)" -Row2 "Id: $($Subscription.Id)"
                SubGraph "main" @{label = $MainGraph_Label; fontsize = "9"; style="rounded,solid"; bgcolor="ivory1";} {
            
                    edge @{color = $EdgeColor; fontcolor = $EdgeFontColor; fontsize = "11" }
                    node @{color = $NodeColor ; fontcolor = $NodeFontColor; fontsize = "11" }
                
                    $subgraphs
                }

                $Legend
            }

            # hack to fix issue because of double-quotes in image labels
            $graph = $graph | ForEach-Object {
                if($_ -like '*"<<TABLE*'){
                    $_.replace('"','')
                }
                else{
                    $_
                }
            } 

            # to indent and validate the dot language generated by powershell
            $GraphViz = Get-DOTExecutable

            if ( $null -eq $GraphViz ) {
                Write-Error "'GraphViz' is not installed on this system and is a prerequisites for this module to work. Please download and install from here: https://graphviz.org/download/ and re-run this command." -ErrorAction Stop
            }
            else {
                $dot_file = (Join-Path ([System.IO.Path]::GetTempPath()) "temp.dot")
                $graph | Out-String | Out-File $dot_file -Verbose
                if (Test-Path $dot_file) {
                    if ($IsLinux) {
                        Invoke-Expression "$($GraphViz.FullName) $dot_file"
                    }
                    else {
                        & $GraphViz.FullName $dot_file
                    }

                    # Remove-Item $dot_file -Force
                }
                else {
                    $graph | Out-String 
                }
            }

        }
    }
    
    end {
        
    }
}