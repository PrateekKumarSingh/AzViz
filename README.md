# AzViz

PowerShell Module that can generate a topology diagram to Visualize Azure Network Topology and ARM templates (WIP). It has capabilities to insert appropriate Azure Icons depending upon the type of the Azure Resource you have in your Resource Group, like Virtual Machine, Virtual Network, Subnet etc.


# Azure Resource Network Topology Visualization

### Working with Single Azure Resource Group

```PowerShell
Import-Module AzViz

Get-AzNetworkVizualization -ResourceGroups 'test-resource-group' -ShowGraph -OutputFormat png -Verbose
```

![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroup.jpg)


### Working with Multiple Azure Resource Group

```PowerShell
$ResourceGroups = 'test-resource-group', 'demo-resource-group'
Get-AzNetworkVizualization -ResourceGroups $ResourceGroups  -ShowGraph -OutputFormat png -Verbose
```

![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/MultipleResourceGroups.jpg)





# Does this looks like Network Watcher -> Monitor -> Topology feature? 

A couple of things... but before I begin, even this module uses Azure Network Watcher to get associations between each Azure resource, which is returned as a JSON text from Get-AzNetworkWatcherTopology, so following are some advantages this will offer -

1. Network Watcher Topology feature can be used at one resource Group at a time, and it is manual steps. While this module can work on multiple resource groups at once and create a topology diagram for all the resource groups in the entire Azure subscription.

2. Since it is written in PowerShell it becomes easy to generate automated diagrams and reports, to avoid manual activity. This means it can be incorporated with existing reports and scripts.

3. Since each Graph node is an Azure Resource, you can perform a Get-AzResource cmdlet to query more information, which will add more verbosity to graph-like, VMs can show IPAddress and OS with the node icon apart from just name.. I'll be adding this feature very soon.. The Topology Diagram doesn't have this feature it only shows the name of the Azure Resource, a very vanilla diagram.

4. You will also get the option to choose Node Ranking and Node grouping with module very soon.. that means you can place certain nodes on the same level in the graph and even group them into subgroups to make visual tiers like 'Front-end', 'Back-end' , 'tier1','tier2' etc.

5. My understanding tells me, that Azure Network topology Diagrams only have Azure Resource Associations, but they don't show 'Containment' relationship like NIC is contained in a VM or something like that, this graph can also show that.

6. It will also provide a single module to visualize existing network topology and ARM templates.

I'm sure I would be able to implement more features, like colors, shapes, styles, fonts in coming time... and a lot of other functionalities like generating graphs in different output formats that can be even used in HTML webpages.. still a lot of work to do, and like I said in the post Module is still in very premature state. stay tuned.
