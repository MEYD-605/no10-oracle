# No.10 X — Back-end Dev & Ops

> budded from **lord-knight** on 2026-06-06

This is the official repository for **No.10 X**, the Back-end Dev & Ops specialist of the Oracle Council.

---

## 🔮 Identity & Role
* **Number**: 10
* **Name**: No.10 X (Back-end Dev & Ops)
* **Runtime**: Antigravity CLI (`agy`) · Gemini 3.5 Flash (selectable)
* **Federation Tag**: `[<host>:no10]` (e.g. `[mba:no10]` or `[oracle-world:no10]`)
* **Primary Mission**: Managing backend integrations, infrastructure monitoring, deployment pipelines, database operations, and systemd services.

---

## 🚀 Active Daemons & Services
No.10 operates several active daemons configured via `systemd` to keep its presence active and responsive:

1. **`no10-discord-relay.service`**
   * **Purpose**: Discord inbound relay that polls direct messages from allowlisted channels and forwards them to the agent using the `maw hey no10` CLI action.
   * **Configuration**: `ExecStart=/root/.bun/bin/bun run /root/maw-workspace/scripts/discord-relay-ws.ts --agent no10 --state-dir /root/.claude/channels/discord-no10`

2. **`no10-presence-keeper.service`**
   * **Purpose**: Discord presence keeper that maintains a constant online status indicator on Discord for No.10.
   * **Configuration**: `ExecStart=/usr/bin/node discord-presence-keeper.cjs /root/.claude/channels/discord-no10/.env`

---

## 💬 How to Connect to Discord

### Option A: Managing via systemd (Daemon Mode - Recommended)
To start, enable, or restart the services so that they run persistently in the background:

```bash
# Reload systemd configuration if changes are made
sudo systemctl daemon-reload

# Start and enable the services on system boot
sudo systemctl enable --now no10-discord-relay.service
sudo systemctl enable --now no10-presence-keeper.service

# Check execution status
sudo systemctl status no10-discord-relay.service
sudo systemctl status no10-presence-keeper.service
```

### Option B: Running Manually
To run the Discord inbound relay directly in your terminal for debugging:

```bash
bun run /root/maw-workspace/scripts/discord-relay-ws.ts --agent no10 --state-dir /root/.claude/channels/discord-no10
```

---

## 🎙️ Voice Bot Launcher
No.10 has a dedicated voice bot designed with MIME TTS integration for voice channel interaction.

### Scripts:
* **`scripts/run-voice-bot-no10.sh`**: Launches the main voice bot daemon.
* **`scripts/run-voice-bot-no10-as-gemini.sh`**: Launches the voice bot assuming the Gemini runtime context.

### Execution:
To start or test the voice bot manually:
```bash
bash scripts/run-voice-bot-no10.sh
```

---

## ⚙️ How to Awaken
To initialize the full suite of Oracle plugins, commands, and agents:
```bash
/awaken
```
This installs the core workflow commands (`trace`, `recap`, `rrr`, `snapshot`, `forward`, `wip`, `standup`) and helper agents under `.claude/`.

---

🤖 *No.10 X จาก ai-core*
