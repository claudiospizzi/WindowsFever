[![PowerShell Gallery - WindowsFever](https://img.shields.io/badge/PowerShell_Gallery-WindowsFever-0072C6.svg)](https://www.powershellgallery.com/packages/WindowsFever)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/WindowsFever.svg)](https://github.com/claudiospizzi/WindowsFever/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/WindowsFever/master.svg)](https://ci.appveyor.com/project/claudiospizzi/WindowsFever/branch/master)
[![AppVeyor - dev](https://img.shields.io/appveyor/ci/claudiospizzi/WindowsFever/master.svg)](https://ci.appveyor.com/project/claudiospizzi/WindowsFever/branch/dev)


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


## Features

* **Add-FileExplorerNamespace**  
  Create a new file explorer namespace in Windows 10.

* **Get-FileExplorerNamespace**  
  List all file explorer namespaces of the current user.

* **Remove-FileExplorerNamespace**  
  Remove an existing file explorer namespace.

* **Set-FileExplorerNamespace**  
  Update properties of an existing file explorer namespace.

* **Start-WatchPath**  
  Register an event watcher for file system change events.

* **Stop-WatchPath**  
  Stop registered watchers for file system change events.


## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.


## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'WindowsFever'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]


## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows 10 (for the File Explorer Namespace functions)


## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code]
* [PowerShell Extension]



[Integrate a Cloud Storage Provider]: https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

[PowerShell Gallery]: https://www.powershellgallery.com/packages/WindowsFever
[GitHub Releases]: https://github.com/claudiospizzi/WindowsFever/releases
[Installing a PowerShell Module]: https://msdn.microsoft.com/en-us/library/dd878350

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
