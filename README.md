# AzViz - Azure Visualizer

Azure Visualizer aka 'AzViz' - PowerShell module to automatically generate Azure resource topology diagrams by just typing a PowerShell cmdlet and passing the name of one or more Azure Resource Group(s).


> _Cloud admins are not anymore doomed to manually document a cloud environment! The pain of inheriting an undocumented cloud landscape to support is gone 😎😉 so please share this project with your colleagues and friends._

<a href="https://www.buymeacoffee.com/prateeksingh" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

It is capable of:
 * Finding Resources in a Azure Resource Group and identifying their dependencies.
 * Plot nodes and edges to represent Azure Resources and their dependencies on a graph.
 * Insert appropriate Azure Icons on basis of resource category/sub-category.
 * Label each resource with information like Name, Category, Type etc.
 * Generate visualization in formats like: .png and .svg
 * Output image can be in 'light', 'dark' or 'neon' theme.
 * Can target more than one resource group at once.
 * Change direction in which resource groups are plotted, i.e, left-to-right or top-to-bottom.
 
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/LabelVerbosity.png)

## Demo Video - Youtube

[![Demo Video](https://img.youtube.com/vi/7rsNGJ-QmEA/0.jpg)](https://www.youtube.com/watch?v=7rsNGJ-QmEA)
## How to use?

```PowerShell
# clone the project from github
git clone https://github.com/PrateekKumarSingh/AzViz.git

Set-Location .\AzViz\
   
# import the powershell module
Import-Module .\AzViz.psm1 -Verbose

# login to azure
Connect-AzAccount
```
### Target Single Resource Group

```PowerShell
# target single resource group
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowVisualization
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroup.png)
### Target Single Resource Group with more sub-categories

```PowerShell
# target single resource group with more sub-categories
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowVisualization -CategoryDepth 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroupSubCategories.png)
### Target Multiple Resource Groups

```PowerShell
# target multiple resource groups
Get-AzViz -ResourceGroups demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Verbose -ShowVisualization -OutputFormat png
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/MultipleResourceGroups.png)
### Add Verbosity to Resource Label

```PowerShell
# adding more information in resource label like: Name, type, Provider etc
Get-AzViz -ResourceGroups demo-2 -Theme light -Verbose -OutputFormat png -ShowVisualization -LabelVerbosity 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/LabelVerbosity.png)
