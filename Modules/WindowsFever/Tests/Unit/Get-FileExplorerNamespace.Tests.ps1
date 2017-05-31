
$modulePath = Resolve-Path -Path "$PSScriptRoot\..\..\.." | Select-Object -ExpandProperty Path
$moduleName = Resolve-Path -Path "$PSScriptRoot\..\.." | Get-Item | Select-Object -ExpandProperty BaseName

Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$modulePath\$moduleName" -Force

Describe 'Get-FileExplorerNamespace' {

    Context 'Default' {

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\*' } {
            [PSCustomObject] @{
                '(default)'   = 'OneDrive'
                'PSChildName' = '{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
            }
            [PSCustomObject] @{
                '(default)'   = 'Dropbox'
                'PSChildName' = '{E31EA727-12ED-4702-820C-4B6445F28E1A}'
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\Instance\initPropertyBag' } {
            [PSCustomObject] @{
                'TargetKnownFolder' = '{a52bba46-e9e1-435f-b3d9-28daa648c0f6}'
                'TargetFolderPath'  = $null
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\Instance\initPropertyBag' } {
            [PSCustomObject] @{
                'TargetKnownFolder' = $null
                'TargetFolderPath'  = 'C:\Users\Demo\Dropbox'
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\DefaultIcon' } {
            [PSCustomObject] @{
                '(default)' = 'C:\Users\claudio.spizzi\AppData\Local\Microsoft\OneDrive\OneDrive.exe,0'
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}\DefaultIcon' } {
            [PSCustomObject] @{
                '(default)' = 'C:\Program Files (x86)\Dropbox\Client\Dropbox.exe,-6001'
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' } {
            [PSCustomObject] @{
                'SortOrderIndex' = 66
            }
        }

        Mock 'Get-ItemProperty' -ModuleName $moduleName -ParameterFilter { $Path -eq 'HKCU:\SOFTWARE\Classes\CLSID\{E31EA727-12ED-4702-820C-4B6445F28E1A}' } {
            [PSCustomObject] @{
                'SortOrderIndex' = 66
            }
        }

        It 'should return all namespaces' {

            # Act
            $namespaces = Get-FileExplorerNamespace

            # Assert
            $namespaces.Count | Should Be 2
        }

        It 'should return the OneDrive namespace by name' {

            # Act
            $namespace = Get-FileExplorerNamespace -Name 'OneDrive'

            # Assert
            $namespace.Id          | Should Be '018D5C66-4533-4307-9B53-224DE2ED1FE6'
            $namespace.Name        | Should Be 'OneDrive'
            $namespace.Icon        | Should Be 'C:\Users\claudio.spizzi\AppData\Local\Microsoft\OneDrive\OneDrive.exe,0'
            $namespace.Order       | Should Be 66
            $namespace.TargetType  | Should Be 'KnownFolder'
            $namespace.TargetValue | Should Be '{a52bba46-e9e1-435f-b3d9-28daa648c0f6}'
        }

        It 'should return the Dropbox namespace by id' {

            # Act
            $namespace = Get-FileExplorerNamespace -Id '{E31EA727-12ED-4702-820C-4B6445F28E1A}'

            # Assert
            $namespace.Id          | Should Be 'E31EA727-12ED-4702-820C-4B6445F28E1A'
            $namespace.Name        | Should Be 'Dropbox'
            $namespace.Icon        | Should Be 'C:\Program Files (x86)\Dropbox\Client\Dropbox.exe,-6001'
            $namespace.Order       | Should Be 66
            $namespace.TargetType  | Should Be 'FolderPath'
            $namespace.TargetValue | Should Be 'C:\Users\Demo\Dropbox'
        }

        It 'should not return any namespaces' {

            # Act
            $namespace = Get-FileExplorerNamespace -Name 'Demo'

            # Assert
            $namespace | Should BeNullOrEmpty
        }
    }
}
