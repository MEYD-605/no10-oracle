# Hermes Gateway WebSocket Silent Disconnect Recipe

## Incident Symptom
User reports bot is silent or unresponsive ("หลอน").
- `ps aux` shows `python -m hermes_cli.main gateway run` is alive (0% CPU).
- tmux pane (`116-gmaicore` or seat window) shows active shell prompt.
- Discord UI shows bot online or idle, but inbound DMs/mentions yield no response.

## Root Cause Analysis
Discord Gateway WebSocket connection was closed by remote host or network flicker (`socket_closed`).
The Hermes Discord adapter logs:
`WARNING hermes_plugins.discord_platform.adapter: [Discord] Discord Gateway WebSocket unhealthy (socket_closed, 1/2)`
The main Python process stays alive without crashing, but fails to auto-reconnect to the Discord Gateway, keeping stale sockets in `CLOSE-WAIT` (e.g. to local 9router at `127.0.0.1:20128`).

## Verification Commands
1. Check process PID and uptime:
   `ssh <host> "ps -eo pid,etime,cmd | grep hermes_cli.main"`
2. Inspect log tail for WebSocket health warnings:
   `ssh <host> "tail -50 ~/.hermes-<seat>/logs/gateway.log | grep -iE 'WebSocket|unhealthy|Connected'"`
3. Verify socket connection states:
   `ssh <host> "ss -tnp | grep <pid>"`
4. Verify log activity over time:
   `ssh <host> "wc -l ~/.hermes-<seat>/logs/gateway.log"` (re-check after 15s to confirm log growth has stopped).

## Remediation
Restart the gateway process:
- Linux / systemd or manual daemon:
  `ssh <host> "kill <pid>"` (supervisor will respawn, or manually start)
- macOS seat gateway:
  `open /path/to/restart.command` or `launchctl kickstart -k gui/$(id -u)/ai.hermes.gateway-<seat>`
