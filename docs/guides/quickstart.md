# Quickstart

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
Install-Module AzViz -Verbose -Scope CurrentUser -Force

# import the module
Import-Module AzViz -Verbose

# login to azure, this is required for module to work
Connect-AzAccount
```

### Clone the project from GitHub

```PowerShell
# optionally clone the project from github
git clone https://github.com/PrateekKumarSingh/AzViz.git
Set-Location .\AzViz\
   
# import the powershell module
Import-Module .\AzViz.psm1 -Verbose

# login to azure, this is required for module to work
Connect-AzAccount
```