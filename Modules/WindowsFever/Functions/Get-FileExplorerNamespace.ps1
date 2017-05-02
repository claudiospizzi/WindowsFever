<#
.SYNOPSIS
    List all file explorer namespaces of the current user.

.DESCRIPTION
    List all file explorer namespaces of the current user. It uses the registry
    with the following paths to enumerate the file explorer namespaces:
    - HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace
    - HKCU:\SOFTWARE\Classes\CLSID\{00000000-0000-0000-0000-000000000000}
    You can find the reference for this implementation on MSDN:
    https://msdn.microsoft.com/en-us/library/windows/desktop/dn889934

.PARAMETER Id
    Parameter to filter for the id (GUID) of the file explorer namespace.

.PARAMETER Name
    Parameter to filter for the name of the file explorer namespace.

.INPUTS
    None. This command does not accept pipeline input.

.OUTPUTS
    Spizzi.PowerShell.System.FileExplorerNamespace. A collection of file explorer namespace result objects.

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
    https://github.com/claudiospizzi/Spizzi.Management
#>

function Get-FileExplorerNamespace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)]
        [Guid] $Id = [Guid]::Empty,

        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [String] $Name = [String]::Empty
    )

    $NamespaceItems = Get-ChildItem -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace' | Get-ItemProperty

    foreach ($NamespaceItem in $NamespaceItems)
    {
        $NamespaceId   = [Guid] $NamespaceItem.PSChildName
        $NamespaceName = $NamespaceItem.'(default)'

        if (($Id -eq [Guid]::Empty -or $Id -eq $NamespaceId) -and ($Name -eq [String]::Empty -or $Name -eq $NamespaceName))
        {
            $InitPropertyBag = Get-ItemProperty "HKCU:\SOFTWARE\Classes\CLSID\{$NamespaceId}\Instance\InitPropertyBag"

            # Based on the property bag definition, use the curresponding type
            if ($InitPropertyBag.TargetKnownFolder -ne $null)
            {
                $TargetType  = 'KnownFolder'
                $TargetValue = $InitPropertyBag.TargetKnownFolder
            }
            elseif ($InitPropertyBag.TargetFolderPath -ne $null)
            {
                $TargetType  = 'FolderPath'
                $TargetValue = $InitPropertyBag.TargetFolderPath
            }
            else
            {
                $TargetType  = 'Unknown'
                $TargetValue = ''
            }

            # Create a correctly typed output object
            $Namespace = New-Object -TypeName PSObject -Property @{
                Id          = $NamespaceId
                Name        = $NamespaceName
                Icon        = $(try { Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{$NamespaceId}\DefaultIcon" -ErrorAction Stop | Select-Object -ExpandProperty '(default)' } catch { 'Unknown' })
                Order       = $(try { Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{$NamespaceId}" -ErrorAction Stop | Select-Object -ExpandProperty 'SortOrderIndex' } catch { 'Unknown' })
                TargetType  = $TargetType
                TargetValue = $TargetValue
            }
            $Namespace.PSTypeNames.Insert(0, 'Spizzi.PowerShell.Management.FileExplorerNamespace')

            Write-Output $Namespace
        }
    }
}
