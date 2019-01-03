<#
    .SYNOPSIS
        Get all entries from the hosts file.

    .DESCRIPTION
        Get the content of the C:\Windows\System32\drivers\etc\hosts file and
        parse all lines with regex to extract the host entries.

    .INPUTS
        None.

    .OUTPUTS
        WindowsFever.HostsEntry.

    .EXAMPLE
        PS C:\> Get-HostsEntry
        Get all entries from the local hosts file.

    .NOTES
        Author     : Claudio Spizzi
        License    : MIT License

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Get-HostsEntry
{
    [CmdletBinding()]
    param ()

    $hostsFilePath  = "$Env:WINDIR\System32\drivers\etc\hosts"
    $hostsFileRegex = '^\s*(?<Address>(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\s+(?<Hostname>[a-zA-Z0-9.]+)\s*$'

    # Check if the hosts file exists
    if (-not (Test-Path -Path $hostsFilePath))
    {
        throw 'Hosts file not found!'
    }

    $data = Get-Content -Path $hostsFilePath

    for ($i = 0; $i -lt $data.Length; $i++)
    {
        $match = [System.Text.RegularExpressions.Regex]::Match($data[$i], $hostsFileRegex)

        if ($match.Success)
        {
            [PSCustomObject] @{
                PSTypeName = 'WindowsFever.HostsEntry'
                Address   = $match.Groups['Address'].Value
                Hostname  = $match.Groups['Hostname'].Value
                Reference = $i + 1
            }
        }
    }
}
