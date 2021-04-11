<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ResourceGroups
Target resource groups 

.PARAMETER Show
Launches visualization image

.PARAMETER LabelVerbosity
Level of information to included in vizualization

.PARAMETER CategoryDepth
Level of Azure Resource Sub-category to be included in vizualization

-CategoryDepth 'level1' only allow resource catergores like: Microsoft.EventGrid/topics and  Microsoft.ServiceBus/namespaces
-CategoryDepth 'level2' only allow resource catergores like: Microsoft.ServiceBus/namespaces/AuthorizationRules and  Microsoft.ServiceBus/namespaces/networkRuleSets

.PARAMETER OutputFormat
Output format of the vizualization, i.e, .png or .svg

.PARAMETER Theme
Changes the color theme, i.e 'light', 'dark' or 'neon'. Default is 'light'.

.PARAMETER Direction
Direction in which resource groups are plotted on the visualization

.PARAMETER OutputFilePath
Output file path

.EXAMPLE
An example

Export-AzViz -ResourceGroups demo-2 -LabelVerbosity 2 -CategoryDepth 2 -Theme light -Verbose -ShowGraph -OutputFormat png

.NOTES
Project URL: https://github.com/PrateekKumarSingh/azviz
Author: 
    https://twitter.com/singhprateik
    https://www.linkedin.com/in/prateeksingh1590
