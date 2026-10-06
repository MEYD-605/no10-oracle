# Hermes 9router Custom Provider Configuration & Diagnostics

## Overview
When Hermes is configured to route LLM requests through a local `9router` instance (e.g. `http://127.0.0.1:20128/v1`), specific configuration rules must be followed to avoid `Provider authentication failed` or `The model provider failed after retries` errors in Discord DMs / channels.

## Correct `config.yaml` Structure for Custom 9router Endpoint

```yaml
model:
  default: ag/gemini-3.6-flash-high
  provider: custom
  base_url: http://127.0.0.1:20128/v1

custom_providers:
  - name: custom
    base_url: http://127.0.0.1:20128/v1
    type: openai

fallback_providers:
  - model: ag/gemini-3.6-flash-high
    provider: custom
  - model: cc/claude-sonnet-5
    provider: custom
```

## Failure Modes & Diagnostic Steps

1. **`Provider authentication failed` / `Unknown provider '9router'`**:
   - Cause: `provider` set to `9router` without registering it in `custom_providers`, or `custom_providers` specified as a dict instead of a YAML list (`- name: ...`).
   - Fix: Ensure `custom_providers` is a list, and `provider` matches a known provider or `custom`.

2. **`9router` process not listening on port 20128**:
   - Cause: `9router` service stopped or crashed.
   - Probe: `curl -sS http://127.0.0.1:20128/v1/models`
   - Fix: Restart 9router in tmux or daemon mode (`9router start` or tmux session).

3. **Discord DM Error Cards**:
   - When a provider failure occurs, Hermes Gateway returns:
     > ⚠️ `The model provider failed after retries. I kept raw provider details out of chat; check gateway logs for diagnostics.`
   - Check `~/.hermes-<profile>/logs/gateway.log` for exact python traceback / HTTP status codes before asserting provider health.
