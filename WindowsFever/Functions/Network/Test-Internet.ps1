<#
    .SYNOPSIS
        .

    .DESCRIPTION
        .

    .INPUTS
        .

    .OUTPUTS
        .

    .EXAMPLE
        PS C:\> Test-Internet
        .

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Test-Internet
{
    [CmdletBinding()]
    param ()

    $ipAddresses = @(Get-NetIPAddress -AddressFamily 'IPv4' -Type 'Unicast' | Where-Object { $_.PrefixOrigin -ne 'WellKnown' } | Sort-Object -Property 'IPAddress')
    if ($ipAddresses.Count -eq 0)
    {
        throw 'No IP adresses found!'
    }
    foreach ($ipAddress in $ipAddresses)
    {
        [PSCustomObject] @{
            Type   = 'IPAddress'
            Test   = 'Ping'
            Target = [System.String] $ipAddress.IPAddress
            Result = Test-Connection -ComputerName $ipAddress.IPAddress -Count 1 -Quiet
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
            Type   = 'DefaultGateway'
            Target = [System.String] $defaultGateway.NextHop
            Test   = 'Ping'
            Result = Test-Connection -ComputerName $defaultGateway.NextHop -Count 1 -Quiet
        }
    }

    $publicAddresses = '1.1.1.1', '8.8.8.8', '9.9.9.9'
    foreach ($publicAddress in $publicAddresses)
    {
        [PSCustomObject] @{
            Type   = 'PublicAddress'
            Target = [System.String] $publicAddress
            Test   = 'Ping'
            Result = Test-Connection -ComputerName $publicAddress -Count 1 -Quiet
        }
    }

    $nameResolutions = 'microsoft.com', 'office.com', 'azure.com'
    foreach ($nameResolution in $nameResolutions)
    {
        $result = [PSCustomObject] @{
            Type   = 'PublicAddress'
            Target = $nameResolution
            Test   = 'DNS'
            Result = ''
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

    $webServices = 'microsoft.com', 'office.com', 'azure.com'
    foreach ($webService in $webServices)
    {
        foreach ($port in 80, 443)
        {
            [PSCustomObject] @{
                Type   = 'WebServices'
                Target = '{0}:{1}' -f $webService, $port
                Test   = 'TCP'
                Result = Test-NetConnection -ComputerName $webService -Port $port -WarningAction 'SilentlyContinue' | Select-Object -ExpandProperty 'TcpTestSucceeded'
            }
        }
    }
}
