<#
    .SYNOPSIS
        Register an event watcher for file system change events.

    .DESCRIPTION
        Use the System.IO.FileSystemWatcher .NET class to watch for file system
        events like create, change, rename and delete. Thanks to the PowerShell
        cmdlet Register-ObjectEvent, you can provide script blocks to process
        the events.

    .PARAMETER Path
        Path to watch for changes.

    .PARAMETER Filter
        The file filter, be default any file (wildcard).

    .PARAMETER Recurse
        Optionally watch all subfolders and files.

    .PARAMETER NotifyFilter
        Change the events to listen on. By default for file name and last write.

    .PARAMETER CreatedAction
        Script block to execute, when the create-event happens. The variable
        $Event will contain all arguments and properties of the event.

    .PARAMETER ChangedAction
        Script block to execute, when the change-event happens. The variable
        $Event will contain all arguments and properties of the event.

    .PARAMETER RenamedAction
        Script block to execute, when the rename-event happens. The variable
        $Event will contain all arguments and properties of the event.

    .PARAMETER DeletedAction
        Script block to execute, when the delete-event happens. The variable
        $Event will contain all arguments and properties of the event.

    .INPUTS
        None.

    .OUTPUTS
        None

    .EXAMPLE
        PS C:\> Start-WatchPath -Path 'C:\Demo' -Filter 'file.txt' -ChangedAction { Write-Host "File changed: $($Event.SourceArgs[1].FullPath)" }
        Watch the C:\Demo\file.txt for changes and write them to the host.

    .EXAMPLE
        PS C:\> Start-WatchPath -Path 'C:\Windows' -Recurse -CreatedAction { Write-Host "File changed: $($Event.SourceArgs[1].FullPath)" }
        Watch for new files in the C:\Windows directory.

    .NOTES
        Author     : Claudio Spizzi
        License    : MIT License

    .LINK
        https://github.com/claudiospizzi/WindowsFever
#>
function Start-WatchPath
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ })]
        [System.String]
        $Path,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Filter = '*',

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]
        $Recurse,

        [Parameter(Mandatory = $false)]
        [System.IO.NotifyFilters]
        $NotifyFilter = 'FileName, LastWrite',

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ScriptBlock]
        $CreatedAction,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ScriptBlock]
        $ChangedAction,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ScriptBlock]
        $RenamedAction,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ScriptBlock]
        $DeletedAction
    )

    $ErrorActionPreference = 'Stop'

    $Path = $Path.TrimEnd('\')

    if ($null -ne (Get-EventSubscriber -SourceIdentifier "PSWatchPath|$Path|*"))
    {
        throw "File System Watcher for $Path does already exist."
    }

    # Create the file system watcher and add all required properties
    $watcher = New-Object -TypeName 'System.IO.FileSystemWatcher' -ArgumentList $Path, $Filter
    $watcher.IncludeSubdirectories = $Recurse.IsPresent
    $watcher.NotifyFilter          = $NotifyFilter

    # Register object events with provided script blocks
    if ($PSBoundParameters.Keys.Contains('CreatedAction') -and $PSCmdlet.ShouldProcess("Created event on $Path", 'Register'))
    {
        Register-ObjectEvent -InputObject $watcher -EventName 'Created' -SourceIdentifier "PSWatchPath|$Path|Created" -Action $CreatedAction
    }
    if ($PSBoundParameters.Keys.Contains('ChangedAction') -and $PSCmdlet.ShouldProcess("Changed event on $Path", 'Register'))
    {
        Register-ObjectEvent -InputObject $watcher -EventName 'Changed' -SourceIdentifier "PSWatchPath|$Path|Changed" -Action $ChangedAction
    }
    if ($PSBoundParameters.Keys.Contains('RenamedAction') -and $PSCmdlet.ShouldProcess("Renamed event on $Path", 'Register'))
    {
        Register-ObjectEvent -InputObject $watcher -EventName 'Renamed' -SourceIdentifier "PSWatchPath|$Path|Renamed" -Action $RenamedAction
    }
    if ($PSBoundParameters.Keys.Contains('DeletedAction') -and $PSCmdlet.ShouldProcess("Deleted event on $Path", 'Register'))
    {
        Register-ObjectEvent -InputObject $watcher -EventName 'Deleted' -SourceIdentifier "PSWatchPath|$Path|Deleted" -Action $DeletedAction
    }
}
