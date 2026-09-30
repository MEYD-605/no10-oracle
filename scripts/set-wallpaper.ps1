param (
    [string]$ImagePath = "C:\wallpaper\bo_joker_wallpaper.jpg"
)

if (-not (Test-Path $ImagePath)) {
    Write-Error "File not found: $ImagePath"
    exit 1
}

$resolvedPath = (Resolve-Path $ImagePath).Path

# Set Registry
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -Value $resolvedPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value "0"

$signature = @'
using System;
using System.Runtime.InteropServices;

public class Win32WallpaperHelper {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfoW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uAction, uint uParam, string lpvParam, uint fuWinIni);
}
'@

try {
    Add-Type -TypeDefinition $signature -ErrorAction Stop
} catch {
    # Type might already be added in session
}

$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02
$flags = $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE

$success = [Win32WallpaperHelper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $resolvedPath, $flags)
$lastError = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()

Write-Host "SetWallpaper Result: $success (Win32Error: $lastError)"

# Also update TranscodedWallpaper in AppData if needed
$transcodedPath = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
try {
    Copy-Item -Path $resolvedPath -Destination $transcodedPath -Force -ErrorAction SilentlyContinue
} catch {}
