<#
    .SYNOPSIS
        Add an entry to the hosts file.

    .DESCRIPTION
        Add an entry to the C:\Windows\System32\drivers\etc\hosts file formatted
        as best practices.

    .PARAMETER Address
        The IPv4 address for the hosts file entry.

    .PARAMETER Hostname
        The hostname for the hosts file entry.

    .INPUTS
        None.

    .OUTPUTS
        WindowsFever.HostsEntry.

    .EXAMPLE
        PS C:\> Add-HostsEntry -Address '8.8.8.8' -Hostname 'google-public-dns-a.google.com'
        Add a hosts entry to the Google Public DNS A host.

    .NOTES
        Author     : Claudio Spizzi
        License    : MIT License

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Add-HostsEntry
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Address,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Hostname
    )

    $hostsFilePath = "$Env:WINDIR\System32\drivers\etc\hosts"

    $currentEntries = Get-NetworkHostsEntry
    foreach ($currentEntry in  $currentEntries)
    {
        if ($currentEntry.Address -eq $Address -and $currentEntry.Hostname -eq $Hostname)
        {
            throw "The host entry already exists!"
        }
    }

    # Form a new entry to add to the hosts file
    $entry = "{0,-24}{1}" -f $Address, $Hostname

    if ($PSCmdlet.ShouldProcess($hostsFilePath, "Append line '$entry'"))
    {
        Add-Content -Path $hostsFilePath -Value $entry -Encoding 'UTF8'

        Get-HostsEntry | Where-Object { $_.Address -eq $Address -and $_.Hostname -eq $Hostname }
    }
}
