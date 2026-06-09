# Plan: Agy Auto-recovery + Weekly Auto-cleanup

**Created**: 2026-06-09 13:25 GMT+7
**Type**: Implementation Plan

## Context
- Recent commit: `332afcd` (auto: pre-reset save (session-policy daily))
- Related files:
  - [/root/maw-workspace/scripts/agy-watchdog.sh](file:///root/maw-workspace/scripts/agy-watchdog.sh) (Current watchdog for process/prompt hangs)
  - [/root/maw-workspace/scripts/session-policy.sh](file:///root/maw-workspace/scripts/session-policy.sh) (Current session lifecycle/reset manager)

## Problem
1. **Silent Terminal/Context Hangs**: AGY terminal sessions occasionally freeze or hang (sometimes due to stdout buffer or terminal blockage) and require an `Enter` keystroke to unblock. We need a way to automatically detect these silent freezes and try to unblock them before executing a full session restart.
2. **Disk and Sandbox Accumulation Bloat**: Inactive conversation SQLite databases (`.db` files) and CLI log files accumulate over time, taking up gigabytes of space (e.g., `/root/.no10-home/` has 1.1GB of files, with some individual databases reaching 700MB+). Under the `Nothing is Deleted` principle, we cannot simply delete them, but we must compress and archive them to save disk space and prevent config-bloat crashes.

## Solution
1. **Auto-recovery Enhancements**:
   - Create a detection mechanism in `agy-watchdog.sh` (or a separate monitoring loop) that checks if the active log file (linked via `cli.log` -> `log/cli-*.log`) has not been updated/written to for more than 5 minutes while the `agy` process is running.
   - If a silent hang is suspected (log idle time > 5 mins), send an `Enter` key using `tmux send-keys -t "$session" Enter` to unblock the pane.
   - If the log remains idle for another 5 minutes, proceed with a clean process restart (kill and respawn) as a fallback.
2. **Weekly Auto-cleanup**:
   - Develop a script `/root/maw-workspace/scripts/agy-cleanup.sh` that runs weekly (or can be triggered manually).
   - The script will iterate through all AGY home directories: `/root/.no6-home`, `/root/.no8-home`, and `/root/.no10-home`.
   - For each home directory, it will:
     - Check the open databases using `lsof` or `fuser` to see if they are active.
     - Move any inactive `.db` files older than 24 hours to `/root/ψ/archive/conversations/[home_name]/` and compress them using `gzip` (reducing size by ~70%).
     - Delete stray `-wal` and `-shm` files of closed databases.
     - Compress old logs (`*.log`) older than 7 days in `log/` directory.
     - Clear temporary worktrees under `worktrees/` directory that belong to closed sessions.
3. **Integration**:
   - Register the cleanup script in `/root/maw-workspace/scripts/session-policy.sh` or cron.

## Steps
1. [x] **Research and Verification**: Verify tmux active sessions and `lsof` tool compatibility across LXC containers.
2. [x] **Develop Cleanup Script (`agy-cleanup.sh`)**: Implement database detection, archiving, and compression. Test on inactive test databases.
3. [x] **Update Watchdog (`agy-watchdog.sh`)**: Implement idle log checking and tmux unblocking via `Enter` send-keys.
4. [x] **Integration & Cron Job**: Setup cron entry for weekly cleanup execution.

## Files
- `/root/maw-workspace/scripts/agy-cleanup.sh` - New script to compress and archive inactive databases and logs.
- `/root/maw-workspace/scripts/agy-watchdog.sh` - Enhanced watchdog to detect silent hangs and send unblock keys.

---
🤖 **Antigravity** (planner)
