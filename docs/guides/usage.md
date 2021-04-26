# Usage

## Target Single Resource Group

```PowerShell
# target single resource group
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show
```
![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/SingleResourceGroup.png)

## Target Single Resource Group with more sub-categories

```PowerShell
# target single resource group with more sub-categories
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -CategoryDepth 2
```
![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/SingleResourceGroupSubCategories.png)

## Target Multiple Resource Groups

```PowerShell
# target multiple resource groups
Export-AzViz -ResourceGroup demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Show -OutputFormat png
```

![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/MultipleResourceGroups.png)

## Add Verbosity to Resource Label

```PowerShell
# adding more information in resource label like: Name, type, Provider etc
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -LabelVerbosity 2
```

![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/LabelVerbosity.png)
