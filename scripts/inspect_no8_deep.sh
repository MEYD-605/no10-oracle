#!/bin/bash
ssh -o BatchMode=yes admin@100.83.0.1 '
echo "=== NO8 WORKSPACE ==="
ls -la /Users/admin/Code/github.com/MEYD-605/agy-nano2-oracle

echo "=== NO8 START SCRIPT / PM2 ==="
pm2 list 2>/dev/null || true
cat /Users/admin/Code/github.com/MEYD-605/agy-nano2-oracle/start*.sh 2>/dev/null || true
cat /Users/admin/Code/github.com/MEYD-605/agy-nano2-oracle/run*.sh 2>/dev/null || true

echo "=== NO8 DISCORD CHANNEL CONFIG ==="
ls -la /Users/admin/.no8-home/.claude/channels/discord-no8 2>/dev/null || ls -la /Users/admin/.claude/channels/discord-no8 2>/dev/null

echo "=== NO8 SETTINGS / MCP ==="
cat /Users/admin/Code/github.com/MEYD-605/agy-nano2-oracle/.mcp.json 2>/dev/null || true
cat /Users/admin/.no8-home/.gemini/settings.json 2>/dev/null || true
'
