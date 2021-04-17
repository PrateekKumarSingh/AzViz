function ConvertTo-DOTLanguage {
    [CmdletBinding()]
    param (
        [string[]] $Targets,
        [ValidateSet('Azure Resource Group')]
        [string] $TargetType = 'Azure Resource Group',
        [int] $LabelVerbosity = 1,
        [int] $CategoryDepth = 1,
        [string] $Direction = 'top-to-bottom'
    )
    
    begin {
        switch ($Direction) {
            'left-to-right' { $rankdir = "LR" }
            'top-to-bottom' { $rankdir = "TB" }
        }
    }
    
    process {
        $ARMObjects = ConvertFrom-ARM -TargetType $TargetType -Targets $Targets -CategoryDepth $CategoryDepth
        $NetworkObjects = ConvertFrom-Network -TargetType $TargetType -Targets $Targets -CategoryDepth $CategoryDepth

        $GraphObjects = ($ARMObjects + $NetworkObjects) | 
                        Group-Object Name | 
                        ForEach-Object {
                            [PSCustomObject]@{
                                Name = $_.Name
                                Type = $_.group.type[0]
                                Resources = $_.group.Resources
                            }
                        }
        
        $Counter = 0
        $subgraphs = foreach ($Target in $GraphObjects) {
            $Counter = $Counter + 1              
            Write-Verbose " [+] Plotting sub-graph for $($Target.Type): `"$($Target.Name)`""  

            #region plotting-edges-to-nodes

            $nodes_and_edges = $Target.Resources | 
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
                $SubGraphName = "Resource Group: $($Target.Name)"
                SubGraph "$($($Target.Type).Replace(' ',''))$Counter" @{label = $SubGraphName; labelloc = 'b'; penwidth = "1"; fontname = "Courier New" ; color = $SubGraphColor; style = 'rounded' } {
                    $nodes_and_edges
                }
            }
            #endregion plotting-edges-to-nodes

        }

        if ($subgraphs) {
            $Subscription = (Get-AzContext).Subscription
            $GraphName = "Subscription: {0} ({1})" -f $Subscription.name, $Subscription.Id
            $graph = Graph 'Visualization' @{label = $GraphName; rankdir = $rankdir; overlap = 'false'; splines = 'true' ; color = $GraphColor; bgcolor = $GraphColor; penwidth = "1"; fontname = "Courier New" ; fontcolor = $GraphFontColor } {
            
                edge @{color = $EdgeColor; fontcolor = $EdgeFontColor }
                node @{color = $NodeColor ; fontcolor = $NodeFontColor }
                
                $subgraphs
            }

            # to indent and validate the dot language generated by powershell
            $GraphViz = Get-DOTExecutable

            if ( $null -eq $GraphViz ) {
                Write-Error "'GraphViz' is not installed on this system and is a prerequisites for this module to work. Please download and install from here: https://graphviz.org/download/ and re-run this command." -ErrorAction Stop
            }
            else {
                $dot_file = (Join-Path ([System.IO.Path]::GetTempPath()) "temp.dot")
                $graph | Out-String | Out-File $dot_file -Verbose
                if(Test-Path $dot_file){
                    if($IsLinux){
                        Invoke-Expression "$($GraphViz.FullName) $dot_file"
                    }
                    else{
                        & $GraphViz.FullName $dot_file
                    }

                    Remove-Item $dot_file -Force
                }
                else{
                    $graph | Out-String
                }
            }

        }
    }
    
    end {
        
    }
}