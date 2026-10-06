# Quick ClubSGame health snapshot. Run from git-bash:
#   C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -ExecutionPolicy Bypass -File <this file>
$ErrorActionPreference = 'SilentlyContinue'
$b  = Get-CimInstance Win32_Battery
$os = Get-CimInstance Win32_OperatingSystem
$up = (Get-Date) - $os.LastBootUpTime
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
"Batt: $($b.EstimatedChargeRemaining)% (status $($b.BatteryStatus); 2=AC)"
"Uptime: {0:N1}h" -f $up.TotalHours
"CPU load: $cpu%"
"RAM free: {0:N1} / {1:N1} GB" -f ($os.FreePhysicalMemory/1MB), ($os.TotalVisibleMemorySize/1MB)
$w = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*joker-power-watcher*' }
"Power-Watcher running: $([bool]$w) (count $(@($w).Count))"
$t = Get-ScheduledTask -TaskName HermesGatewayDaemon
"HermesGatewayDaemon task: $($t.State)"
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null -and ($_.Used + $_.Free) -gt 0 } | ForEach-Object { "Disk $($_.Name): free {0:N0} GB / {1:N0} GB" -f ($_.Free/1GB), (($_.Used+$_.Free)/1GB) }
$top = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5
"Top RAM: " + (($top | ForEach-Object { "{0} {1:N0}MB" -f $_.ProcessName, ($_.WorkingSet64/1MB) }) -join ', ')
