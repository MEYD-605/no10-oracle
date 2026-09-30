#!/bin/bash
ssh -o BatchMode=yes admin@100.83.0.1 'tmux ls 2>/dev/null; ps aux | grep -i no8 | grep -v grep; ls -la ~/.gemini ~/.claude/channels 2>/dev/null'
