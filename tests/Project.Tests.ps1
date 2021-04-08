$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = "$projectRoot\"
# $moduleName = Split-Path $moduleRoot -Leaf

Describe "PSScriptAnalyzer rule-sets" -Tag Build {
    $Rules = Get-ScriptAnalyzerRule -Severity Error
    $ExcludedRules = 'PSAvoidUsingEmptyCatchBlock', 'PSUseShouldProcessForStateChangingFunctions', 'PSAvoidUsingWriteHost', 'PSProvideCommentHelp', 'PSAvoidTrailingWhitespace'
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse | Where-Object fullname -notmatch 'classes'

    foreach ( $Script in $scripts ) {
        $results = Invoke-ScriptAnalyzer -Path $script.FullName -includeRule $Rules -ExcludeRule $ExcludedRules
        if ($results) {
            foreach ($rule in $results) {
                It $rule.RuleName {
                    $message = "{0} Line {1}: {2}" -f $rule.Severity, $rule.Line, $rule.message
                    $message | Should Be ""
                }
            }
        }
        else {
            It "Script '$($script.Name)' should not fail any rules" {
                $results | Should BeNullOrEmpty
            }
        }
    }
}
