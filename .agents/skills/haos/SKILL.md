---
name: haos
description: Interact with Home Assistant OS (HAOS) and local Arra Memory fleet registry on ClubSGame (localhost / 100.87.51.122). Query device states, call automation services, inspect updates, and query or record shared Oracle memories.
---

# HAOS & Arra Memory Skill

This skill enables No.10 X to manage and interact with Home Assistant OS and the Oracle Arra Memory corpus running on the local host/VM network.

## Network Endpoints
* **HAOS Core / REST API**: `http://127.0.0.1:80` (or `http://100.87.51.122:80`)
* **Arra Memory (Add-on)**: `http://127.0.0.1:8099` (MCP at `/mcp`)
* **Mosquitto MQTT**: `127.0.0.1:1883` (or `100.87.51.122:1883`)

## CLI Commands (`rtk haos ...`)
Always use the `haos` tool via `rtk`:

```bash
# Check connectivity & health of both HAOS Core and Arra Memory
rtk haos status

# List entities (optionally filtered by domain like sensor, light, update, switch)
rtk haos list
rtk haos list update
rtk haos list sensor

# Get detailed state and attributes of a specific entity
rtk haos get update.arra_memory_update
rtk haos get sun.sun

# Call a service on Home Assistant
rtk haos call light.turn_on '{"entity_id": "light.living_room"}'

# Arra Memory operations
rtk haos memory stats
rtk haos memory search "your query"
rtk haos memory remember "Title" "Content text to store in shared memory"
```
