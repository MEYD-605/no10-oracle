import Foundation

// MARK: - Fetcher (one account at a time, fully async)

enum AccountFetcher {
    static func fetch(codexHome: String) async -> AccountSnapshot {
        let label = labelForHome(codexHome)

        do {
            var auth = try CodexAuth.load(from: codexHome)

            // Refresh token if stale (>8 days since last_refresh)
            if auth.needsRefresh {
                do {
                    auth = try await CodexAuth.refresh(auth, writeTo: codexHome)
                } catch {
                    // Non-fatal: try with existing token
                }
            }

            let tokenExpiry = auth.accessTokenExpiry
            let usage = try await CodexUsageAPI.fetchUsage(
                accessToken: auth.tokens.accessToken,
                accountId: auth.tokens.accountId
            )

            let session = usage.rateLimit.primaryWindow.map {
                UsageWindowSnapshot(
                    usedPercent: $0.usedPercent,
                    resetsIn: formatDuration($0.resetAfterSeconds),
                    resetAt: Date(timeIntervalSince1970: TimeInterval($0.resetAt)),
                    windowSeconds: $0.limitWindowSeconds,
                    resetAfterSeconds: $0.resetAfterSeconds
                )
            }

            let weekly = usage.rateLimit.secondaryWindow.map {
                UsageWindowSnapshot(
                    usedPercent: $0.usedPercent,
                    resetsIn: formatDuration($0.resetAfterSeconds),
                    resetAt: Date(timeIntervalSince1970: TimeInterval($0.resetAt)),
                    windowSeconds: $0.limitWindowSeconds,
                    resetAfterSeconds: $0.resetAfterSeconds
                )
            }

            let extras: [ExtraRateSnapshot] = (usage.additionalRateLimits ?? []).compactMap { extra in
                guard let pw = extra.rateLimit.primaryWindow else { return nil }
                return ExtraRateSnapshot(
                    name: extra.limitName,
                    usedPercent: pw.usedPercent,
                    resetsIn: formatDuration(pw.resetAfterSeconds),
                    weeklyUsedPercent: extra.rateLimit.secondaryWindow?.usedPercent,
                    weeklyResetAfterSeconds: extra.rateLimit.secondaryWindow?.resetAfterSeconds,
                    weeklyWindowSeconds: extra.rateLimit.secondaryWindow?.limitWindowSeconds
                )
            }

            let credits = Double(usage.credits.balance) ?? 0

            return AccountSnapshot(
                id: codexHome,
                home: codexHome,
                label: label,
                email: usage.email,
                plan: usage.planType,
                session: session,
                weekly: weekly,
                extras: extras,
                credits: credits,
                error: nil,
                fetchedAt: Date(),
                tokenExpiresAt: tokenExpiry
            )

        } catch {
            return AccountSnapshot(
                id: codexHome,
                home: codexHome,
                label: label,
                email: "unknown",
                plan: "?",
                session: nil,
                weekly: nil,
                extras: [],
                credits: 0,
                error: error.localizedDescription,
                fetchedAt: Date(),
                tokenExpiresAt: nil
            )
        }
    }
}

// MARK: - Helpers

func labelForHome(_ path: String) -> String {
    let base = (path as NSString).lastPathComponent
    let parent = ((path as NSString).deletingLastPathComponent as NSString).lastPathComponent

    // ~/.codex-team/1 → "team/1"
    if parent == ".codex-team" {
        return "team/\(base)"
    }
    if base == ".codex" { return "default" }
    if base.hasPrefix(".codex-") { return String(base.dropFirst(7)) }
    return base
}

func formatDuration(_ seconds: Int) -> String {
    if seconds <= 0 { return "now" }
    let d = seconds / 86400
    let h = (seconds % 86400) / 3600
    let m = (seconds % 3600) / 60
    var parts: [String] = []
    if d > 0 { parts.append("\(d)d") }
    if h > 0 { parts.append("\(h)h") }
    if m > 0 { parts.append("\(m)m") }
    return parts.isEmpty ? "<1m" : parts.joined(separator: " ")
}
