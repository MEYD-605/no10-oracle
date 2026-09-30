import { readFileSync, existsSync } from "fs";

// Load configuration from environment or .env files
function loadEnv() {
  const envPaths = [
    "E:\\Agents\\no10-oracle\\.env",
    "C:\\Users\\noone\\.claude\\channels\\discord-no10\\.env"
  ];
  const env: Record<string, string> = { ...process.env as Record<string, string> };
  for (const p of envPaths) {
    if (existsSync(p)) {
      try {
        const lines = readFileSync(p, "utf8").split("\n");
        for (const line of lines) {
          const m = line.match(/^([A-Za-z0-9_]+)=(.*)$/);
          if (m && !env[m[1]]) {
            env[m[1]] = m[2].trim().replace(/^["']|["']$/g, "");
          }
        }
      } catch {}
    }
  }
  return env;
}

const env = loadEnv();
const HASS_URL = (env.HASS_URL || "http://127.0.0.1:80").replace(/\/+$/, "");
const HASS_TOKEN = env.HASS_TOKEN || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5ZWQzZmQ3NTdmM2I0Y2Y1ODc2NGZlYzA2YzVkMzAwOCIsImlhdCI6MTc5MDA5MjQzNSwiZXhwIjoyMTA1NDUyNDM1fQ.hHrJb-5mnWJJTTxQzSNvGP7Vi9kjgNQVhCHVQQL6ejk";
const ARRA_URL = (env.ARRA_MEMORY_URL || "http://127.0.0.1:8099/mcp").replace(/\/+$/, "");
const ARRA_TOKEN = env.ARRA_MEMORY_TOKEN || "bf9e86e0f371b0eeabf11de20677cb34b38abfec7113a10be8ffb4981965da14";
const ARRA_BASE_URL = ARRA_URL.replace(/\/mcp\/?$/, "");

const [cmd, ...args] = process.argv.slice(2);

async function hassFetch(path: string, options: RequestInit = {}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 4000);
  try {
    const res = await fetch(`${HASS_URL}${path}`, {
      ...options,
      signal: controller.signal,
      headers: {
        Authorization: `Bearer ${HASS_TOKEN}`,
        "Content-Type": "application/json",
        ...(options.headers || {})
      }
    });
    if (!res.ok) {
      const err = await res.text();
      throw new Error(`HAOS HTTP ${res.status}: ${err}`);
    }
    return res.json();
  } finally {
    clearTimeout(timeout);
  }
}

const CENTRAL_ARRA_URL = (env.CENTRAL_ARRA_URL || "http://100.83.0.1:8099/mcp").replace(/\/+$/, "");
const CENTRAL_ARRA_TOKEN = env.CENTRAL_ARRA_TOKEN || ARRA_TOKEN;

async function arraMcpCall(method: string, params: any) {
  const tryCall = async (url: string, token: string, timeoutMs: number) => {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const res = await fetch(url, {
        method: "POST",
        signal: controller.signal,
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: Date.now(),
          method,
          params
        })
      });
      if (!res.ok) {
        const err = await res.text();
        throw new Error(`HTTP ${res.status}: ${err}`);
      }
      const json: any = await res.json();
      if (json.error) {
        throw new Error(`RPC Error: ${json.error.message || JSON.stringify(json.error)}`);
      }
      return json.result;
    } finally {
      clearTimeout(timeout);
    }
  };

  try {
    return await tryCall(ARRA_URL, ARRA_TOKEN, 4000);
  } catch (err: any) {
    // Failover to Central MacLab Arra Memory
    try {
      return await tryCall(CENTRAL_ARRA_URL, CENTRAL_ARRA_TOKEN, 6000);
    } catch (err2: any) {
      throw new Error(`Arra Memory dual-failover failed (Local: ${err.message}, Central: ${err2.message})`);
    }
  }
}