#>
function Export-AzViz {
    [alias("AzViz")]
    [CmdletBinding()]
    param (
        # Names of target resource groups 
        [Parameter(ParameterSetName = 'AzLogin', Mandatory = $true, Position = 0)]
        [string[]] $ResourceGroup,

        # # File paths to target ARM templates
        # [Parameter(ParameterSetName = 'FilePath', Mandatory = $true, Position = 0)]
        # [System.IO.Path[]] $Path,

        # # URLs to target ARM templates
        # [Parameter(ParameterSetName = 'Url', Mandatory = $true, Position = 0)]
        # [uri[]] $Url,
        
        # Launches visualization image
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [switch] $Show,
        
        # Level of information to included in vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet(1, 2, 3)]
        [int] $LabelVerbosity = 1,
        
        # Level of Azure Resource Sub-category to be included in vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet(1, 2, 3)]
        [int] $CategoryDepth = 1,
        
        # Output format of the vizualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('png', 'svg')]
        [string] $OutputFormat = 'png',
        
        # Changes the color theme, i.e light or dark
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('light', 'dark', 'neon')]
        [string] $Theme = 'light',

        # Direction in which resource groups are plotted on the visualization
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateSet('left-to-right', 'top-to-bottom')]
        [string] $Direction = 'top-to-bottom',

        # Output file path
        [Parameter(ParameterSetName = 'AzLogin')]
        # [Parameter(ParameterSetName = 'FilePath')]
        # [Parameter(ParameterSetName = 'Url')]
        [ValidateScript( { Test-Path -Path $_ -IsValid })]
        [string] $OutputFilePath = (Join-Path ([System.IO.Path]::GetTempPath()) "output.$OutputFormat")
    )
        
    #region defaults
    try {
        $ErrorActionPreference = 'stop'

        $ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $ModuleVersion = (Import-PowerShellDataFile (Join-Path $ProjectRoot "AzViz.psd1")).ModuleVersion
        if ($ModuleVersion) {

            $ASCIIArt = Get-ASCIIArt  
            $ASCIIArt += "`n   Module  : Azure Visualizer v$ModuleVersion"                       
            $ASCIIArt += "`n   Project : https://github.com/PrateekKumarSingh/AzViz`n"                       
            Write-Verbose $ASCIIArt
            Write-Verbose ""
            
        }

        Write-Verbose "Testing Graphviz installation..."
        # test graphviz installation
        $PossibleGraphVizPaths = 'C:\Program Files\NuGet\Packages\Graphviz*\dot.exe', 'C:\program files*\GraphViz*\bin\dot.exe', '/usr/local/bin/dot', '/usr/bin/dot'
        $GraphViz = Resolve-Path -path $PossibleGraphVizPaths -ErrorAction SilentlyContinue | Get-Item | Where-Object BaseName -eq 'dot' | Select-Object -First 1

        if ( $null -eq $GraphViz ) {
            Write-Error "'GraphViz' is not installed on this system and is a prerequisites for this module to work. Please download and install from here: https://graphviz.org/download/ and re-run this command." -ErrorAction Stop
        }
        else {
            Write-Verbose " [+] GraphViz installation path : $GraphViz"
        }

        switch ($Theme) {
            'light' { 
                $GraphColor = 'White'
                $SubGraphColor = 'Black'
                $GraphFontColor = 'Black'
                $EdgeColor = 'Black'
                $EdgeFontColor = 'Black'
                $NodeColor = 'Black'
                $NodeFontColor = 'Black'
                break
            }
            'dark' { 
                $GraphColor = 'Black'
                $SubGraphColor = 'White'
                $GraphFontColor = 'White'
                $EdgeColor = 'White'
                $EdgeFontColor = 'White'
                $NodeColor = 'White'
                $NodeFontColor = 'White'
                break
            }
            'neon' {
                $GraphColor = 'Black'
                $SubGraphColor = 'YellowGreen'
                $GraphFontColor = 'YellowGreen'
                $EdgeColor = 'YellowGreen'
                $EdgeFontColor = 'YellowGreen'
                $NodeColor = 'YellowGreen'
                $NodeFontColor = 'YellowGreen'
                break
            }
        }

        if ($PSBoundParameters.ContainsKey('ResourceGroup')) {
            $TargetType = 'Azure Resource Group'
        }
        elseif ($PSBoundParameters.ContainsKey('Path')) {
            $TargetType = 'File'
        }
        elseif ($PSBoundParameters.ContainsKey('URL')) {
            $TargetType = 'URL'
        }
    
        switch ($Direction) {
            'left-to-right' { $rankdir = "LR" }
            'top-to-bottom' { $rankdir = "TB" }
        }

        $rank = @{
            "Microsoft.Network/publicIPAddresses"     = 1
            "Microsoft.Network/loadBalancers"         = 2
            "Microsoft.Network/virtualNetworks"       = 3 
            "Microsoft.Network/networkSecurityGroups" = 4
            "Microsoft.Network/networkInterfaces"     = 5
            "Microsoft.Compute/virtualMachines"       = 6
        }

        Write-Verbose "Configuring Defaults..."
        Write-Verbose " [+] Target Type          : $TargetType"
        Write-Verbose " [+] Output Format        : $OutputFormat"
        Write-Verbose " [+] Output File Path     : $OutputFilePath"
        Write-Verbose " [+] Label Verbosity      : $LabelVerbosity"
        Write-Verbose " [+] Category Depth       : $CategoryDepth"
        Write-Verbose " [+] Sub-graph Direction  : $Direction"
        Write-Verbose " [+] Theme                : $Theme"
        Write-Verbose " [+] Launch Visualization : $Show"
        #endregion defaults

        switch ($TargetType) {
            'Azure Resource Group' { $targets = $ResourceGroup }
            'File' { $targets = $path }
            'Url' { $targets = $url }
        }
          
        Write-Verbose "Target ${TargetType}s: "
        $targets.ForEach( { Write-Verbose "   > '$_'" } )

        #region graph-generation
        Write-Verbose "Starting to generate Azure visualization..."
    
        $Counter = 0
        $subgraphs = foreach ($target in $targets) {

            $temp_armtemplate = (Join-Path ([System.IO.Path]::GetTempPath()) "armtemplate.json")
                
            #region obtaining-arm-template
            switch ($TargetType) {
                'Azure Resource Group' { 
                    if (!(Test-AzLogin)) {
                        break
                    }
                    Write-Verbose " [+] Exporting ARM template of Azure Resource group: `"$target`""
                    $template = (Export-AzResourceGroup -ResourceGroupName $target -SkipAllParameterization -Force -Path $temp_armtemplate).Path
                }
                'File' { 
                    Write-Verbose " [+] Accessing ARM template from local file: `"$target`""
                    $template = $target
                }
                'Url' {
                    Write-Verbose " [+] Downloading ARM template from URL: `"$target`""
                    # $target = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-linux/azuredeploy.json'
                    $template = $temp_armtemplate
                    Invoke-WebRequest -Uri  $target -OutFile $template  -Verbose:$false
                    # todo test-path the downloaded file
                }
            }

            Write-Verbose " [+] Processing the ARM template to extract resources"
            # $arm = ConvertFrom-ArmTemplate -Path $template
            $arm = Get-Content -Path $template | ConvertFrom-Json
            $resources = $arm.Resources

            if ($resources) {
                Write-Verbose " [+] Total resources found: $($resources.count)"
                Write-Verbose " [+] Cleaning up temporary ARM template file at: $template"
                Remove-Item $template -Force
            }
            else {
                Write-Verbose " [+] Total resources/sub-resources found: $($resources.count)"
                Write-Verbose " [-] Skipping ${TargetType}: `"$target`" as no resources were found."
                break        
            }
            #endregion obtaining-arm-template
                
            Write-Verbose " [+] Plotting sub-graph for ${TargetType}: `"$target`""

                     
            #region parsing-arm-template-and-finding-resource-dependencies
            $data = @()
            $Counter = $Counter + 1
            # $excluded_types = @("scheduledqueryrules","containers","solutions","modules","savedSearches")
                    
            $data += $resources |
            Where-Object { $_.type.tostring().split("/").count -le $($CategoryDepth + 1) } |
            ForEach-Object {
                $dependson = $null
                if ($_.dependson) {
                    $dependson = $_.DependsOn #| ForEach-Object { $_.ToString().split("parameters('")[1].split("')")[0]}
                    foreach ($dependency in $dependson) {                            
                        $r = $rank["$($_.type.ToString())"]
                        [PSCustomObject]@{
                            fromcateg   = $_.type.ToString() #.split('/')[-1]
                            from        = $_.name.ToString() #.split('/')[-1] #.split("parameters('")[1].split("')")[0]
                            to          = $dependency.tostring().replace("[resourceId(", "").replace(")]", "").Split(",")[1].replace("'", "").trim() # -join '/' #.split('/')[-1]
                            tocateg     = $dependency.tostring().replace("[resourceId(", "").replace(")]", "").Split(",")[0].replace("'", "").trim().Split("/")[0..1] -join '/' #.split('/')[-1]
                            isdependent = $true
                            rank        = if ($r) { $r }else { 9999 }
                        }
                    }
                }
                else {
                    $r = $rank["$($_.type.ToString())"]
                    [PSCustomObject]@{
                        fromcateg   = $_.type.ToString() #.split('/')[-1]
                        from        = $_.name.ToString() #.split("parameters('")[1].split("')")[0]
                        to          = ''
                        tocateg     = ''
                        isdependent = $false
                        rank        = if ($r) { $r }else { 9999 }
                    }
                }
            } | 
            Sort-Object Rank
            #endregion parsing-arm-template-and-finding-resource-associations

            #region plotting-edges-to-nodes

            $nodes_and_edges = $data | 
            # Where-Object to | 
            Tee-Object -Variable pipe_var |
            ForEach-Object {
                $from = $_.from
                $fromcateg = $_.fromcateg
                $to = $_.to
                $tocateg = $_.tocateg
                if ($_.isdependent) {
                    Edge -From "$fromcateg$from".ToUpper() `
                        -to "$tocateg$to".ToUpper() `
                        -Attributes @{
                        arrowhead = 'normal';
                        style     = 'dotted';
                        label     = 'dependsOn'
                        penwidth  = "1"
                        fontname  = "Courier New"
                    }

                    Write-Verbose "   > Creating Edge: $from -> $to"

                    if ($LabelVerbosity -eq 1) {
                        Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   
                        Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows $to -Type $tocateg
    
                        Write-Verbose "   > Creating Node: $from"
                        Write-Verbose "   > Creating Node: $to"
                    }
                    elseif ($LabelVerbosity -eq 2) {
                        Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                        Get-ImageNode -Name "$tocateg$to".ToUpper() -Rows ($to, $toCateg) -Type $tocateg   

                        Write-Verbose "   > Creating Node: $from"
                        Write-Verbose "   > Creating Node: $to"
                    }
                }
                else {
                    if ($LabelVerbosity -eq 1) {
                        Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows $from -Type $fromcateg   

                        Write-Verbose "   > Creating Node: $from"
                    }
                    elseif ($LabelVerbosity -eq 2) {
                        Get-ImageNode -Name "$fromcateg$from".ToUpper() -Rows ($from, $fromcateg) -Type $fromcateg
                        Write-Verbose "   > Creating Node: $to"
                    }
                }
            }
                    
                
            # Write-Verbose " [+] Total resources filtered: $($pipe_var.count)"
            if (!$nodes_and_edges) {
                Write-Warning " [-] No resources found.. re-run the command and try increasing the category depth using -CategoryDepth 2 or -CategoryDepth 3 cmdlet parameters." -Verbose
            }
            else {
                $SubGraphName = "Resource Group: $target"
                SubGraph "$($TargetType.Replace(' ',''))$Counter" @{label = $SubGraphName; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor; style = 'rounded' } {
                    $nodes_and_edges
                }
            }
            #endregion plotting-edges-to-nodes

            #region ranking-nodes

            # foreach($item in $data | Group-Object rank){
            #     $nodes = foreach($group in $item.Group){
            #         $from = $group.from
            #         $fromcateg = $group.fromcateg
            #         $to = $group.to
            #         $tocateg = $group.tocateg
            #         "`"$fromcateg$from`"".ToUpper()
            #     }
            #     "{rank = `"same`"; $($nodes -join '; ')}"
            # }

            #endregion ranking-nodes

            #endregion plotting-all-remaining-nodes

        }

        if ($subgraphs) {
            $Subscription = (Get-AzContext).Subscription
            $GraphName = "Subscription: {0} ({1})" -f $Subscription.name, $Subscription.Id
            $graph = Graph 'Visualization' @{label = $GraphName; rankdir = $rankdir; overlap = 'false'; splines = 'true' ; color = $GraphColor; bgcolor = $GraphColor; penwidth = "1"; fontname = "Courier New" ; fontcolor = $GraphFontColor } {
            
                edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
                node @{color = $NodeColor ; fontcolor = $NodeFontColor }
                
                $subgraphs
            }
        }

        if ($graph) {
            @"
strict $graph
"@ | Export-PSGraph -ShowGraph:$Show -OutputFormat $OutputFormat -DestinationPath $OutputFilePath -OutVariable output |
            Out-Null
            Write-Verbose "Visualization exported to path: $($output.fullname)"

            if(!$PSBoundParameters.ContainsKey('Verbose')){
                Write-Host "`nVisualization exported to path: $($output.fullname)`n"
            }
            Write-Verbose "Finished Azure visualization."
        }
        #endregion graph-generation
    }
    catch {
        $_
    }
}

Export-ModuleMember Export-AzViz