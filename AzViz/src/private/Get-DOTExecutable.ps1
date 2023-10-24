function Get-DOTExecutable {
    
    $PossibleGraphVizPaths = @(
        'C:\Program Files\NuGet\Packages\Graphviz*\dot.exe',
        'C:\program files*\GraphViz*\bin\dot.exe',
        '/usr/local/bin/dot',
        '/usr/bin/dot',
        '/opt/homebrew/bin/dot'
    )
    $PossibleGraphVizPaths += (Get-Command -Type Application -Name dot).Source

    $GraphViz = Resolve-Path -path $PossibleGraphVizPaths -ErrorAction SilentlyContinue | Get-Item | Where-Object BaseName -eq 'dot' | Select-Object -First 1

    return $GraphViz
}

