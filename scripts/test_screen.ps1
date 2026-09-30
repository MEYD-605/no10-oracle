Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$screens = [System.Windows.Forms.Screen]::AllScreens
Write-Host "Screens found: $($screens.Count)"
foreach ($s in $screens) {
    Write-Host "Screen: $($s.DeviceName), Bounds: $($s.Bounds)"
}
