# AzViz

Azure Visualizer aka 'AzViz' - PowerShell module to automatically generate Azure resource topology diagrams by just typing a PowerShell cmdlet and passing the name of one or more Azure Resource Group(s).

It is capable of:
 * Finding Resources in a Azure Resource Group and identifying their dependencies.
 * Plot nodes and edges to represent Azure Resources and their dependencies on a graph.
 * Insert appropriate Azure Icons on basis of resource category/sub-category.
 * Label each resource with information like Name, Category, Type etc.
 * Generate visualization in formats like: .png and .svg
 * Output image can be in 'light', 'dark' or 'neon' theme.

#powershell #automation #azure #azurepowershell #infrastructureascode #infrastructureautomation #pwsh #code #dotnet #aurepwsh #graphviz #automationtools #azurecloud #devops #armtemplates #microsoft #cloud #arm

https://youtu.be/7rsNGJ-QmEA


## How to use?

```PowerShell
git clone https://github.com/PrateekKumarSingh/AzViz.git

Set-Location .\AzViz\
   
Import-Module .\AzViz.psm1

Get-AzViz -ResourceGroups 'demo-1','demo-2' -LabelVerbosity 2 -CategoryDepth 2 -Theme light -Verbose -ShowGraph -OutputFormat png
```

![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroup.jpg)


### Demo Video

https://youtu.be/7rsNGJ-QmEA