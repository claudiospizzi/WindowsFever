<#
    .SYNOPSIS
        Test the internet connection by pinging local and public addresses, and
        testing DNS resolution and HTTPS connectivity.

    .DESCRIPTION
        The Test-Internet function checks the internet connection by performing
        the following tests:
        1. Pings local IP addresses to test the network stack.
        2. Pings default gateways to ensure connectivity to the local network.
        3. Pings well-known public DNS servers to verify external connectivity.
        4. Resolves domain names of popular websites to test DNS resolution.
        5. Tests HTTPS connectivity to popular web services.

    .EXAMPLE
        PS C:\> Test-Internet
        This command runs the Test-Internet function and returns the results of
        the connectivity tests.

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Test-Internet
{
    [CmdletBinding()]
    param ()

    # Ping local ip addresses to test the network stack
    $ipAddresses = @('::1', '127.0.0.1')
    $ipAddresses += @(Get-NetIPAddress -AddressFamily 'IPv4' -Type 'Unicast' | Where-Object { $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -ExpandProperty 'IPAddress')
    foreach ($ipAddress in $ipAddresses)
    {
        [PSCustomObject] @{
            Type     = 'LocalAddress'
            Protocol = 'ICMP'
            Service  = 'Ping'
            Target   = [System.String] $ipAddress
            Result   = Test-Connection -ComputerName $ipAddress -Count 1 -Quiet
        }
    }

    $defaultGateways = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0')
    if ($defaultGateways.Count -eq 0)
    {
        throw 'No default gateway found!'
    }
    foreach ($defaultGateway in $defaultGateways)
    {
        [PSCustomObject] @{
            Type     = 'DefaultGateway'
            Protocol = 'ICMP'
            Service  = 'Ping'
            Target   = [System.String] $defaultGateway.NextHop
            Result   = Test-Connection -ComputerName $defaultGateway.NextHop -Count 1 -Quiet
        }
    }

    # Well-known public DNS servers
    $publicAddresses = '1.1.1.1', '8.8.8.8', '9.9.9.9'
    foreach ($publicAddress in $publicAddresses)
    {
        [PSCustomObject] @{
            Type     = 'PublicAddress'
            Protocol = 'ICMP'
            Service  = 'Ping'
            Target   = [System.String] $publicAddress
            Result   = Test-Connection -ComputerName $publicAddress -Count 1 -Quiet
        }
    }

    # Use different TLDs to test name resolution
    $nameResolutions = 'iana.org', 'cloudflare.com', 'quad9.net'
    foreach ($nameResolution in $nameResolutions)
    {
        $result = [PSCustomObject] @{
            Type     = 'PublicAddress'
            Protocol = 'UDP'
            Service  = 'DNS'
            Target   = $nameResolution
            Result   = ''
        }

        try
        {
            Resolve-DnsName -Name $nameResolution -ErrorAction 'Stop' | Out-Null
            $result.Result = $true
        }
        catch
        {
            $result.Result = $false
        }

        Write-Output $result
    }

    $webServices = 'office.com', 'github.com', 'google.com', 'microsoft.com', 'cloudflare.com', 'quad9.net'
    foreach ($webService in $webServices)
    {
        [PSCustomObject] @{
            Type     = 'WebServices'
            Protocol = 'TCP'
            Service  = 'HTTPS'
            Target   = '{0}' -f $webService
            Result   = Test-NetConnection -ComputerName $webService -Port 443 -WarningAction 'SilentlyContinue' | Select-Object -ExpandProperty 'TcpTestSucceeded'
        }
    }
}
