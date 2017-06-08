
# Watch the C:\Demo\file.txt for changes and write them to the host.
Start-WatchPath -Path 'C:\Demo' -Filter 'file.txt' -ChangedAction { $Event.SourceArgs[1].FullPath | Out-File -FilePath 'C:\Log\changed.log' }

# Stop watching on C:\Demo.
Stop-WatchPath -Path 'C:\Demo'
