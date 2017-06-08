
# Watch the C:\Demo\file.txt for changes and write them to the host.
Start-WatchPath -Path 'C:\Demo' -Filter 'file.txt' -ChangedAction { Write-Host "File changed: $($Event.SourceArgs[1].FullPath)" }

# Stop watching on C:\Demo.
Stop-WatchPath -Path 'C:\Demo'
