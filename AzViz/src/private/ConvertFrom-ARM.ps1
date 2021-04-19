function ConvertFrom-ARM {
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

        $Excluded_ARMObjects = $(
            "Microsoft.Network/virtualNetworks*",
            "Microsoft.Network/virtualNetworks/subnets*",
            "Microsoft.Network/networkSecurityGroups*"
        )

        # $scriptblock = [scriptblock]::Create($Excluded_ARMObjects.ForEach({'$_.type -NotLike "{0}"' -f $_}) -join ' -and ')
        $scriptblock = [scriptblock]::Create($Excluded_ARMObjects.ForEach({'$_.fromcateg -NotLike "{0}" -and $_.tocateg -NotLike "{0}"' -f $_}) -join ' -and ')
        
    }
    
    process {
        foreach ($Target in $Targets) {

            $temp_armtemplate = (Join-Path ([System.IO.Path]::GetTempPath()) "armtemplate.json")
                
            #region obtaining-arm-template
            switch ($TargetType) {
                'Azure Resource Group' { 
                    Write-Verbose " [+] Exporting ARM template of Azure Resource group: `"$Target`""
                    $template = (Export-AzResourceGroup -ResourceGroupName $Target -SkipAllParameterization -Force -Path $temp_armtemplate).Path
                }
                'File' { 
                    Write-Verbose " [+] Accessing ARM template from local file: `"$Target`""
                    $template = $Target
                }
                'Url' {
                    Write-Verbose " [+] Downloading ARM template from URL: `"$Target`""
                    # $Target = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-linux/azuredeploy.json'
                    $template = $temp_armtemplate
                    Invoke-WebRequest -Uri  $Target -OutFile $template  -Verbose:$false
                    # todo test-path the downloaded file
                }
            }

            Write-Verbose " [+] Processing the ARM template to extract resources"

            $arm = Get-Content -Path $template | ConvertFrom-Json
            $resources = $arm.Resources | Where-Object $scriptblock

            if ($resources) {
                Write-Verbose " [+] Total resources found: $($resources.count)"
                Write-Verbose " [+] Cleaning up temporary ARM template file at: $template"
                Remove-Item $template -Force
            }
            else {
                Write-Verbose " [+] Total resources/sub-resources found: $($resources.count)"
                Write-Verbose " [-] Skipping ${TargetType}: `"$Target`" as no resources were found."
                break        
            }
            #endregion obtaining-arm-template

            #region parsing-arm-template-and-finding-resource-dependencies
            $data = @()
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

            [PSCustomObject]@{
                Type      = $TargetType
                Name      = $Target
                Resources = $data | Where-Object $scriptblock
            }
        }
    }
    
    end {
        
    }
}