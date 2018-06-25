<#
    .SYNOPSIS
        Update properties of an existing file explorer namespace.

    .DESCRIPTION
        Update properties of an existing file explorer namespace in Windows 10.
        It updates the following registry paths to change the namespace, if
        required:
        - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
        - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel
        - HKCU:\SOFTWARE\Classes\CLSID\{00000000-0000-0000-0000-000000000000}
        - HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID\{00000000-0000-0000-0000-000000000000}
        You can find the reference for this implementation on MSDN. Even if it's
        intended for a Cloud Storage Provider, it will work for every local
        folder:
        - https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

    .PARAMETER Id
        The GUID of the existing file explorer namespace.

    .PARAMETER Name
        The new name of the new file explorer namespace.

    .PARAMETER Icon
        The new icon of the new file explorer namespace. Please specify a target
        dll or exe with the id of the icon.

    .PARAMETER Order
        The new order of the new file explorer namespace. The order defines,
        where in the file explorer the new namespace will be visible.

    .INPUTS
        WindowsFever.FileExplorerNamespace.

    .OUTPUTS
        WindowsFever.FileExplorerNamespace.

    .EXAMPLE
        PS C:\> Get-FileExplorerNamespace -Name 'PowerShell' | Set-FileExplorerNamespace -Order 66
        Update the order property of the existing PowerShell file explorer
        namespace to number 66.

    .NOTES
        Author     : Claudio Spizzi
        License    : MIT License

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Set-FileExplorerNamespace
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.Guid[]]
        $Id,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Icon,

        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Order
    )

    process
    {
        foreach ($currentId in $Id)
        {
            # For security reason, check if the namespace exists
            if ($null -eq (Get-FileExplorerNamespace -Id $currentId))
            {
                throw "The file explorer namespace with Id '$currentId' does not exists!"
            }

            # The method ShouldProcess asks the user for confirmation or display
            # just the action we perform inside this if when the users uses
            # -WhatIf
            if ($PSCmdlet.ShouldProcess($currentId, 'Set'))
            {
                # Use the default and WOW64 node to place the class
                foreach ($Key in 'HKCU:\SOFTWARE\Classes\CLSID', 'HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID')
                {
                    if ((Test-Path -Path $Key))
                    {
                        # Update the name
                        if ($PSBoundParameters.Keys -contains 'Name')
                        {
                            Set-Item -Path "$Key\{$currentId}" -Value $Name -Force | Out-Null
                        }

                        # Update the icon
                        if ($PSBoundParameters.Keys -contains 'Icon')
                        {
                            Set-Item -Path "$Key\{$currentId}\DefaultIcon" -Value $Icon -Force | Out-Null
                        }

                        # Update the order
                        if ($PSBoundParameters.Keys -contains 'Order')
                        {
                            Set-ItemProperty -Path "$Key\{$currentId}" -Name 'SortOrderIndex' -Value $Order -Force | Out-Null
                        }
                    }
                }

                # Update the name
                if ($PSBoundParameters.Keys -contains 'Name')
                {
                    Set-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{$currentId}" -Value $Name -Force | Out-Null
                }

                # Return the newly create file explorer namespace
                Get-FileExplorerNamespace -Id $currentId
            }
        }
    }
}
