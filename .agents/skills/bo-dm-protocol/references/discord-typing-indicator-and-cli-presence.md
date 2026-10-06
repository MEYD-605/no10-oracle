# Discord Typing Indicator & Headless CLI Presence Pattern

## Overview
When orchestrating headless CLI agents (e.g. Claude Code CLI, Grok CLI, OpenCode) in tmux with Discord gateway relays (`presence.js` / `discord-fleet-router.ts`), there is a latency gap (5–30s) while the LLM reasons and executes tool calls.

Without active typing indicators, the mobile and desktop Discord UI shows no visual feedback, making users perceive the bot as dead, hung, or ignoring them ("ทำไมมันยังไม่ตอบ").

## The Discord Typing API Specification
- **Endpoint**: `POST https://discord.com/api/v10/channels/{channel_id}/typing`
- **Headers**:
  - `Authorization: Bot <BOT_TOKEN>`
  - `User-Agent: DiscordBot (<URL>, <VERSION>)`
- **TTL**: Discord's typing indicator automatically disappears after **9–10 seconds** unless refreshed.

## Implementation Pattern in Node / Bun WebSocket Gateways

```javascript
// Function to fire Discord typing indicator
async function sendTyping(channelId, token) {
  try {
    await fetch(`https://discord.com/api/v10/channels/${channelId}/typing`, {
      method: 'POST',
      headers: {
        'Authorization': `Bot ${token}`,
        'User-Agent': 'DiscordBot (https://github.com/MEYD-605, 1.0)'
      }
    });
  } catch (e) {
    // Non-blocking catch
  }
}

// In WebSocket message handler:
if (msg.t === 'MESSAGE_CREATE') {
  const m = msg.d;
  if (m.author.bot) return;

  // 1. Immediately trigger typing indicator on Discord
  await sendTyping(m.channel_id, token);

  // 2. Keep typing indicator alive every 8s (bounded, e.g. up to 24-32s) while agent thinks
  let count = 0;
  const typingTimer = setInterval(async () => {
    count++;
    if (count > 3) { // 8s * 4 = 32s safety cap
      clearInterval(typingTimer);
      return;
    }
    await sendTyping(m.channel_id, token);
  }, 8000);

  // 3. Dispatch to agent session (e.g. maw hey or tmux send-keys)
  const formatted = `Discord DM จาก ${m.author.username}: ${m.content} | chat_id: ${m.channel_id}`;
  spawnSync('maw', ['hey', targetAgent, formatted], { timeout: 10000 });
}
```

## Key Proof Points
1. **Immediate Reaction**: Trigger `sendTyping` before or concurrently with `maw hey` dispatch.
2. **Periodic Refresh**: Interval must be <= 8000ms to prevent the indicator from dropping out before the agent replies.
3. **Safety Cap**: Always bound `setInterval` (e.g. max 3–4 iterations) to prevent indefinite typing status if the agent crashes or encounters an unhandled exception.
