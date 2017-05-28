<#
    .SYNOPSIS
    Remove an existing file explorer namespace.

    .DESCRIPTION
    Remove an existing file explorer namespace. It removes all entries from the
    following registry keys. Take care, you can also remove an existing built-in
    file explorer namespace like OneDrive.
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel
    - HKCU:\SOFTWARE\Classes\CLSID\{00000000-0000-0000-0000-000000000000}
    - HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID\{00000000-0000-0000-0000-000000000000}
    You can find the reference for this implementation on MSDN:
    https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

    .PARAMETER Id
    The id of the file explorer namespace to delete.

    .INPUTS
    WindowsFever.FileExplorerNamespace. You can pipe existing file explorer
    namespace objects to remove them from the system.

    .OUTPUTS
    None. The command does not return any objects.

    .EXAMPLE
    C:\> Remove-FileExplorerNamespace -Id 'e9ec969f-3e60-4be3-b2bb-1a5d04beacc1'
    Remove the file explorer namespace with the given id.

    .EXAMPLE
    C:\> Get-FileExplorerNamespace -Name 'Test' | Remove-FileExplorerNamespace
    Remove the file explorer namespace with the name 'Test'.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/WindowsFever
#>

function Remove-FileExplorerNamespace
{
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.Guid[]]
        $Id
    )

    process
    {
        foreach ($currentId in $Id)
        {
            if ((Get-FileExplorerNamespace -Id $currentId) -ne $null)
            {
                # The method ShouldProcess asks the user for confirmation or display just
                # the action we perform inside this if when the users uses -WhatIf
                if ($PSCmdlet.ShouldProcess($currentId, 'Remove'))
                {
                    # Step 1: Remove CLSID class implementation
                    foreach ($key in 'HKCU:\SOFTWARE\Classes\CLSID', 'HKCU:\SOFTWARE\Classes\Wow6432Node\CLSID')
                    {
                        if ((Test-Path -Path $key))
                        {
                            Remove-Item -Path "$key\{$currentId}" -Recurse -Force
                        }
                    }

                    # Step 2: Remove namespace extension from root
                    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{$currentId}" -Recurse -Force

                    # Step 3: Remove desktop hide feature
                    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{$currentId}" -Force
                }
            }
            else
            {
                Write-Warning -Message "The file explorer namespace with Id '$currentId' does not exists!"
            }
        }
    }
}
