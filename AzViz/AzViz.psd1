#
# Module manifest for module 'AzViz'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'AzViz.psm1'

# Version number of this module.
ModuleVersion = '1.2.1'

# Supported PSEditions
CompatiblePSEditions = @('Desktop','Core')

# ID used to uniquely identify this module
GUID = '2ef9c59e-fdab-4d6a-a3cf-ba466a0788c6'

# Author of this module
Author = 'Prateek Singh'

# Company or vendor of this module
CompanyName = 'ridicurious.com'

# Copyright statement for this module
Copyright = '(c) 2021 Prateek Singh. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Create automated diagrams of Azure Resources and dependencies'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @('PSGraph', 'Az.Accounts', 'Az.Resources')

RequiredModules = @(
    @{ModuleName = 'PSGraph'; ModuleVersion = '2.1.38.27'}
    @{ModuleName = 'Az.Accounts';       ModuleVersion = '2.2.8'}
    @{ModuleName = 'Az.Resources';       ModuleVersion = '3.4.1'}
    @{ModuleName = 'Az.Network'; ModuleVersion = '4.11.0'}
    @{ModuleName = 'Az.Compute'; ModuleVersion = '4.17.0'}
)

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Export-AzViz')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @('AzViz')

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Azure','Diagrams','Architecture','GraphViz','Topology','Documentation')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PrateekKumarSingh/AzViz/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PrateekKumarSingh/AzViz'

        # ExternalModuleDependencies = @('PSGraph', 'Az.Accounts', 'Az.Resources')

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @"
v1.2.* :
- handled condition to skip resources out of resource group, this should fix issue#37 and issue#39 
- handled period in resource group name, this should fix issue#41
- If there are no edges between the nodes, then graph legends are not plotted, this should fix issue#38 
- empty resource groups skips, resource visualization for all later targets, this should fix issue#50 

v1.1.2 :     
- Network infra and the associated resources are represented in much better way 
- Improve network diagrams with Virtual Networks containing Subnets and resources
- Azure Icons with labels showing informarion on Subscriptions, RGs, VNet, Subnets
- Excluding Azure resource types/providers
- Supports empty virtual networks
- Improved dark and neon themes
- Supports diagram legends
- Bug Fixes
"@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
