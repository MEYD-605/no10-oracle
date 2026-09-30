Write-Host "=== SCHEDULED TASKS ==="
Get-ScheduledTask -TaskName "*Joker*" | Select-Object TaskName, State, @{N='LastResult';E={$_.GetTaskInfo().LastTaskResult}} | Format-Table

Write-Host "=== JOKER PROCESSES ==="
Get-Process | Where-Object { $_.ProcessName -match "claude|node|python|joker|hermes" } | Select-Object Id, ProcessName, SessionId, CPU, WorkingSet | Format-Table

Write-Host "=== JOKER WORKSPACE (E:\Agents\joker-oracle) ==="
if (Test-Path "E:\Agents\joker-oracle") {
    Get-ChildItem -Path "E:\Agents\joker-oracle" | Select-Object Name, Length, LastWriteTime | Sort-Object LastWriteTime -Descending | Format-Table
} else {
    Write-Host "E:\Agents\joker-oracle does not exist."
}

Write-Host "=== JOKER CONSOLE PAYLOAD SCRIPT ==="
if (Test-Path "C:\Users\noone\bin\joker-console-payload.ps1") {
    Get-Content "C:\Users\noone\bin\joker-console-payload.ps1"
} else {
    Write-Host "C:\Users\noone\bin\joker-console-payload.ps1 does not exist."
}
