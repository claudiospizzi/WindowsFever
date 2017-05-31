[![AppVeyor - master](https://ci.appveyor.com/api/projects/status/qy518j43ii6f1xdq/branch/master?svg=true)](https://ci.appveyor.com/project/claudiospizzi/windowsfever/branch/master)
[![AppVeyor - dev](https://ci.appveyor.com/api/projects/status/qy518j43ii6f1xdq/branch/dev?svg=true)](https://ci.appveyor.com/project/claudiospizzi/windowsfever/branch/dev)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/WindowsFever.svg)](https://github.com/claudiospizzi/WindowsFever/releases)
[![PowerShell Gallery - WindowsFever](https://img.shields.io/badge/PowerShell_Gallery-WindowsFever-0072C6.svg)](https://www.powershellgallery.com/packages/WindowsFever)


# WindowsFever PowerShell Module

PowerShell Module with custom functions and cmdlets related to Windows.


## Introduction

This is a personal PowerShell Module by Claudio Spizzi. It is used to unite all
proven Windows Operating System related functions and cmdlets into one module.

Within this module, the **File Explorer Namespaces** in Windows 10 can be
customized as needed.


## Features

* **Add-FileExplorerNamespace**
  Create a new file explorer namespace in Windows 10.

* **Get-FileExplorerNamespace**
  List all file explorer namespaces of the current user.

* **Remove-FileExplorerNamespace**
  Remove an existing file explorer namespace.

* **Set-FileExplorerNamespace**
  Update properties of an existing file explorer namespace.


## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows 10 (for some commands)


## Installation

Use the following command to install the module from the PowerShell Gallery.

```powershell
# Download and install the module
Install-Module -Name 'WindowsFever'
```
