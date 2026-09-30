$t = Get-ScheduledTask -TaskName 'JokerConsole'
Write-Host "Action:" ($t.Actions | Format-List | Out-String)
Write-Host "Principal:" ($t.Principal | Format-List | Out-String)
