# Azure Visualizer

## Description

Azure Visualizer aka 'AzViz' - PowerShell module to automatically generate Azure resource topology diagrams by just typing a PowerShell cmdlet and passing the name of one or more Azure Resource Group(s).

> _Cloud admins are not anymore doomed to manually document a cloud environment! The pain of inheriting an undocumented cloud landscape to support is gone 😎😉 so please share this project with your colleagues and friends._

## Capabilities

 * Finding Resources in a Azure Resource Group and identifying their dependencies.
 * Plot nodes and edges to represent Azure Resources and their dependencies on a graph.
 * Insert appropriate Azure Icons on basis of resource category/sub-category.
 * Label each resource with information like Name, Category, Type etc.
 * Generate visualization in formats like: .png and .svg
 * Output image can be in 'light', 'dark' or 'neon' theme.
 * Can target more than one resource group at once.
 * Change direction in which resource groups are plotted, i.e, left-to-right or top-to-bottom.
 * Network infra and the associated resources are represented in much better way
 * Improve network diagrams with Virtual Networks containing Subnets and resources
 * Azure Icons with labels showing information on Subscriptions, RGs, VNet, Subnets
 * Excluding Azure resource types/providers
 * Supports empty virtual networks
 * Improved dark and neon themes
 * Supports diagram legends
 
![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/themeneon.jpg)

![](https://raw.githubusercontent.com/PrateekKumarSingh/AzViz/master/img/themedark.jpg)

## Demo Video

[![Demo Video](https://img.youtube.com/vi/7rsNGJ-QmEA/0.jpg)](https://www.youtube.com/watch?v=7rsNGJ-QmEA)

## Future of this Module

* Right now I'm fiddling with two ideas to generate the visualization
using **dependsOn property** in ARM template to find dependency in an ARM template
and using Network watcher to find associations. Which also provides the network flow like **`PublicIP > LoadBalancer > NIC > VM`**. I may end up using both because both have pros and cons, and by overlaying data from both these approaches on the same graph will give amazing details and insights of you Azure infrastructure.

* Today we only use '**GraphViz**' which is open-source visualization software, I will add support for more visualization engines, graphing tools like: Visio, Lucid Charts, etc

* Ability to expose '**Custom properties**' of an Azure resource type on the image, like IPAddress on NIC card etc

* Right now, the module doesn't support **clustering similar resources and subcategories into a logical cluster/group**. This is a work in progress and would make the diagram much easier to understand once implemented

* Ability to exclude Azure resource types like `Microsoft.Storage/storageAccounts/blobServices`
Support visualization from ARM templates passed as an URL or a local File - Work in progress!.

* **Infrastructure DIFF!** yeah, you heard it right this is going to be my favorite feature to implement. This will give us the **ability to identify/detect what has changed in Azure infrastructure**, for example, a resource has been deleted, or IPAddress has been changed something like that.
