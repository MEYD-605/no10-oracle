import Foundation
import Network

// MARK: - Embedded HTTP server (NWListener, zero dependencies)
// Serves JSON at http://localhost:47780/api/usage

@MainActor
final class LocalAPIServer {
    private var listener: NWListener?
    private let store: FleetStore
    private let port: UInt16

    init(store: FleetStore, port: UInt16 = 47780) {
        self.store = store
        self.port = port
    }

    nonisolated func start() {
        do {
            let params = NWParameters.tcp
            let listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: self.port)!)
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("[LocalAPI] listening on :\(self.port)")
                case .failed(let err):
                    print("[LocalAPI] listener failed: \(err)")
                default:
                    break
                }
            }
            listener.newConnectionHandler = { [weak self] conn in
                self?.handleConnection(conn)
            }
            listener.start(queue: .global(qos: .utility))
            Task { @MainActor in
                self.listener = listener
            }
        } catch {
            print("[LocalAPI] failed to create listener: \(error)")
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    // MARK: - Connection handling

    nonisolated private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .utility))
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] data, _, _, error in
            guard let self, let data else {
                connection.cancel()
                return
            }

            let request = String(data: data, encoding: .utf8) ?? ""
            let (method, path) = Self.parseRequestLine(request)

            Task { @MainActor in
                let response = await self.route(method: method, path: path)
                self.sendResponse(connection: connection, response: response)
            }
        }
    }

    nonisolated private func sendResponse(connection: NWConnection, response: HTTPResponse) {
        let header = """
        HTTP/1.1 \(response.status)\r
        Content-Type: \(response.contentType)\r
        Content-Length: \(response.body.count)\r
        Access-Control-Allow-Origin: *\r
        Connection: close\r
        \r\n
        """
        let payload = header.data(using: .utf8)! + response.body
        connection.send(content: payload, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    // MARK: - Router

    private func route(method: String, path: String) async -> HTTPResponse {
        switch (method, path) {
        case ("GET", "/api/usage"):
            return await usageEndpoint()
        case ("GET", "/api/stats"):
            return statsEndpoint()
        case ("GET", "/api/health"):
            return healthEndpoint()
        case ("GET", "/"):
            return indexEndpoint()
        default:
            return HTTPResponse(status: "404 Not Found", body: Data("{\"error\":\"not found\"}".utf8))
        }
    }

    // MARK: - Endpoints

    /// GET /api/usage — full account data with burn rate predictions
    private func usageEndpoint() async -> HTTPResponse {
        // Refresh if stale (> 60s)
        if let last = store.lastRefresh, Date().timeIntervalSince(last) > 60 {
            await store.refreshAll()
        } else if store.lastRefresh == nil {
            await store.refreshAll()
        }

        var accounts: [[String: Any]] = []
        for acct in store.accounts {
            var dict: [String: Any] = [
                "label": acct.label,
                "email": acct.email,
                "plan": acct.plan,
                "home": acct.home,
                "credits": acct.credits,
                "fetched_at": ISO8601DateFormatter().string(from: acct.fetchedAt),
            ]

            if let err = acct.error {
                dict["error"] = err
            }

            if let exp = acct.tokenExpiresAt {
                dict["token_expires_at"] = ISO8601DateFormatter().string(from: exp)
            }

            if let session = acct.session {
                dict["session"] = windowDict(session, label: "session")
            }

            if let weekly = acct.weekly {
                dict["weekly"] = windowDict(weekly, label: "weekly")
            }

            if !acct.extras.isEmpty {
                dict["extras"] = acct.extras.map { extra -> [String: Any] in
                    var d: [String: Any] = [
                        "name": extra.name,
                        "used_percent": extra.usedPercent,
                        "resets_in": extra.resetsIn,
                    ]
                    if let wp = extra.weeklyUsedPercent { d["weekly_used_percent"] = wp }
                    return d
                }
            }

            accounts.append(dict)
        }

        let payload: [String: Any] = [
            "accounts": accounts,
            "count": store.accounts.count,
            "active": store.accounts.filter { $0.error == nil }.count,
            "refreshed_at": store.lastRefresh.map { ISO8601DateFormatter().string(from: $0) } ?? NSNull(),
        ]

        return jsonResponse(payload)
    }

    /// GET /api/stats — summary numbers for widgets
    private func statsEndpoint() -> HTTPResponse {
        let active = store.accounts.filter { $0.error == nil }
        let worstWeekly = active.compactMap(\.weekly).max(by: { $0.usedPercent < $1.usedPercent })

        var stats: [String: Any] = [
            "accounts": store.accounts.count,
            "active": active.count,
            "errors": store.accounts.count - active.count,
        ]

        if let w = worstWeekly {
            stats["worst_weekly_used"] = w.usedPercent
            stats["worst_weekly_remaining"] = 100 - w.usedPercent
            stats["worst_weekly_days_left"] = Double(w.resetAfterSeconds) / 86400
            if let burn = w.burnPerDay { stats["worst_burn_per_day"] = burn }
            if let safe = w.safeDailyRate { stats["worst_safe_per_day"] = safe }
            stats["worst_budget_status"] = w.budgetStatus
        }

        return jsonResponse(stats)
    }

    /// GET /api/health
    private func healthEndpoint() -> HTTPResponse {
        return jsonResponse(["status": "ok", "port": Int(port), "pid": ProcessInfo.processInfo.processIdentifier])
    }

    /// GET /
    private func indexEndpoint() -> HTTPResponse {
        let html = """
        <!doctype html>
        <html><head><title>CodexFleet</title></head>
        <body style="font-family:monospace;background:#111;color:#eee;padding:2em">
        <h2>CodexFleet API</h2>
        <ul>
        <li><a href="/api/usage">/api/usage</a> — full account data + predictions</li>
        <li><a href="/api/stats">/api/stats</a> — summary numbers for widgets</li>
        <li><a href="/api/health">/api/health</a> — health check</li>
        </ul>
        </body></html>
        """
        return HTTPResponse(status: "200 OK", contentType: "text/html; charset=utf-8", body: Data(html.utf8))
    }

    // MARK: - Helpers

    private func windowDict(_ w: UsageWindowSnapshot, label: String) -> [String: Any] {
        var d: [String: Any] = [
            "used_percent": w.usedPercent,
            "remaining_percent": 100 - w.usedPercent,
            "resets_in": w.resetsIn,
            "window_seconds": w.windowSeconds,
            "reset_after_seconds": w.resetAfterSeconds,
            "elapsed_seconds": w.elapsedSeconds,
        ]
        if let resetAt = w.resetAt {
            d["reset_at"] = ISO8601DateFormatter().string(from: resetAt)
        }
        if let burn = w.burnPerDay { d["burn_per_day"] = round(burn * 10) / 10 }
        if let safe = w.safeDailyRate { d["safe_per_day"] = round(safe * 10) / 10 }
        if let proj = w.projectedAtReset { d["projected_at_reset"] = min(Int(proj), 100) }
        if let dep = w.hoursToDepleted { d["hours_to_depleted"] = round(dep * 10) / 10 }
        d["budget_status"] = w.budgetStatus
        return d
    }

    private func jsonResponse(_ dict: [String: Any]) -> HTTPResponse {
        let data = (try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])) ?? Data("{}".utf8)
        return HTTPResponse(status: "200 OK", body: data)
    }

    nonisolated static func parseRequestLine(_ raw: String) -> (method: String, path: String) {
        let firstLine = raw.split(separator: "\r\n", maxSplits: 1).first ?? ""
        let parts = firstLine.split(separator: " ")
        guard parts.count >= 2 else { return ("GET", "/") }
        // Strip query string
        let fullPath = String(parts[1])
        let path = fullPath.split(separator: "?", maxSplits: 1).first.map(String.init) ?? fullPath
        return (String(parts[0]), path)
    }
}

// MARK: - Response model

struct HTTPResponse: Sendable {
    let status: String
    let contentType: String
    let body: Data

    init(status: String, contentType: String = "application/json", body: Data) {
        self.status = status
        self.contentType = contentType
        self.body = body
    }
}
