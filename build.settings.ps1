
Properties {

    $ModulePath  = Join-Path -Path $PSScriptRoot -ChildPath 'Modules'
    $ModuleNames = Get-ChildItem -Path $ModulePath | Select-Object -ExpandProperty 'BaseName' -First 1

    $ReleasePath = Join-Path -Path $PSScriptRoot -ChildPath 'Releases'

    $TestPath = Join-Path -Path $PSScriptRoot -ChildPath 'Tests'
    $TestFile = 'pester.xml'

    $AnalyzePath  = Join-Path -Path $PSScriptRoot -ChildPath 'Tests'
    $AnalyzeFile  = 'scriptanalyzer.json'
    $AnalyzeRules = Get-ScriptAnalyzerRule
}
