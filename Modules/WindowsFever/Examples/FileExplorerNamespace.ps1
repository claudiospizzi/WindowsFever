
# Get all file explorer namespaces for the current user
Get-FileExplorerNamespace

# Create a complex Workspace file explorer namespace by specified every parameter including a specific icon
Add-FileExplorerNamespace -Name 'Workspace' -Icon '%SystemRoot%\System32\imageres.dll,156' -TargetFolderPath "$HOME\Workspace" -Order 67

# Create a complex PowerShell file explorer namespace by specified every parameter including a specific icon
Add-FileExplorerNamespace -Name 'PowerShell' -Icon '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe,0' -TargetFolderPath "$HOME\Dropbox\PowerShell" -Order 65

# Remove the file explorer namespace with the name 'Test'
Get-FileExplorerNamespace -Name 'Test' | Remove-FileExplorerNamespace