async function main() {
  switch (cmd) {
    case "status": {
      console.log(`Connecting to HAOS at ${HASS_URL}...`);
      const [apiStatus, config, arraHealth] = await Promise.all([
        hassFetch("/api/").catch(e => ({ error: e.message })),
        hassFetch("/api/config").catch(e => ({ error: e.message })),
        fetch(`${ARRA_BASE_URL}/api/health`, {
          headers: { Authorization: `Bearer ${ARRA_TOKEN}` },
          signal: AbortSignal.timeout(4000)
        }).then(r => r.json()).catch(e => ({ error: e.message }))
      ]);

      console.log(JSON.stringify({
        haos_core: {
          url: HASS_URL,
          api: apiStatus,
          version: config?.version,
          state: config?.state,
          location: config?.location_name,
          time_zone: config?.time_zone
        },
        arra_memory: {
          url: ARRA_BASE_URL,
          health: arraHealth
        }
      }, null, 2));
      break;
    }

    case "states":
    case "list": {
      const domainFilter = args[0];
      const states: any[] = await hassFetch("/api/states");
      const filtered = domainFilter
        ? states.filter(s => s.entity_id.startsWith(`${domainFilter}.`))
        : states;
      console.log(JSON.stringify(filtered.map(s => ({
        entity_id: s.entity_id,
        state: s.state,
        friendly_name: s.attributes?.friendly_name,
        last_changed: s.last_changed
      })), null, 2));
      break;
    }

    case "get": {
      const entityId = args[0];
      if (!entityId) {
        console.error("Usage: haos get <entity_id>");
        process.exit(1);
      }
      const state = await hassFetch(`/api/states/${entityId}`);
      console.log(JSON.stringify(state, null, 2));
      break;
    }

    case "call": {
      const [domain, service] = (args[0] || "").split(".");
      let payload = {};
      if (args[1]) {
        try {
          payload = JSON.parse(args[1]);
        } catch {
          console.error("Error: payload must be valid JSON");
          process.exit(1);
        }
      }
      if (!domain || !service) {
        console.error("Usage: haos call <domain.service> [json_payload]");
        process.exit(1);
      }
      const result = await hassFetch(`/api/services/${domain}/${service}`, {
        method: "POST",
        body: JSON.stringify(payload)
      });
      console.log(JSON.stringify(result, null, 2));
      break;
    }

    case "memory": {
      const sub = args[0];
      if (sub === "stats") {
        const stats = await arraMcpCall("tools/call", { name: "memory_stats", arguments: {} });
        console.log(stats?.content?.[0]?.text || JSON.stringify(stats, null, 2));
      } else if (sub === "search") {
        const query = args.slice(1).join(" ");
        if (!query) {
          console.error("Usage: haos memory search <query>");
          process.exit(1);
        }
        const res = await arraMcpCall("tools/call", { name: "recall_memories", arguments: { query, mode: "keyword" } });
        console.log(res?.content?.[0]?.text || JSON.stringify(res, null, 2));
      } else if (sub === "remember") {
        const title = args[1];
        const content = args.slice(2).join(" ");
        if (!title || !content) {
          console.error("Usage: haos memory remember <title> <content>");
          process.exit(1);
        }
        const res = await arraMcpCall("tools/call", {
          name: "remember",
          arguments: {
            title,
            content,
            kind: "note",
            tags: ["no10", "oracle"],
            importance: 4,
            project: "no10-oracle",
            workspace: "oracle-fleet",
            createdBy: "no10-oracle"
          }
        });
        console.log(res?.content?.[0]?.text || JSON.stringify(res, null, 2));
      } else {
        console.error("Usage: haos memory [stats|search|remember]");
      }
      break;
    }

    default: {
      console.log(`HAOS CLI for Oracle No.10 X
Usage:
  haos status                       Check connection to HAOS and Arra Memory
  haos list [domain]                List entities (e.g. haos list sensor)
  haos get <entity_id>              Get entity state & attributes
  haos call <domain.service> [json] Call HA service (e.g. haos call light.turn_on '{"entity_id":"light.living"}')
  haos memory stats                 Get Arra Memory stats on HAOS
  haos memory search <query>        Search Arra Memory on HAOS
  haos memory remember <title> <text> Save memory to Arra Memory on HAOS
`);
    }
  }
}

main().catch(err => {
  console.error("Error:", err.message);
  process.exit(1);
});
