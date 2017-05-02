<#
.SYNOPSIS
    Create a new file explorer namespace in Windows 10.

.DESCRIPTION
    Create a new file explorer namespace in Windows 10. It uses the folloing
    registry paths to register the namespace properly.
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel
    - HKCU:\SOFTWARE\Classes\CLSID\{00000000-0000-0000-0000-000000000000}
    - HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID\{00000000-0000-0000-0000-000000000000}
    You can find the reference for this implementation on MSDN:
    https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

.PARAMETER Id
    The guid of the new file explorer namespace. A random id will be generated,
    if this parameter is not specified.

.PARAMETER Name
    The name of the new file explorer namespace. This name will be visible
    inside the file explorer.

.PARAMETER Icon
    The icon of the new file explorer namespace. Please specify a target dll or
    exe with the id of the icon. By default, the following icon is used:
    %SystemRoot%\System32\imageres.dll,156

.PARAMETER Order
    The order of the new file explorer namespace. The order defines, where in
    the file explorer the new namespace will be visiable. The default order is
    66 (StarWars?).

.PARAMETER TargetKnownFolder
    You can specify a guid for a known folder, e.g. for OneDrive.

.PARAMETER TargetFolderPath
    You can specify a physical path to the target folder path.

.INPUTS
    None. This command does not accept pipeline input.

.OUTPUTS
    Spizzi.PowerShell.System.FileExplorerNamespace. The created file explorer namespace object.

.EXAMPLE
    C:\> Add-FileExplorerNamespace -Name 'Test' -TargetFolderPath 'C:\Test'
    Create a simple file explorer namespace with the name Test which points to C:\Test.

.EXAMPLE
    C:\> Add-FileExplorerNamespace -Name 'Workspace' -Icon '%SystemRoot%\System32\imageres.dll,156' -TargetFolderPath "$HOME\Workspace" -Order 67
    Create a complex Workspace file explorer namespace by specified every parameter including a specific icon.

.EXAMPLE
    C:\> Add-FileExplorerNamespace -Name 'PowerShell' -Icon '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe,0' -TargetFolderPath "$HOME\Dropbox\PowerShell" -Order 65
    Create a complex PowerShell file explorer namespace by specified every parameter including a specific icon.

.EXAMPLE
    C:\> Add-FileExplorerNamespace -Id '57C16D98-4CA5-4AAA-8118-48C28D8C50BC' -Name 'OneDrive (Copy)' -Icon 'C:\WINDOWS\system32\imageres.dll,-1043' -TargetKnownFolder 'a52bba46-e9e1-435f-b3d9-28daa648c0f6'
    Duplicate the OneDrive namespace inside the file explorer by using the OneDrive known folder class id.

.NOTES
    Author     : Claudio Spizzi
    License    : MIT License

.LINK
    https://github.com/claudiospizzi/Spizzi.Management
#>

function Add-FileExplorerNamespace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)]
        [Guid] $Id = [Guid]::NewGuid(),

        [Parameter(Mandatory=$true)]
        [String] $Name,

        [Parameter(Mandatory=$false)]
        [String] $Icon = '%SystemRoot%\System32\imageres.dll,156',

        [Parameter(Mandatory=$false)]
        [Int32] $Order = 66,

        [Parameter(Mandatory=$true,
                   ParameterSetName='KnownFolder')]
        [Guid] $TargetKnownFolder,

        [Parameter(Mandatory=$true,
                   ParameterSetName='FolderPath')]
        [ValidateScript({Test-Path -Path $_})]
        [String] $TargetFolderPath
    )

    # For security reason, check if the namespace already exists
    if ((Get-FileExplorerNamespace -Id $Id) -ne $null)
    {
        throw "The file explorer namespace with Id '$Id' already exists!"
    }

    # Use the default and WOW64 node to place the class
    foreach ($Key in 'HKCU:\SOFTWARE\Classes\CLSID', 'HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID')
    {
        if ((Test-Path -Path $Key))
        {
            # Step 1: Add your CLSID and name your extension
            New-Item -Path $Key -Name "{$Id}" -Value $Name -ItemType String -Force | Out-Null

            # Step 2: Set the image for your icon
            New-Item -Path "$Key\{$Id}" -Name 'DefaultIcon' -Value $Icon -ItemType String -Force | Out-Null

            # Step 3: Add your extension to the Navigation Pane and make it visible
            New-ItemProperty -Path "$Key\{$Id}" -Name 'System.IsPinnedToNameSpaceTree' -Value 1 -PropertyType DWord -Force | Out-Null

            # Step 4: Set the location for your extension in the Navigation Pane
            New-ItemProperty -Path "$Key\{$Id}" -Name 'SortOrderIndex' -Value $Order -PropertyType DWord -Force | Out-Null

            # Step 5: Provide the dll that hosts your extension
            New-Item -Path "$Key\{$Id}" -Name 'InProcServer32' -Value "%SystemRoot%\System32\shell32.dll" -ItemType String -Force | Out-Null

            # Step 6: Define the instance object
            New-Item -Path "$Key\{$Id}" -Name 'Instance' -ItemType String -Force | Out-Null
            New-ItemProperty -Path "$Key\{$Id}\Instance" -Name 'CLSID' -Value '{0E5AAE11-A475-4c5b-AB00-C66DE400274E}' -PropertyType String -Force | Out-Null

            # Step 7: Provide the file system attributes of the target folder
            New-Item -Path "$Key\{$Id}\Instance" -Name 'InitPropertyBag' -ItemType String -Force | Out-Null
            New-ItemProperty -Path "$Key\{$Id}\Instance\InitPropertyBag" -Name 'Attributes' -Value 17 -PropertyType DWord -Force | Out-Null
                
            # Step 8: Set the path for the target (depending of the type)
            switch ($PSCmdlet.ParameterSetName)
            {
                'KnownFolder' { New-ItemProperty -Path "$Key\{$Id}\Instance\InitPropertyBag" -Name 'TargetKnownFolder' -Value "{$TargetKnownFolder}" -PropertyType ExpandString -Force | Out-Null }
                'FolderPath'  { New-ItemProperty -Path "$Key\{$Id}\Instance\InitPropertyBag" -Name 'TargetFolderPath' -Value $TargetFolderPath -PropertyType ExpandString -Force | Out-Null }
            }

            # Step 9: Set appropriate shell flags
            New-Item -Path "$Key\{$Id}" -Name 'ShellFolder' -ItemType String -Force | Out-Null
            New-ItemProperty -Path "$Key\{$Id}\ShellFolder" -Name 'FolderValueFlags' -Value 40 -PropertyType DWord -Force | Out-Null

            # Step 10: Set the appropriate flags to control your shell behavior
            New-ItemProperty -Path "$Key\{$Id}\ShellFolder" -Name 'Attributes' -Value 4034920525 -PropertyType DWord -Force | Out-Null
        }
    }

    # Step 11: Register your extension in the namespace root
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace" -Name "{$Id}" -Value $Name -ItemType String -Force | Out-Null

    # Step 12: Hide your extension from the Desktop
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{$Id}" -Value 1 -PropertyType DWord -Force | Out-Null

    # Return the newly create file explorer namespace
    Get-FileExplorerNamespace -Id $Id
}
