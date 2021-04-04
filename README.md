# AzViz

Azure Visualizer aka 'AzViz' - PowerShell module to automatically generate Azure resource topology diagrams by just typing a PowerShell cmdlet and passing the name of one or more Azure Resource Group(s).

It is capable of:
 * Finding Resources in a Azure Resource Group and identifying their dependencies.
 * Plot nodes and edges to represent Azure Resources and their dependencies on a graph.
 * Insert appropriate Azure Icons on basis of resource category/sub-category.
 * Label each resource with information like Name, Category, Type etc.
 * Generate visualization in formats like: .png and .svg
 * Output image can be in 'light', 'dark' or 'neon' theme.
 
## Demo Video - Youtube

[![Demo Video](https://img.youtube.com/vi/7rsNGJ-QmEA/2.jpg)](https://www.youtube.com/watch?v=7rsNGJ-QmEA)
## How to use?

```PowerShell
git clone https://github.com/PrateekKumarSingh/AzViz.git

Set-Location .\AzViz\
   
Import-Module .\AzViz.psm1 -Verbose
```
### Target Single Resource Group

```PowerShell
# target single resource group
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowGraph
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroup.png)
### Target Single Resource Group with more sub-categories

```PowerShell
# target single resource group with more sub-categories
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowGraph -CategoryDepth 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroupSubCategories.png)
### Target Multiple Resource Groups

```PowerShell
# target multiple resource groups
Get-AzViz -ResourceGroups demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Verbose -ShowGraph -OutputFormat png
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/MultipleResourceGroups.png)
### Add Verbosity to Resource Label

```PowerShell
# adding more information in resource label like: Name, type, Provider etc
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowGraph -LabelVerbosity 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/LabelVerbosity.png)
