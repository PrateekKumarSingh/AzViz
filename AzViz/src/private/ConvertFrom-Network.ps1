function ConvertFrom-Network {
    [CmdletBinding()]
    param (
        [string[]] $Targets,
        [ValidateSet('Azure Resource Group')]
        [string] $TargetType = 'Azure Resource Group',
        [int] $CategoryDepth = 1,
        [string[]] $ExcludeTypes
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
                
        if($ExcludeTypes){
            $Excluded_NetworkObjects += $ExcludeTypes
        }
        
        $scriptblock = [scriptblock]::Create( $Excluded_NetworkObjects.ForEach( { '$_.fromcateg -NotLike "{0}" -and $_.tocateg -NotLike "{0}"' -f $_ }) -join ' -and ' )
    }
    
    process {

        # $Targets | ForEach-Object -ThrottleLimit 10 -Parallel {
        #     Import-Module Az.Resources, Az.Network
        #     $TargetType = $using:TargetType
        #     $CategoryDepth = $using:CategoryDepth
        #     $Target = $_
        #     $Rank = $using:Rank
        #     $scriptblock = [scriptblock]::Create($using:condition)

        Foreach ($Target in $Targets) {

            switch ($TargetType) {
                'Azure Resource Group' { 
                    $ResourceGroup = $Target
                    Write-CustomHost "Exporting network associations for resource group: `'$Target`'" -Indentation 1 -color Green
                    $location = Get-AzResourceGroup -Name $ResourceGroup -Verbose:$false | ForEach-Object location
                    $networkWatcher = Get-AzNetworkWatcher -Location $location -ErrorAction SilentlyContinue -Verbose:$false
                }
                'File' { 
                    #todo
                }
                'Url' {
                    #todo
                }
            }

            if ($networkWatcher) {
                Write-CustomHost "Network watcher found: `'$($networkWatcher.Name)`'" -Indentation 2 -color Green

                #region obtaining-network-associations           
                Write-CustomHost "Obtaining network topology using Network Watcher" -Indentation 2 -color Green
                $Topology = Get-AzNetworkWatcherTopology -NetworkWatcher $networkWatcher -TargetResourceGroupName $ResourceGroup -Verbose:$false 
                
                $resources = $Topology.Resources #| Where-Object $scriptblock
                #endregion obtaining-network-associations
    
                #region parsing-network-topology-and-finding-associations
                $SkipMsgFlag = $true
                $data = @()
                $data += $Resources | 
                Select-Object @{n = 'from'; e = { $_.name } },
                              @{n = 'fromcateg'; e = { (Get-AzResource -ResourceId $_.id -ea SilentlyContinue -Verbose:$false).ResourceType } },
                              Associations,
                              @{n = 'to'; e = { ($_.AssociationText | ConvertFrom-Json) | Select-Object name, AssociationType, resourceID } } |
                Select-Object *, @{n='CategDepth';e={$depth=0;try{$depth=$_.fromcateg.split("/").count}catch{};$depth}} | #todo just a hack will write better code later :)
                Where-Object { $_.fromcateg -and ($_.CategDepth -le $($CategoryDepth + 1)) } -ea silentlycontinue |
                ForEach-Object {
                    if ($_.to) {
                        Foreach ($to in $_.to) {
                            # todo: only allow network connections within the resource group to be included
                            # as the module evolves, need to figure out a way to visualize network connections outside resource group
                            if($to.ResourceID -like "*$ResourceGroup*"){
                                $fromcateg = $_.FromCateg
                                $r = $rank[$fromcateg]
                                [PSCustomObject]@{
                                    fromcateg   = $fromCateg
                                    from        = $_.from
                                    to          = $to.name
                                    toCateg     = (Get-AzResource -ResourceId $to.ResourceId -ErrorAction SilentlyContinue).ResourceType
                                    association = $to.associationType
                                    rank        = if ($r) { $r }else { 9999 }
                                }
                            }
                            else{
                                if($SkipMsgFlag){
                                    Write-CustomHost "Skipping network resources outside the resource group '$ResourceGroup'" -Indentation 3 -color Yellow
                                    $skipMsgFlag = $false
                                }
                                Write-CustomHost "$($to.ResourceID)" -Indentation 4 -color Yellow
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
                Write-CustomHost "Network watcher not found for resource group: `'$ResourceGroup`'" -Indentation 2 -Color Yellow
            }
 
            #endregion parsing-network-topology-and-finding-associations

        }
    }
    
    end {
        
    }
}