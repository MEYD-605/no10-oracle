Write-Host "=== DISCORD RELAY / BOTS ==="
Get-Process | Where-Object { $_.ProcessName -match "node|python|hermes|agy|claude" } | ForEach-Object {
    $proc = $_
    $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
    [PSCustomObject]@{
        Id = $proc.Id
        Name = $proc.ProcessName
        SessionId = $proc.SessionId
        CommandLine = $cmd
    }
} | Format-List

Write-Host "=== JOKER FOLDER IN APPDATA OR .claude ==="
if (Test-Path "E:\Agents\joker-oracle\.claude") {
    Get-ChildItem -Path "E:\Agents\joker-oracle\.claude" -Recurse | Select-Object FullName, LastWriteTime | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | Format-Table
}

Write-Host "=== JOKER IN WSL? ==="
wsl.exe -l -v
