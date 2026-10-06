# Claude Code CLI Background Tool Timeouts & Prompt Queue Stalling

## Background
In Claude Code CLI (v2.1+), long-running commands (such as inter-agent pings, synchronous bash commands, or cross-node sync calls) executed by an agent can time out after 120s:
`Command did not complete within its 120s timeout and was moved to the background (ID: <task_id>). Output is being written to: /private/tmp/claude-.../tasks/<task_id>.output.`

## The Queue Block Trap
When Claude CLI moves a tool to the background, it registers an asynchronous task listener. If inbound Discord messages or queued prompt commands arrive while:
1. Claude is waiting on background task resolution, or
2. A subsequent background task notification is enqueued, or
3. Claude CLI enters an interactive prompt (`❯ `) without automatically dequeuing the backlog:

The pending user messages stay trapped in the internal JSONL transcript under `type: "queue-operation", operation: "enqueue"` and are **not processed until a carriage return (`Enter`) or explicit prompt stimulus is injected into the tmux pane**.

## Diagnostic Signs
1. User reports: "ถามไปตั้งนานแล้วไม่ตอบ" / "บอทยังไม่ตอบเลย"
2. Transcript inspection (`~/.claude/projects/.../<session_id>.jsonl`):
   - Multiple `queue-operation` `enqueue` events present without corresponding assistant turn generation.
   - Background task completion/killed notifications (`task-notification`) sitting at the tail of the session.
3. Pane capture (`tmux capture-pane -pt <seat>:0`):
   - Shows idle prompt `❯ ` without "Clauding..." animation.

## Resolution & Unblocking Procedure
1. Inspect the live pane: `tmux capture-pane -pt <seat>:0 -S -30`
2. If the prompt is idle `❯ ` despite pending Discord questions in the queue:
   - Send an explicit stimulus or send-keys Enter to wake the queue processing:
     `tmux send-keys -t <seat> "<Prompt text or Enter>" Enter`
3. Verify with live pane capture that Claude CLI transitions to `⏺ Running` / `✳ Clauding…`
4. Confirm response delivery via Discord channel logs or live trace.
