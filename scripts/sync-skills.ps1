# scripts/sync-skills.ps1
# Syncs skills from skills/{eskill,gskill,lskill} into .agents/skills/ as real directories
# Resolves the issue where Antigravity CLI (agy.exe) ignores Windows NTFS Junctions.

$ErrorActionPreference = "Stop"
$baseDir = "E:\Agents\no10-oracle"
$destDir = "$baseDir\.agents\skills"
$sourceDirs = @(
    "$baseDir\skills\eskill",
    "$baseDir\skills\gskill",
    "$baseDir\skills\lskill"
)

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

$count = 0
foreach ($src in $sourceDirs) {
    if (Test-Path $src) {
        $skillDirs = Get-ChildItem -Path $src -Directory
        foreach ($skill in $skillDirs) {
            $destSkill = Join-Path $destDir $skill.Name
            
            # If destination exists and is a Junction or ReparsePoint, remove it cleanly
            if (Test-Path $destSkill) {
                $item = Get-Item $destSkill -Force
                if ($item.LinkType -eq 'Junction' -or $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                    # Remove directory junction without deleting target files
                    [System.IO.Directory]::Delete($destSkill)
                }
            }
            
            # Copy as real directory
            Copy-Item -Path $skill.FullName -Destination $destSkill -Recurse -Force
            $count++
        }
    }
}

Write-Output "Successfully synced $count skills into $destDir as real directories."
