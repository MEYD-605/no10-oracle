#!/bin/bash
export HOME="/root"
export PATH="/root/.local/bin:/usr/local/bin:/usr/bin:/bin"
cd /mnt/e/Agents/no10-oracle
exec /root/.local/bin/agy \
  --model gemini-3.8-flash-high \
  --dangerously-skip-permissions \
  --add-dir /root/.gemini \
  --add-dir /mnt/e/Agents/no10-oracle \
  --add-dir /mnt/e/Agents/no10-oracle/ψ \
  --add-dir /mnt/e/Agents
