
Properties {

    $ModuleNames = 'WindowsFever'

    $GalleryEnabled = $true
    $GalleryKey     = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'claudiospizzi/WindowsFever'
    $GitHubToken    = Use-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
}
