Function Get-ImageNode {
    param(
        [string[]]$Rows,
        [string]$Type,
        [String]$Name,
        [String]$Label,
        [String]$Style = 'Filled',
        [String]$Shape = 'none',
        [String]$FillColor = 'White'
    )

    $Shapes = @{
        loadBalancers                            = 'diamond'
        publicIPAddresses                        = 'octagon'
        networkInterfaces                        = 'component'
        virtualMachines                          = 'box3d'
        'loadBalancers/backendAddressPools'      = 'rect'
        'loadBalancers/frontendIPConfigurations' = 'rect'
        'virtualNetworks'                        = 'oval'
        'networkSecurityGroups'                  = 'oval'
    }
    
    $Styles = @{
        loadBalancers                            = 'filled'
        publicIPAddresses                        = 'filled'
        networkInterfaces                        = 'filled'
        virtualMachines                          = 'filled'
        'loadBalancers/backendAddressPools'      = 'filled'
        'loadBalancers/frontendIPConfigurations' = 'filled'
        'virtualNetworks'                        = 'dotted'
        'networkSecurityGroups'                  = 'filled'
    }
    
    $Colors = @{
        loadBalancers                            = 'greenyellow'
        publicIPAddresses                        = 'gold'
        networkInterfaces                        = 'skyblue'
        'loadBalancers/frontendIPConfigurations' = 'lightsalmon'
        virtualMachines                          = 'darkolivegreen3'
        'loadBalancers/backendAddressPools'      = 'crimson'
        'virtualNetworks'                        = 'navy'
        'networkSecurityGroups'                  = 'azure'
    }

    $TR = ''
    $Rows | ForEach-Object {
        $TR += '<TR><TD align="center"><B>{0}</B></TD></TR>' -f $PSItem
    }

    $Path = $images[$Type]
    if ($Path) {
        '"{0}" [label=<<TABLE border="0" cellborder="0" cellpadding="0"><TR><TD ALIGN="center" ><img src="{1}"/></TD></TR>{2}</TABLE>>;fillcolor="white";shape="none";penwidth="1";fontname="Courier New";]' -f $Name, $images[$Type], $TR
    }
    else {
        node $Name -Attributes @{
            Label     = $Rows; 
            shape     = $Shapes[$Type];
            style     = $styles[$Type] ; 
            fillcolor = $Colors[$Type]
        }
    }

}


# Get-ImageNode -Name 'test' -Rows 'testnode','192.168.1.1' -Type LoadBalancers
