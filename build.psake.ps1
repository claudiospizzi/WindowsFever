
. $PSScriptRoot\build.settings.ps1

# Create release and test folders
Task Init -requiredVariables ReleasePath, TestPath {

    if (!(Test-Path -Path $ReleasePath))
    {
        New-Item -Path $ReleasePath -ItemType Directory -Verbose:$VerbosePreference > $null
    }

    if (!(Test-Path -Path $TestPath))
    {
        New-Item -Path $TestPath -ItemType Directory -Verbose:$VerbosePreference > $null
    }
}

# Remove any items in the release and test folders
Task Clean -depends Init -requiredVariables ReleasePath, TestPath {

    Get-ChildItem -Path $ReleasePath | Remove-Item -Recurse -Force -Verbose:$VerbosePreference

    Get-ChildItem -Path $TestPath | Remove-Item -Recurse -Force -Verbose:$VerbosePreference
}

# Copy all required module files to the release folder
Task Stage -depends Init, Clean -requiredVariables ReleasePath, ModulePath, ModuleName {

    foreach ($module in $ModuleName)
    {
        foreach ($item in (Get-ChildItem -Path "$ModulePath\$module" -Exclude 'Functions', 'Helpers'))
        {
            Copy-Item -Path $item.FullName -Destination "$ReleasePath\$module\$($item.Name)" -Recurse -Verbose:$VerbosePreference
        }
    }
}

# Build the module by copying all helper and cmdlet functions to the psm1 file
Task Build -depends Init, Clean, Stage -requiredVariables ReleasePath, ModulePath, ModuleName {

    foreach ($module in $ModuleName)
    {
        $moduleContent = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

        # Load code for all function files
        foreach ($function in (Get-ChildItem -Path "$ModulePath\$module\Functions" -Filter '*.ps1' -File -ErrorAction 'SilentlyContinue'))
        {
            $moduleContent.Add((Get-Content -Path $function.FullName -Raw))
        }

        # Load code for all helpers files
        foreach ($function in (Get-ChildItem -Path "$ModulePath\$module\Helpers" -Filter '*.ps1' -File -ErrorAction 'SilentlyContinue'))
        {
            $moduleContent.Add((Get-Content -Path $function.FullName -Raw))
        }

        # Load code of the module file itself
        $moduleContent.Add((Get-Content -Path "$ModulePath\$module\$module.psm1" | Select-Object -Skip 15) -join "`r`n")

        # Concatenate whole code into the module file
        $moduleContent | Set-Content -Path "$ReleasePath\$module\$module.psm1" -Encoding UTF8 -Verbose:$VerbosePreference

        # Compress
        Compress-Archive -Path "$ReleasePath\$module" -DestinationPath "$ReleasePath\$module.zip" -Verbose:$VerbosePreference
    }
}

# Invoke Pester tests
Task Test -depends Build -requiredVariables ReleasePath, ModuleName, TestPath, TestFile {

    if (!(Get-Module -Name 'Pester' -ListAvailable))
    {
        Write-Warning "Pester module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    Import-Module -Name 'Pester'

    foreach ($module in $ModuleName)
    {
        try
        {
            Push-Location -Path "$ReleasePath\$module"

            $invokePesterParams = @{
                OutputFile   = Join-Path -Path $TestPath -ChildPath $TestFile
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

            Remove-Module -Name $module -ErrorAction SilentlyContinue
        }
    }
}
