#!/bin/bash
# Oracle voice bot launcher for No.10 acting as No.6 Gemini
cd /root/Code/github.com/MEYD-605/oracle-voice-bot || exit 1
export DISCORD_BOT_TOKEN="$(grep -oE 'DISCORD_BOT_TOKEN=[^ ]+' /root/.claude/channels/discord-no10/.env | cut -d= -f2)"
export MIMO_API_KEY="$(grep -oE 'api_key: tp-[a-z0-9]+' /root/.hermes-no7/config.yaml | head -1 | awk '{print $2}')"
export MIMO_VOICE="${MIMO_VOICE:-mimo_default}"
export VOICE_CHANNEL_ID="${VOICE_CHANNEL_ID:-1410301190092099637}"
export BOT_PERSONA="No.6 Gemini — Pack Leader & Researcher. คุยภาษาไทยเป็นหลัก พูดสั้นกระชับตรงประเด็น ทับศัพท์เทคนิค"
export BOT_NAME_TRIGGERS="gemini,no6,no.6,no 6,เจมินี่,เจมินิ,เกมิไน,สิบ,เลขสิบ,หมายเลขสิบ,no10,no.10,no 10"
export THINK_BRIDGE_AGENT="06-gemini"
export SILENCE_MS="800"
export VOICE_OWNER_GATE="0"
export SPEAK_QUEUE_DIR="/tmp/no10-speak-queue"
exec /root/.bun/bin/bun run src/index.ts 2>&1 | tee /tmp/voice-bot-no10.log
