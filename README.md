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

![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/MultipleResourceGroup.jpg)
