#!/bin/bash
# Oracle voice bot launcher for No.10 — MIMO TTS. Reboot-durable (token from discord-no10/.env).
# Usage: bash /root/maw-workspace/scripts/run-voice-bot-no10.sh
cd /root/Code/github.com/MEYD-605/oracle-voice-bot || exit 1
export DISCORD_BOT_TOKEN="$(grep -oE 'DISCORD_BOT_TOKEN=[^ ]+' /root/.claude/channels/discord-no10/.env | cut -d= -f2)"
export MIMO_API_KEY="$(grep -oE 'api_key: tp-[a-z0-9]+' /root/.hermes-no7/config.yaml | head -1 | awk '{print $2}')"
export MIMO_VOICE="${MIMO_VOICE:-mimo_default}"
export VOICE_CHANNEL_ID="${VOICE_CHANNEL_ID:-1410301190092099637}"
export BOT_PERSONA="No.10 X — Backend Dev & Ops"
export THINK_BRIDGE_AGENT="no10"
export SILENCE_MS="800"
export VOICE_OWNER_GATE="0"
export SPEAK_QUEUE_DIR="/tmp/no10-speak-queue"
export VOICE_TCP_PORT="49912"
exec /root/.bun/bin/bun run src/index.ts 2>&1 | tee /tmp/voice-bot-no10.log
