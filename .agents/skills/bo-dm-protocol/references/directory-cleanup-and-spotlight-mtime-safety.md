# Disk & Directory Deletion Safety: Spotlight `.metadata_never_index` Mtime Trap & Active Process Verification

## 1. The Spotlight `.metadata_never_index` Mtime Trap
When inspecting candidate directories for deletion (e.g. `~/.hermes-*-tui`), checking raw directory `mtime` (e.g. `ls -la` or `stat`) can be completely misleading on macOS:
- Background services like Spotlight indexing create or touch `.metadata_never_index` files inside subdirectories, updating directory mtime to "just now" (e.g. `00:06 Today`).
- If you rely solely on top-level mtime, you will falsely believe a stale directory is actively being written to by a live process.
- **Rule**: Always filter out `.metadata_never_index` and inspect real payload timestamps (`sessions/`, `state.db`, `config.yaml`) to determine actual last-use time:
  ```python
  real_files = [os.path.join(root, f) for root, _, files in os.walk(path) for f in files if f != ".metadata_never_index"]
  latest_mtime = max((os.path.getmtime(f) for f in real_files), default=0)
  ```

## 2. Process Environment Probe Before Directory Deletion
Never assume a directory is unused based on size or absence of `config.yaml` alone.
- Example: `~/.hermes-mimo` was only 4KB with no `config.yaml`, appearing like an empty skeleton directory.
- However, probing process environments revealed:
  ```bash
  ps -axo pid= | while read p; do ps eww $p 2>/dev/null | tr ' ' '\n' | grep -q 'HERMES_HOME=/Users/admin/.hermes-mimo$' && echo $p; done
  ```
  Processes `84832` (`sshx-server :3457` / Oracle Workboard), `84835` (`sshx` client), and `59548` (`ssh clubslab`) were actively using `.hermes-mimo` as their working runtime. Deleting it would have destroyed the live Oracle Board!

## 3. Safe Directory Deletion Protocol
Before executing `rm -rf` / `shutil.rmtree` on any `~/.<name>` profile directory:
1. **Inspect Active Process `HERMES_HOME` / CWD**: Scan all running processes with `ps eww` and `lsof +D <dir>`.
2. **Check LaunchAgents & Crontab References**: Search `/Library/LaunchAgents`, `~/Library/LaunchAgents`, and `crontab -l` for references.
3. **Filter `.metadata_never_index` for Payload Mtime**: Ensure actual data files are stale.
4. **Delete Permanently without Stashing**: When user orders cleanup ("ลบของเก่าเลย"), delete completely once verified — do not leave `.bak` copies.
