# ⚡ Azure Visualizer, aka 'AzViz' 

[![PowerShell Gallery][psgallery-version-badge]][psgallery] [![PowerShell Gallery][psgallery-badge]][psgallery] [![GitHub issues][github-issues-badge]][github-issues] [![CI][github-action-ci-badge]][github-action-ci] [![Documentation Status][docs-badge]][docs] [![License][license-badge]][license]

[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/AzViz.svg
[docs-badge]: https://readthedocs.org/projects/azviz/badge/?version=latest
[docs]: http://AzViz.readthedocs.io/en/latest/
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/AzViz.svg
[psgallery]: https://www.powershellgallery.com/packages/AzViz
[license-badge]: https://img.shields.io/github/license/PrateekKumarSingh/AzViz.svg
[license]: https://www.powershellgallery.com/packages/AzViz
[github-issues-badge]: https://img.shields.io/github/issues/PrateekKumarSingh/AzViz.svg
[github-issues]: https://github.com/PrateekKumarSingh/AzViz/issues
[github-action-ci-badge]: https://github.com/PrateekKumarSingh/AzViz/actions/workflows/main.yml/badge.svg
[github-action-ci]: https://github.com/PrateekKumarSingh/AzViz/actions/workflows/main.yml

Azure Visualizer aka 'AzViz' - PowerShell module to automatically generate Azure resource topology diagrams by just typing a PowerShell cmdlet and passing the name of one or more Azure Resource Group(s).

> _Cloud admins are not anymore doomed to manually document a cloud environment! The pain of inheriting an undocumented cloud landscape to support is gone 😎😉 so please share this project with your colleagues and friends._

## Important Note to AzViz Users
> As the author of this PowerShell module, I’m exploring the idea of transforming AzViz into a cloud-agnostic, AI-powered web app. I’d love to hear your thoughts and feedback on this! 🚀

- Participate in the Poll: https://github.com/PrateekKumarSingh/AzViz/discussions/127
- Linkedin Post on why?: https://www.linkedin.com/feed/update/urn:li:activity:7288900178210693120/


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
 
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/themeneon.jpg)

## Thanks and shoutouts

> Special thanks & shoutout to [`Kevin Marquette`](https://twitter.com/KevinMarquette) and his [`PSGraph`](https://www.powershellgallery.com/packages/PSGraph/2.1.38.27) module which seeded the idea for programmatical approach to Azure Visualization while I was working with Kevin's module. And without which 'AzViz' module won't be possible! ♥👍

## Demo Video - Youtube

[![Demo Video](https://img.youtube.com/vi/7rsNGJ-QmEA/0.jpg)](https://www.youtube.com/watch?v=7rsNGJ-QmEA)

## Prerequisite

We need to install GraphViz on our system before we can proceed with using the 'AzViz' PowerShell module. Depending upon the operating system you are using please follow the below mentioned steps:
### Linux


```bash
# Ubuntu
$ sudo apt install graphviz

# Fedora
$ sudo yum install graphviz

# Debian
$ sudo apt install graphviz
```

### Windows

```PowerShell
# chocolatey packages Graphviz for Windows
choco install graphviz

# alternatively using windows package manager
winget install graphviz
```

### Mac

```PowerShell
brew install graphviz
```

## Installation 
### From PowerShell Gallery

```PowerShell
# install from powershell gallery
Install-Module -Name AzViz -Scope CurrentUser -Repository PSGallery -Force

# import the module
Import-Module AzViz

# login to azure, this is required for module to work
Connect-AzAccount
```

### Clone the project from GitHub

```PowerShell
# optionally clone the project from github
git clone https://github.com/PrateekKumarSingh/AzViz.git
Set-Location .\AzViz\AzViz
   
# import the powershell module
Import-Module .\AzViz.psm1 -Verbose

# login to azure, this is required for module to work
Connect-AzAccount
```

## How to use?

### Target Single Resource Group

```PowerShell
# target single resource group
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroup.png)
### Target Single Resource Group with more sub-categories

```PowerShell
# target single resource group with more sub-categories
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -CategoryDepth 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/SingleResourceGroupSubCategories.png)
### Target Multiple Resource Groups

```PowerShell
# target multiple resource groups
Export-AzViz -ResourceGroup demo-2, demo-3 -LabelVerbosity 1 -CategoryDepth 1 -Theme light -Show -OutputFormat png
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/MultipleResourceGroups.png)
### Add Verbosity to Resource Label

```PowerShell
# adding more information in resource label like: Name, type, Provider etc
Export-AzViz -ResourceGroup demo-2 -Theme light -OutputFormat png -Show -LabelVerbosity 2
```
![](https://github.com/PrateekKumarSingh/AzViz/blob/master/img/LabelVerbosity.png)


## Change Log

### v1.2.1
 - Fixed casing for `loadbalancer.png` in `AzViz/src/private/Images.ps1` to match the filename for `AzViz/icons/LoadBalancers.png` as AzViz could not find the icon when run from pwsh on a Linux VM. [pull-request](https://github.com/PrateekKumarSingh/AzViz/pull/59) by [@madsaune](https://github.com/madsaune)

### v1.2.0
- Handled condition to skip resources out of resource group, this should fix [issue#37](https://github.com/PrateekKumarSingh/AzViz/issues/37) and [issue#39](https://github.com/PrateekKumarSingh/AzViz/issues/39) 
- Handled period in resource group name, this should fix [issue#41](https://github.com/PrateekKumarSingh/AzViz/issues/41)
- If there are no edges between the nodes, then graph legends are not plotted, this should fix [issue#38](https://github.com/PrateekKumarSingh/AzViz/issues/38)
- Empty resource groups skips, resource visualization for all later targets, this should fix [issue#50](https://github.com/PrateekKumarSingh/AzViz/issues/50). Thanks [@madsaune](https://github.com/madsaune) finding the bug and creating the issue.
- Add Vnet-only resource groups to graph visualization. Special thanks to [@madsaune](https://github.com/madsaune) for the [pull-request](https://github.com/PrateekKumarSingh/AzViz/pull/52)

### v1.1.2
- Network infra and the associated resources are represented in much better way 
- Improve network diagrams with Virtual Networks containing Subnets and resources
- Azure Icons with labels showing informarion on Subscriptions, RGs, VNet, Subnets
- Excluding Azure resource types/providers
- Supports empty virtual networks
- Improved dark and neon themes
- Supports diagram legends
- Bug Fixes
