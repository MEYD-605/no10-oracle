$tasks = Get-ScheduledTask
foreach ($t in $tasks) {
    $u = $t.Principal.UserId
    if ($u -and $u -notmatch 'SYSTEM|LOCAL SERVICE|NETWORK SERVICE|INTERACTIVE|Users') {
        Write-Host "Task: $($t.TaskName), User: $u, LogonType: $($t.Principal.LogonType)"
    }
}
