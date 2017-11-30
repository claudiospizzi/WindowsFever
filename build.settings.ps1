
Properties {

    $ModuleNames = 'WindowsFever'

    $GalleryEnabled = $true
    $GalleryKey     = Get-VaultSecureString -TargetName 'PS-SecureString-GalleryKey'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'claudiospizzi/WindowsFever'
    $GitHubToken    = Get-VaultSecureString -TargetName 'PS-SecureString-GitHubToken'
}
