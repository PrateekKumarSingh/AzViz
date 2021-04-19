function ConvertFrom-Network {
    [CmdletBinding()]
    param (
        [string[]] $Targets,
        [ValidateSet('Azure Resource Group')]
        [string] $TargetType = 'Azure Resource Group',
        [int] $CategoryDepth = 1
    )
    
    begin {
        $rank = @{
            "Microsoft.Network/publicIPAddresses"     = 1
            "Microsoft.Network/loadBalancers"         = 2
            "Microsoft.Network/virtualNetworks"       = 3 
            "Microsoft.Network/networkSecurityGroups" = 4
            "Microsoft.Network/networkInterfaces"     = 5
            "Microsoft.Compute/virtualMachines"       = 6
        }

        # $Excluded_NetworkObjects = $("Microsoft.Network/virtualNetworks/subnets", "Microsoft.Network/virtualNetworks")
        $Excluded_NetworkObjects = $(
            "*Microsoft.Network/virtualNetworks*",
            "*Microsoft.Network/virtualNetworks/subnets*",
            "*Microsoft.Network/networkSecurityGroups*"
        )
        
        $scriptblock = [scriptblock]::Create($Excluded_NetworkObjects.ForEach({'$_.fromcateg -NotLike "{0}" -and $_.tocateg -NotLike "{0}"' -f $_}) -join ' -and ')
    }
    
    process {
        foreach ($Target in $Targets) {
                

            switch ($TargetType) {
                'Azure Resource Group' { 
                    $ResourceGroup = $Target
                    Write-Verbose " [+] Exporting Network Associations from Network watcher for Resource Group: `"$Target`""
                    $location = Get-AzResourceGroup -Name $ResourceGroup | ForEach-Object location
                    $networkWatcher = Get-AzNetworkWatcher -Location $location -ErrorAction SilentlyContinue
                }
                'File' { 

                }
                'Url' {

                }
            }

            if ($networkWatcher) {
                Write-Verbose " [+] Network watcher found: `"$($networkWatcher.Name)`""

                #region obtaining-network-associations           
                Write-Verbose " [+] Fetching network topology of resource group: `"$ResourceGroup`""
                $Topology = Get-AzNetworkWatcherTopology -NetworkWatcher $networkWatcher -TargetResourceGroupName $ResourceGroup -Verbose  
                
                $resources = $Topology.Resources #| Where-Object $scriptblock
                #endregion obtaining-network-associations
    
                #region parsing-network-topology-and-finding-associations
                $data = @()
                $data += $Resources | 
                Select-Object @{n = 'from'; e = { $_.name } }, @{n = 'fromcateg'; e = { (Get-AzResource -ResourceId $_.id -ea SilentlyContinue).ResourceType } }, Associations, @{n = 'to'; e = { ($_.AssociationText | ConvertFrom-Json) | Select-Object name, AssociationType, resourceID } } |
                Where-Object { $_.fromcateg.split("/").count -le $($CategoryDepth + 1) } |
                ForEach-Object {
                    if ($_.to) {
                        Foreach ($to in $_.to) {
                            $fromcateg = $_.FromCateg
                            $r = $rank[$fromcateg]
                            [PSCustomObject]@{
                                fromcateg   = $fromCateg
                                from        = $_.from
                                to          = $to.name
                                toCateg     = (Get-AzResource -ResourceId $to.ResourceId).ResourceType
                                association = $to.associationType
                                rank        = if ($r) { $r }else { 9999 }
                            }
                        }
                    }
                    else {
                        $fromcateg = $_.FromCateg
                        [PSCustomObject]@{
                            fromcateg   = $fromCateg
                            from        = $_.from
                            to          = ''
                            toCateg     = ''
                            association = ''
                            rank        = if ($r) { $r }else { 9999 }
                        }
                    }
                } | 
                Sort-Object Rank
                
                [PSCustomObject]@{
                    Type      = $TargetType
                    Name      = $Target
                    Resources = $data | Where-Object $scriptblock
                }
            }
            else {
                Write-Verbose " [+] Network watcher not found for Resource group: `"$ResourceGroup`""
            }
 
            #endregion parsing-network-topology-and-finding-associations

        }
    }
    
    end {
        
    }
}