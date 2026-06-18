[![GitHub Release](https://img.shields.io/github/v/release/claudiospizzi/WindowsFever?label=Release&logo=GitHub&sort=semver)](https://github.com/claudiospizzi/WindowsFever/releases)
[![GitHub CI Build](https://img.shields.io/github/actions/workflow/status/claudiospizzi/WindowsFever/pwsh-ci.yml?label=CI%20Build&logo=GitHub)](https://github.com/claudiospizzi/WindowsFever/actions/workflows/pwsh-ci.yml)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/WindowsFever?label=PowerShell%20Gallery&logo=PowerShell)](https://www.powershellgallery.com/packages/WindowsFever)
[![Gallery Downloads](https://img.shields.io/powershellgallery/dt/WindowsFever?label=Downloads&logo=PowerShell)](https://www.powershellgallery.com/packages/WindowsFever)

# WindowsFever PowerShell Module

PowerShell Module with custom functions and cmdlets related to Windows.

## Introduction

This is a personal PowerShell Module by Claudio Spizzi. It is used to unite all
personal Windows Operating System related functions and cmdlets into one module.

Within this module, the **File Explorer Namespaces** in Windows 10 can be
customized as needed. The File Explorer Namespaces provide the possibility to
add new folders to the left pane of the File Explorer. Additional information
about the File Explorer Namespaces are available on MSDN: [Integrate a Cloud
Storage Provider].

[Integrate a Cloud Storage Provider]: https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

## Features

### File Explorer Namespace

* **Add-FileExplorerNamespace**  
  Create a new file explorer namespace in Windows 10.

* **Get-FileExplorerNamespace**  
  List all file explorer namespaces of the current user.

* **Remove-FileExplorerNamespace**  
  Remove an existing file explorer namespace.

* **Set-FileExplorerNamespace**  
  Update properties of an existing file explorer namespace.

Some examples to work with the File Explorer Namespace:

```powershell
# Get all file explorer namespaces for the current user.
Get-FileExplorerNamespace

# Create a complex Workspace file explorer namespace by specified every
# parameter including a specific icon.
Add-FileExplorerNamespace -Name 'Workspace' -Icon '%SystemRoot%\System32\imageres.dll,156' -TargetFolderPath "$HOME\Workspace" -Order 67

# Create a complex PowerShell file explorer namespace by specified every
# parameter including a specific icon.
Add-FileExplorerNamespace -Name 'PowerShell' -Icon '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe,0' -TargetFolderPath "$HOME\Dropbox\PowerShell" -Order 65

# Update the order property of the existing PowerShell file explorer namespace.
Get-FileExplorerNamespace -Name 'PowerShell' | Set-FileExplorerNamespace -Order 66

# Remove the file explorer namespace called Test.
Get-FileExplorerNamespace -Name 'Test' | Remove-FileExplorerNamespace
```

### Path Watcher

* **Start-WatchPath**  
  Register an event watcher for file system change events.

* **Stop-WatchPath**  
  Stop registered watchers for file system change events.

Some examples to work with the Path Watcher:

```powershell
# Watch the C:\Demo\file.txt for changes and write them to the host.
Start-WatchPath -Path 'C:\Demo' -Filter 'file.txt' -ChangedAction { $Event.SourceArgs[1].FullPath | Out-File -FilePath 'C:\Log\changed.log' }

# Stop watching on C:\Demo.
Stop-WatchPath -Path 'C:\Demo'
```

### Hosts File

* **Add-HostsEntry**  
  Add a new entry to the hosts file.

* **Get-HostsEntry**  
  List all entries of the hosts file.

### Connection Test

* **Test-Internet**  
  Test the internet connection by pinging local and public addresses, and testing DNS resolution and HTTPS connectivity.

## Versions

Please find all versions in the [GitHub Releases] section and the release notes in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery], if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'WindowsFever'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]

## Requirements

The following minimum requirements are recommended to use this module. It used to work on older versions and other platforms too, but they are not officially supported or tested.

* Windows 11 / PowerShell 7

## Contribute

Please feel free to contribute by opening new issues or providing pull requests. For the best development experience, open this project as a folder in Visual Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code] with the [PowerShell Extension]
* [Pester], [PSScriptAnalyzer], [InvokeBuild] and [InvokeBuildHelper] modules

[PowerShell Gallery]: https://www.powershellgallery.com/packages/WindowsFever
[GitHub Releases]: https://github.com/claudiospizzi/WindowsFever/releases
[Installing a PowerShell Module]: https://learn.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[Pester]: https://www.powershellgallery.com/packages/Pester
[PSScriptAnalyzer]: https://www.powershellgallery.com/packages/PSScriptAnalyzer
[InvokeBuild]: https://www.powershellgallery.com/packages/InvokeBuild
[InvokeBuildHelper]: https://www.powershellgallery.com/packages/InvokeBuildHelper
