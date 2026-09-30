Write-Host "=== JOKER SOUL.md ==="
if (Test-Path "E:\Agents\joker-oracle\SOUL.md") {
    Get-Content "E:\Agents\joker-oracle\SOUL.md"
}

Write-Host "=== JOKER GIT LOG (Last 5) ==="
Set-Location "E:\Agents\joker-oracle"
git log -n 5 --oneline

Write-Host "=== JOKER RECENT ACTIVITY LOG ==="
$act = Get-ChildItem -Path "E:\Agents\joker-oracle" -Filter "*activity.log*" -Recurse
if ($act) {
    Get-Content $act[0].FullName -Tail 20
} else {
    Write-Host "No activity log found."
}
