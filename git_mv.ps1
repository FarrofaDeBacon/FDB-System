$workspace = "d:\BASE NOVA"
cd $workspace

$dirs = Get-ChildItem -Directory -Filter "rsg-*" -Exclude "rsgcore_original*"
foreach ($dir in $dirs) {
    $newName = $dir.Name -replace "^rsg-", "fdb-"
    Write-Host "git mv $($dir.Name) $newName"
    git mv $dir.Name $newName
}
