# Find bo_joker_wallpaper.jpg dynamically to avoid Unicode encoding mismatch
$files = Get-ChildItem -Path "E:\Agents\no10-oracle" -Filter "*bo_joker_wallpaper.jpg" -Recurse
if ($files.Count -eq 0) {
    Write-Error "bo_joker_wallpaper.jpg not found!"
    exit 1
}

$sourceFile = $files[0].FullName
Write-Host "Found source: $sourceFile"

# Destination paths
$targetPng = "C:\wallpaper\wallpaper.png"
$targetJpg = "C:\wallpaper\wallpaper.jpg"

if (Test-Path $targetPng) {
    Copy-Item $targetPng "$targetPng.bak" -Force
}

# Convert & Save as PNG & JPG
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($sourceFile)
$img.Save($targetPng, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Save($targetJpg, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$img.Dispose()

Write-Host "Successfully saved to $targetPng and $targetJpg"

# Copy to TranscodedWallpaper for active user sessions
$transcodedPaths = @(
    "C:\Users\ClubSGame\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper",
    "C:\Users\noone\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"
)

foreach ($tp in $transcodedPaths) {
    $parentDir = Split-Path $tp
    if (Test-Path $parentDir) {
        Copy-Item $targetPng $tp -Force
        Write-Host "Overwrote $tp"
    }
}

# Update Current User Registry
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -Value $targetPng
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name TileWallpaper -Value "0"

# Also update registry of S-1-5-21... (ClubSGame user SID if found in HKU)
$userSIDs = Get-ChildItem "Registry::HKEY_USERS" | Where-Object { $_.Name -match 'S-1-5-21-' -and $_.Name -notmatch '_Classes' }
foreach ($sid in $userSIDs) {
    $sidPath = "Registry::$($sid.Name)\Control Panel\Desktop"
    if (Test-Path $sidPath) {
        Set-ItemProperty -Path $sidPath -Name Wallpaper -Value $targetPng -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $sidPath -Name WallpaperStyle -Value "10" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $sidPath -Name TileWallpaper -Value "0" -ErrorAction SilentlyContinue
        Write-Host "Updated registry for SID: $($sid.Name)"
    }
}

# Win32 notify refresh
$code = @"
using System;
using System.Runtime.InteropServices;
public class Win32WP {
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfoW", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uAction, uint uParam, string lpvParam, uint fuWinIni);
}
"@
try {
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
} catch {}

[Win32WP]::SystemParametersInfo(0x0014, 0, $targetPng, 0x01 -bor 0x02)

Write-Host "Wallpaper update script complete!"
