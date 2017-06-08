<#
    .SYNOPSIS
    Stop registered watchers for file system change events.

    .DESCRIPTION
    Remove event subscribers for the existing path by getting all event
    subscribers and unregister all with the Unregister-Event command.

    .PARAMETER Path
    Path to stop watching changes.

    .INPUTS
    None.

    .OUTPUTS
    None

    .EXAMPLE
    C:\> Stop-WatchPath -Path 'C:\Demo'
    Stop watching the path C:\Demo for all events.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/WindowsFever
#>

function Stop-WatchPath
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ })]
        [System.String]
        $Path
    )

    $ErrorActionPreference = 'Stop'

    $Path = $Path.TrimEnd('\')

    # Unregister all event subscribers for the path.
    Get-EventSubscriber -SourceIdentifier "PSWatchPath|$Path|*" -ErrorAction SilentlyContinue | Unregister-Event
}
