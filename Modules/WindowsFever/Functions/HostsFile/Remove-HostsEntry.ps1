<#
    .SYNOPSIS


    .DESCRIPTION


    .PARAMETER Id


    .INPUTS
        None.

    .OUTPUTS
        WindowsFever.HostsEntry.

    .EXAMPLE
        PS C:\>


    .EXAMPLE
        PS C:\>


    .NOTES
        Author     : Claudio Spizzi
        License    : MIT License

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Remove-HostsEntry
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'HostsEntry', ValueFromPipeline = $true)]
        [System.Management.Automation.PSObject[]]
        $InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'AddressHostname')]
        [System.String]
        $Address,

        [Parameter(Mandatory = $true, ParameterSetName = 'AddressHostname')]
        [System.String]
        $Hostname
    )

    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'AddressHostname')
        {
            $hostsEntry = Get-HostsEntry | Where-Object { $_.Address -eq $Address -and $_.Hostname -eq $Hostname }

            if ($null -eq $hostsEntry)
            {
                throw "The host entry does not exists!"
            }

            $InputObject += $hostsEntry
        }
    }

    process
    {
        foreach ($hostsEntry in $InputObject)
        {

        }
    }
}
