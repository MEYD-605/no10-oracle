# Hosting apps as background daemons on ClubSGame

## Recipe (Node/bun app from a zip)
1. Inspect first: `unzip -l`, read README, package.json, grep outbound hosts (`https?://...` sorted by count) and `child_process|eval|new Function` outside tests. Report to Bo what it is before running anything.
2. Port check (see SKILL.md) — never start a second copy next to a sibling's; take it over only when Bo assigns it, then stop the sibling's process and tell that agent.
3. Install to `C:\Users\ClubSGame\apps\<name>` (not /tmp, not scratch). `npm ci --no-audit --no-fund`; Playwright apps also need `npx playwright install chromium`.
4. Launcher `.cmd` (quoted heredoc or write_file, never printf/sed): `cd /d` to the app, `set HOST=` / `set PORT=`, absolute node path `C:\Users\ClubSGame\AppData\Local\hermes\tools\node-*\node.exe`, output `>> <app>\<name>.log 2>&1` (a visible console can freeze the event loop — same failure as the 8056 bridge).
5. Scheduled task: principal `SYSTEM` / ServiceAccount / Highest, `AtStartup` with `Delay=PT2M`, `ExecutionTimeLimit 0`, RestartCount 3 / 1 min, battery flags off. (`New-ScheduledTaskPrincipal -UserId ClubSGame -LogonType S4U` is rejected with "The parameter is incorrect".) Running as SYSTEM changes the profile, so set `PLAYWRIGHT_BROWSERS_PATH=C:\Users\ClubSGame\AppData\Local\ms-playwright` in the .cmd or browser launches fail.
6. Verify: task Running, exactly one listener on the port, HTTP 200 on the bound address, tail the log, report RAM.
7. Remote access: bind `HOST=100.87.51.122` (Tailscale) — then 127.0.0.1 no longer answers, so probe the Tailscale IP.

## Finn Bot Fleet (Ragnarok bot panel)
- Targets the private web server Finn-RO (`auction-finn-ragnarok.com`, roBrowser) — NOT the official Thai client in `C:\Program Files (x86)\Gravity Game Tech\RagnarokOnline` (GameGuard). Say so if Bo means "use it with my installed Ragnarok".
- Lives at `C:\Users\ClubSGame\apps\finn-bot-fleet`, entry `panel/fleet-server.js`, task `Finn-Bot-Fleet`, panel `http://100.87.51.122:8791`, log `finn-fleet.log`. Runtime data in `panel/data/`, accounts in `panel/bots.json`.
- Shared zips arrive with blank credentials (`user`/`pass` empty) → "Manager login failed; retry within 60s" is expected until Bo enters his own account in the UI. Never type the game password yourself.
- `panel/data/universal-warper-catalog.json` is `require()`d directly by `killer-control-service.js` and `wizard-pk-warper.js`; if the store quarantined it to `.corrupt-*` the server crashes with MODULE_NOT_FOUND. Regenerate a valid empty catalog from `initialCatalog()` in `universal-warper-store.js` (load the file source with an appended export, write JSON), don't hand-write it.
- "IPv6 pool empty / provision-ipv6.sh / en0" log lines are Mac-deployment leftovers; harmless for 1–2 bots on the home IP.
