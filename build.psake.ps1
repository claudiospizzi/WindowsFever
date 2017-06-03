
. $PSScriptRoot\build.settings.ps1

# Default tasks
Task Default -depends Build, Test, Analyze

# Create release and test folders
Task Init -requiredVariables ReleasePath, TestPath, AnalyzePath {

    if (!(Test-Path -Path $ReleasePath))
    {
        New-Item -Path $ReleasePath -ItemType Directory -Verbose:$VerbosePreference > $null
    }

    if (!(Test-Path -Path $TestPath))
    {
        New-Item -Path $TestPath -ItemType Directory -Verbose:$VerbosePreference > $null
    }

    if (!(Test-Path -Path $AnalyzePath))
    {
        New-Item -Path $AnalyzePath -ItemType Directory -Verbose:$VerbosePreference > $null
    }
}

# Remove any items in the release and test folders
Task Clean -depends Init -requiredVariables ReleasePath, TestPath, AnalyzePath {

    Get-ChildItem -Path $ReleasePath | Remove-Item -Recurse -Force -Verbose:$VerbosePreference

    Get-ChildItem -Path $TestPath | Remove-Item -Recurse -Force -Verbose:$VerbosePreference

    Get-ChildItem -Path $AnalyzePath | Remove-Item -Recurse -Force -Verbose:$VerbosePreference
}

# Copy all required module files to the release folder
Task Stage -depends Clean -requiredVariables ReleasePath, ModulePath, ModuleNames {

    foreach ($moduleName in $ModuleNames)
    {
        foreach ($item in (Get-ChildItem -Path "$ModulePath\$moduleName" -Exclude 'Functions', 'Helpers'))
        {
            Copy-Item -Path $item.FullName -Destination "$ReleasePath\$moduleName\$($item.Name)" -Recurse -Verbose:$VerbosePreference
        }
    }
}

# Build the module by copying all helper and cmdlet functions to the psm1 file
Task Build -depends Stage -requiredVariables ReleasePath, ModulePath, ModuleNames {

    foreach ($moduleName in $ModuleNames)
    {
        $moduleContent = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

        # Load code for all function files
        foreach ($function in (Get-ChildItem -Path "$ModulePath\$moduleName\Functions" -Filter '*.ps1' -File -ErrorAction 'SilentlyContinue'))
        {
            $moduleContent.Add((Get-Content -Path $function.FullName -Raw))
        }

        # Load code for all helpers files
        foreach ($function in (Get-ChildItem -Path "$ModulePath\$moduleName\Helpers" -Filter '*.ps1' -File -ErrorAction 'SilentlyContinue'))
        {
            $moduleContent.Add((Get-Content -Path $function.FullName -Raw))
        }

        # Load code of the module file itself
        $moduleContent.Add((Get-Content -Path "$ModulePath\$moduleName\$moduleName.psm1" | Select-Object -Skip 15) -join "`r`n")

        # Concatenate whole code into the module file
        $moduleContent | Set-Content -Path "$ReleasePath\$moduleName\$moduleName.psm1" -Encoding UTF8 -Verbose:$VerbosePreference

        # Compress
        Compress-Archive -Path "$ReleasePath\$moduleName" -DestinationPath "$ReleasePath\$moduleName.zip" -Verbose:$VerbosePreference

        # Publish AppVeyor artifacts
        if ($env:APPVEYOR)
        {
            Push-AppveyorArtifact -Path "$ReleasePath\$moduleName.zip" -DeploymentName $moduleName -Verbose:$VerbosePreference
        }
    }
}

# Invoke Pester tests and return result as NUnit XML file
Task Test -depends Build -requiredVariables ReleasePath, ModuleNames, TestPath, TestFile {

    if (!(Get-Module -Name 'Pester' -ListAvailable))
    {
        Write-Warning "Pester module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    Import-Module -Name 'Pester'

    foreach ($moduleName in $ModuleNames)
    {
        $moduleTestFile = Join-Path -Path $TestPath -ChildPath "$moduleName-$TestFile"

        try
        {
            Push-Location -Path "$ReleasePath\$moduleName"

            $invokePesterParams = @{
                OutputFile   = $moduleTestFile
                OutputFormat = 'NUnitXml'
                PassThru     = $true
                Verbose      = $VerbosePreference
                #CodeCoverage = $CodeCoverageFiles
            }
            $testResults = Invoke-Pester @invokePesterParams

            Assert -conditionToCheck ($testResults.FailedCount -eq 0) -failureMessage "One or more Pester tests failed, build cannot continue."
        }
        finally
        {
            Pop-Location

            Remove-Module -Name $moduleName -ErrorAction SilentlyContinue

            # Publish AppVeyor test results
            if ($env:APPVEYOR)
            {
                $webClient = New-Object -TypeName 'System.Net.WebClient'
                $webClient.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$env:APPVEYOR_JOB_ID", $moduleTestFile)
            }
        }
    }
}

# Invoke Script Analyzer
Task Analyze -depends Build -requiredVariables ReleasePath, ModuleNames, AnalyzePath, AnalyzeFile, AnalyzeRules {

    if (!(Get-Module -Name 'PSScriptAnalyzer' -ListAvailable))
    {
        Write-Warning "PSScriptAnalyzer module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    Import-Module -Name 'PSScriptAnalyzer'

    foreach ($moduleName in $ModuleNames)
    {
        $moduleAnalyzeFile = Join-Path -Path $AnalyzePath -ChildPath "$moduleName-$AnalyzeFile"

        $analyzeResults = Invoke-ScriptAnalyzer -Path .\Modules\WindowsFever -IncludeRule $AnalyzeRules -Recurse
        $analyzeResults | ConvertTo-Json | Out-File -FilePath $moduleAnalyzeFile -Encoding UTF8

        Show-ScriptAnalyzerResult -ModuleName $moduleName -Rule $AnalyzeRules -Result $analyzeResults

        Assert -conditionToCheck ($analyzeResults.Count -eq 0) -failureMessage "One or more Script Analyzer tests failed, build cannot continue."
    }
}

# Helper Function: Show Script Analyzer Result
function Show-ScriptAnalyzerResult($ModuleName, $Rule, $Result)
{
    $colorMap = @{
        Error       = 'Red'
        Warning     = 'Yellow'
        Information = 'Blue'
    }

    Write-Host "Module $ModuleName" -ForegroundColor Magenta

    foreach ($currentRule in $Rule)
    {
        Write-Host "   Rule $($currentRule.RuleName)" -ForegroundColor Magenta

        foreach ($record in $Result.Where({$_.RuleName -eq $currentRule.RuleName}))
        {
            Write-Host "    [-] $($record.Severity): $($record.Message)" -ForegroundColor $colorMap[[String]$record.Severity]
            Write-Host "      at $($record.ScriptPath): line $($record.Line)" -ForegroundColor $colorMap[[String]$record.Severity]

        }
    }

    Write-Host "Script Analyzer completed"
    Write-Host "Rules: $($Rule.Count) Failed: $($analyzeResults.Count)"
}
