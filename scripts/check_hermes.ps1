if (Test-Path "C:\Users\noone\.hermes") {
    Get-ChildItem -Path "C:\Users\noone\.hermes" | Select-Object Name, Length, LastWriteTime
}
if (Test-Path "$env:USERPROFILE\.hermes") {
    Get-ChildItem -Path "$env:USERPROFILE\.hermes" | Select-Object Name, Length, LastWriteTime
}
# Also check if there's any hermes config in AppData
Get-ChildItem -Path "$env:LOCALAPPDATA\hermes" -Recurse -Depth 2 | Select-Object FullName
