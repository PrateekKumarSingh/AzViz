<#
Class EvaluateARMExpression {
    [String] $expression

    EvaluateARMExpression($expression) {
        
        if ($expression -match "\w+\([a-zA-Z0-9_(\/)', -.]+") { 
            $this.expression = $Matches[0]
        }
        else {

        }
    }

}

[EvaluateARMExpression] "[concat(variables('accountName'), '/', parameters('databaseName'), '/', parameters('graphName'))]"



$template = Get-Content D:\Workspace\Repository\AzViz\networkwatcherrg.json | ConvertFrom-Json
$params = $template.parameters.psobject.Properties.foreach({
    [PSCustomObject]@{
        name = $_.name
        type = $_.Value.type
        default = $_.Value.defaultValue
    }
    
})

$vars = $template.variables.psobject.Properties.foreach({
    [PSCustomObject]@{
        name = $_.name
        type = $_.Value.type
        default = $_.Value.defaultValue
    }
    
})

function eval($string){
    $arg = if($string -match "'\w+'"){$Matches.Values -replace "'",""}

    if($arg){
        $params.where({$_.name -eq $arg}).name
    }
}

#>