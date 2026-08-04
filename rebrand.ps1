$workspace = "d:\BASE NOVA"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Starting FDB Rebranding Process" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Rename directories
Write-Host "`n1. Renaming rsg-* directories to fdb-*..." -ForegroundColor Yellow
$dirs = Get-ChildItem -Path $workspace -Directory -Filter "rsg-*" -Exclude "rsgcore_original*"
foreach ($dir in $dirs) {
    $newName = $dir.Name -replace "^rsg-", "fdb-"
    Write-Host ("Renaming " + $dir.Name + " -> " + $newName)
    Rename-Item -Path $dir.FullName -NewName $newName
}

# 2. Text replacements in all text files (excluding .git and specific files)
Write-Host "`n2. Replacing text contents..." -ForegroundColor Yellow

$excludeDirs = @(".git", ".github", "node_modules", "tmp", "_clone_tmp")
$includeExts = @("*.lua", "*.js", "*.html", "*.json", "*.yaml", "*.cfg", "*.css", "*.sql", "*.md")

$files = Get-ChildItem -Path $workspace -Recurse -Include $includeExts | Where-Object {
    $path = $_.FullName
    $skip = $false
    foreach ($ex in $excludeDirs) {
        if ($path -match "\\$ex\\") { $skip = $true; break }
    }
    if ($path -match "rsgcore_original") { $skip = $true }
    if ($path -match "server_original") { $skip = $true }
    if ($path -match "implementation_plan.md") { $skip = $true }
    if ($path -match "task.md") { $skip = $true }
    if ($path -match "clone_rsg.ps1") { $skip = $true }
    if ($path -match "rebrand.ps1") { $skip = $true }
    -not $skip
}

$totalFiles = $files.Count
$counter = 0

foreach ($file in $files) {
    $counter++
    if ($counter % 100 -eq 0) {
        Write-Host "  Processing file $counter of $totalFiles..." -ForegroundColor Gray
    }

    try {
        $content = Get-Content $file.FullName -Raw
        if ($null -ne $content) {
            $originalContent = $content
            
            # Map of replacements
            # Case-sensitive exact replacements
            $content = $content -creplace "RSGCore", "FDBCore"
            
            # Case-insensitive replacements
            $content = $content -replace "rsg-core", "fdb-core"
            $content = $content -replace "rsgcore", "fdbcore"
            $content = $content -replace "rsg_locale", "fdb_locale"
            $content = $content -replace "rsg_horses", "fdb_horses" # the DB table
            
            # Global catch-all for all other rsg-* resources
            # This uses a regex to match rsg-(anything) where anything is a word
            # Example: rsg-inventory -> fdb-inventory
            $content = [System.Text.RegularExpressions.Regex]::Replace($content, "(?i)rsg-([a-z]+)", "fdb-`$1")
            
            # And specific locale checks: 'rsg_' -> 'fdb_' just in case some scripts use rsg_something
            # We already did rsg_locale and rsg_horses, but let's do a general one for SQL variables if they exist
            # However, a blind rsg_ -> fdb_ might break some standard things, so let's stick to the specific ones above + rsg-

            if ($originalContent -cne $content) {
                # File needs updating
                Set-Content -Path $file.FullName -Value $content -NoNewline
                # Write-Host "    Modified: $($file.FullName)"
            }
        }
    } catch {
        Write-Host "  Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Rebranding Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
