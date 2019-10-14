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
            Label     = $Label; 
            shape     = $Shape;
            style     = $style ; 
            fillcolor = $FillColor
        }
    }

}


# Get-ImageNode -Name 'test' -Rows 'testnode','192.168.1.1' -Type LoadBalancers
