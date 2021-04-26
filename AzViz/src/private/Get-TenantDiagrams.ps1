# https://www.reddit.com/r/PowerShell/comments/mmxq6a/powershell_module_to_visualize_and_document_azure/gtwb6uf?utm_source=share&utm_medium=web2x&context=3
function Get-TenantDiagrams {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet('light', 'dark', 'neon')]$theme,
        [Parameter(Mandatory = $true)][ValidateScript( { Test-Path -Path $_ -IsValid })][string] $OutputFilePath,
        [Parameter(Mandatory = $false)][ValidateSet(1, 2, 3)][int] $LabelVerbosity = 3,
        [Parameter(Mandatory = $false)][ValidateSet(1, 2, 3)][int] $CategoryDepth = 3,
        [Parameter(Mandatory = $false)][ValidateSet('png', 'svg')][string] $OutputFormat = 'png',
        [Parameter(Mandatory = $false)][ValidateSet('left-to-right', 'top-to-bottom')][string] $Direction = 'left-to-right'
    )

    $script:dateis = Get-Date -Format MM-dd-yyyy

    if ($OutputFormat -eq 'svg') {
        $script:extension = '.svg'
    }
    else {
        $script:extension = '.png'
    }


    $Subscriptions = Get-AzSubscription

    foreach ($sub in $Subscriptions) {
        Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
        $script:name = $sub.name
        New-Item -Path $OutputFilePath\$dateis\$name -ItemType Directory | Out-Null
        $AZResourcegroups = Get-AzResourceGroup

        foreach ($RGName in $AZResourcegroups) {

            $RG = $RGName.resourcegroupname
            $filename = $RG + $extension

            $Params = @{
                ResourceGroup  = $RG
                OutputFilePath = "$OutputFilePath\$dateis\$name\$filename"
                Theme          = $Theme
                OutputFormat   = $OutputFormat
                CategoryDepth  = $CategoryDepth
                Direction      = $Direction
                LabelVerbosity = $LabelVerbosity
            }

            Get-AzViz @params

        }
    }
}