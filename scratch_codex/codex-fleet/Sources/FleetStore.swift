import Foundation
import Observation

// MARK: - Store (drives the menu bar)

@MainActor
@Observable
final class FleetStore {
    var accounts: [AccountSnapshot] = []
    var lastRefresh: Date?
    var isRefreshing = false

    private let discovery = AccountDiscovery()

    func refreshAll() async {
        isRefreshing = true
        defer { isRefreshing = false }

        let homes = discovery.discoverHomes()
        accounts = await withTaskGroup(of: AccountSnapshot.self, returning: [AccountSnapshot].self) { group in
            for home in homes {
                group.addTask { await AccountFetcher.fetch(codexHome: home) }
            }
            var results: [AccountSnapshot] = []
            for await snapshot in group {
                results.append(snapshot)
            }
            // Stable sort by home path
            return results.sorted { $0.home < $1.home }
        }
        lastRefresh = Date()
    }
}

// MARK: - Snapshot model

struct UsageWindowSnapshot: Sendable {
    let usedPercent: Int
    let resetsIn: String
    let resetAt: Date?
    let windowSeconds: Int      // total window length (e.g. 604800 for 7d)
    let resetAfterSeconds: Int  // seconds until next reset

    /// How many seconds have elapsed since window start
    var elapsedSeconds: Int { windowSeconds - resetAfterSeconds }

    /// Burn rate: percent per hour (nil if no elapsed time or 0% used)
    var burnPerHour: Double? {
        let elapsed = Double(elapsedSeconds)
        guard elapsed > 0, usedPercent > 0 else { return nil }
        return Double(usedPercent) / (elapsed / 3600)
    }

    /// Burn rate: percent per day
    var burnPerDay: Double? {
        guard let bph = burnPerHour else { return nil }
        return bph * 24
    }

    /// Safe daily spend rate to exactly hit 100% at reset
    var safeDailyRate: Double? {
        let remaining = Double(100 - usedPercent)
        let daysLeft = Double(resetAfterSeconds) / 86400
        guard daysLeft > 0 else { return nil }
        return remaining / daysLeft
    }

    /// Projected usage at reset time if current burn rate continues
    var projectedAtReset: Double? {
        guard let bph = burnPerHour else { return nil }
        return Double(usedPercent) + bph * (Double(resetAfterSeconds) / 3600)
    }

    /// Hours until 100% at current burn rate (nil = won't deplete)
    var hoursToDepleted: Double? {
        guard let bph = burnPerHour, bph > 0 else { return nil }
        return Double(100 - usedPercent) / bph
    }

    /// Status: SAFE, WARNING, or OVER BUDGET
    var budgetStatus: String {
        guard let burn = burnPerDay, let safe = safeDailyRate, safe > 0 else { return "—" }
        let ratio = burn / safe
        if ratio <= 1.0 { return "SAFE" }
        if ratio <= 1.5 { return "WARNING (\(String(format: "%.1f", ratio))x)" }
        return "OVER (\(String(format: "%.1f", ratio))x)"
    }
}

struct ExtraRateSnapshot: Sendable {
    let name: String
    let usedPercent: Int
    let resetsIn: String
    let weeklyUsedPercent: Int?
    let weeklyResetAfterSeconds: Int?
    let weeklyWindowSeconds: Int?
}

struct AccountSnapshot: Sendable, Identifiable {
    let id: String // home path
    let home: String
    let label: String
    let email: String
    let plan: String
    let session: UsageWindowSnapshot?
    let weekly: UsageWindowSnapshot?
    let extras: [ExtraRateSnapshot]
    let credits: Double
    let error: String?
    let fetchedAt: Date
    let tokenExpiresAt: Date?
}

// MARK: - Account discovery

struct AccountDiscovery: Sendable {
    func discoverHomes() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        var homes: [String] = []

        // Default ~/.codex
        let defaultHome = home + "/.codex"
        if FileManager.default.fileExists(atPath: defaultHome + "/auth.json") {
            homes.append(defaultHome)
        }

        // ~/.codex-* (flat naming: ~/.codex-foo)
        do {
            let entries = try FileManager.default.contentsOfDirectory(atPath: home)
            for entry in entries.sorted() {
                guard entry.hasPrefix(".codex-"), entry != ".codex" else { continue }
                let candidate = home + "/" + entry
                var isDir: ObjCBool = false
                guard FileManager.default.fileExists(atPath: candidate, isDirectory: &isDir),
                      isDir.boolValue else { continue }
                if FileManager.default.fileExists(atPath: candidate + "/auth.json") {
                    homes.append(candidate)
                }
            }
        } catch {}

        // ~/.codex-team/* (team grouping: ~/.codex-team/1, ~/.codex-team/2, ...)
        let teamDir = home + "/.codex-team"
        do {
            let entries = try FileManager.default.contentsOfDirectory(atPath: teamDir)
            for entry in entries.sorted() {
                let candidate = teamDir + "/" + entry
                var isDir: ObjCBool = false
                guard FileManager.default.fileExists(atPath: candidate, isDirectory: &isDir),
                      isDir.boolValue else { continue }
                if FileManager.default.fileExists(atPath: candidate + "/auth.json") {
                    homes.append(candidate)
                }
            }
        } catch {} // OK if ~/.codex-team doesn't exist

        return homes
    }
}
