<#
    .SYNOPSIS
    List all file explorer namespaces of the current user.

    .DESCRIPTION
    List all file explorer namespaces of the current user. It uses the registry
    with the following paths to enumerate the file explorer namespaces:
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
    - HKCU:\SOFTWARE\Classes\CLSID\{00000000-0000-0000-0000-000000000000}
    You can find the reference for this implementation on MSDN. Even if it's
    intended for a Cloud Storage Provider, it will work for every local folder:
    - https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

    .PARAMETER Id
    Parameter to filter for the id (GUID) of the file explorer namespace.

    .PARAMETER Name
    Parameter to filter for the name of the file explorer namespace.

    .INPUTS
    None.

    .OUTPUTS
    WindowsFever.FileExplorerNamespace.

    .EXAMPLE
    C:\> Get-FileExplorerNamespace
    Get all file explorer namespaces for the current user.

    .EXAMPLE
    C:\> Get-FileExplorerNamespace -Id '018d5c66-4533-4307-9b53-224de2ed1fe6'
    Get the file explorer namespaces with the provided GUID, which in this case is OneDrive.

    .EXAMPLE
    C:\> Get-FileExplorerNamespace -Name 'OneDrive'
    Get the file explorer namespaces with the name OneDrive.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/WindowsFever
#>

function Get-FileExplorerNamespace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.Guid]
        $Id = [Guid]::Empty,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $Name = [String]::Empty
    )

    $namespaceItems = Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\*'

    foreach ($namespaceItem in $namespaceItems)
    {
        $namespaceId   = [Guid] $namespaceItem.PSChildName
        $namespaceName = $namespaceItem.'(default)'

        if (($Id -eq [Guid]::Empty -or $Id -eq $namespaceId) -and ($Name -eq [String]::Empty -or $Name -eq $namespaceName))
        {
            $initPropertyBag = Get-ItemProperty "HKCU:\SOFTWARE\Classes\CLSID\{$namespaceId}\Instance\initPropertyBag"

            # Based on the property bag definition, use the corresponding type
            if ($initPropertyBag.TargetKnownFolder -ne $null)
            {
                $targetType  = 'KnownFolder'
                $targetValue = $initPropertyBag.TargetKnownFolder
            }
            elseif ($initPropertyBag.TargetFolderPath -ne $null)
            {
                $targetType  = 'FolderPath'
                $targetValue = $initPropertyBag.TargetFolderPath
            }
            else
            {
                $targetType  = 'Unknown'
                $targetValue = ''
            }

            # Create a correctly typed output object
            $namespace = New-Object -TypeName PSObject -Property @{
                Id          = $namespaceId
                Name        = $namespaceName
                Icon        = $(try { Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{$namespaceId}\DefaultIcon" -ErrorAction Stop | Select-Object -ExpandProperty '(default)' } catch { 'Unknown' })
                Order       = $(try { Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{$namespaceId}" -ErrorAction Stop | Select-Object -ExpandProperty 'SortOrderIndex' } catch { 'Unknown' })
                targetType  = $targetType
                targetValue = $targetValue
            }
            $namespace.PSTypeNames.Insert(0, 'WindowsFever.FileExplorerNamespace')

            Write-Output $namespace
        }
    }
}
