import AppKit
import SwiftUI

// MARK: - App entry

@main
struct CodexFleetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environment(appDelegate.store)
        }
    }
}

// MARK: - AppDelegate (owns NSStatusItem + menu)

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = FleetStore()
    private var statusItem: NSStatusItem!
    private var refreshTimer: Timer?
    private var mascot: MascotController!
    private var api: LocalAPIServer!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Status bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "gauge.with.dots.needle.33percent", accessibilityDescription: "CodexFleet")
            button.imagePosition = .imageLeading
        }

        // Mascot overlay (starts after first fetch)
        mascot = MascotController(store: store)

        // Local HTTP API on :47780
        api = LocalAPIServer(store: store)
        api.start()

        // Initial fetch, then spawn cats
        Task {
            await store.refreshAll()
            rebuildMenu()
            mascot.show()  // spawn cats after accounts are known
        }

        // Poll every 5 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.store.refreshAll()
                self.rebuildMenu()
                self.mascot.show()  // re-sync cats (adds new, updates existing)
            }
        }
    }

    func rebuildMenu() {
        let menu = NSMenu()

        let header = NSMenuItem(title: "CodexFleet — \(store.accounts.count) account(s)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(NSMenuItem.separator())

        if store.accounts.isEmpty {
            let empty = NSMenuItem(title: "No accounts found", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
            let hint = NSMenuItem(title: "Drop auth.json into ~/.codex or ~/.codex-*", action: nil, keyEquivalent: "")
            hint.isEnabled = false
            menu.addItem(hint)
        } else {
            for snapshot in store.accounts {
                // Account header
                let label = snapshot.error != nil ? "✗" : "✓"
                let title = "\(label) [\(snapshot.label)] \(snapshot.email) — \(snapshot.plan)"
                let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                item.isEnabled = false
                menu.addItem(item)

                if let error = snapshot.error {
                    let errItem = NSMenuItem(title: "   Error: \(error)", action: nil, keyEquivalent: "")
                    errItem.isEnabled = false
                    menu.addItem(errItem)
                } else {
                    // Session window (5h cycle)
                    if let session = snapshot.session {
                        let remaining = 100 - session.usedPercent
                        let bar = usageBarText(usedPercent: session.usedPercent)
                        let item = NSMenuItem(title: "   Session  \(bar) \(remaining)% left  resets \(session.resetsIn)", action: nil, keyEquivalent: "")
                        item.isEnabled = false
                        menu.addItem(item)
                    }

                    // Weekly window (7-day) — main focus
                    if let weekly = snapshot.weekly {
                        let remaining = 100 - weekly.usedPercent
                        let bar = usageBarText(usedPercent: weekly.usedPercent)
                        let daysLeft = Double(weekly.resetAfterSeconds) / 86400

                        let resetDate = weekly.resetAt.map { formatDate($0) } ?? "?"
                        let item = NSMenuItem(title: "   7-Day    \(bar) \(remaining)% left  \(String(format: "%.1f", daysLeft))d remain", action: nil, keyEquivalent: "")
                        item.isEnabled = false
                        menu.addItem(item)

                        // Burn rate + prediction
                        if let burnDay = weekly.burnPerDay,
                           let safeRate = weekly.safeDailyRate,
                           let projected = weekly.projectedAtReset {
                            let burnItem = NSMenuItem(
                                title: "            \(String(format: "%.1f", burnDay))%/d burn · \(String(format: "%.1f", safeRate))%/d safe · \(weekly.budgetStatus)",
                                action: nil, keyEquivalent: ""
                            )
                            burnItem.isEnabled = false
                            menu.addItem(burnItem)

                            let projPct = min(Int(projected), 100)
                            if let deplete = weekly.hoursToDepleted {
                                let depleteDays = deplete / 24
                                let depleteLabel = depleteDays < 1 ? "\(Int(deplete))h" : String(format: "%.1fd", depleteDays)
                                let predItem = NSMenuItem(
                                    title: "            proj \(projPct)% by reset · depletes \(depleteLabel) · resets \(resetDate)",
                                    action: nil, keyEquivalent: ""
                                )
                                predItem.isEnabled = false
                                menu.addItem(predItem)
                            }
                        } else {
                            // No burn data yet (just started)
                            let infoItem = NSMenuItem(title: "            resets \(resetDate)", action: nil, keyEquivalent: "")
                            infoItem.isEnabled = false
                            menu.addItem(infoItem)
                        }
                    }

                    // Extra rate limits (e.g. GPT-5.3-Codex-Spark)
                    for extra in snapshot.extras {
                        let remaining = 100 - extra.usedPercent
                        let bar = usageBarText(usedPercent: extra.usedPercent)
                        let shortName = String(extra.name.split(separator: "-").last ?? Substring(extra.name))
                        let pad = shortName.padding(toLength: 8, withPad: " ", startingAt: 0)

                        var line = "   \(pad) \(bar) \(remaining)% left  resets \(extra.resetsIn)"

                        // Show weekly burn for extras too
                        if let wUsed = extra.weeklyUsedPercent {
                            line += "  [7d: \(wUsed)%]"
                        }

                        let item = NSMenuItem(title: line, action: nil, keyEquivalent: "")
                        item.isEnabled = false
                        menu.addItem(item)
                    }
                }

                menu.addItem(NSMenuItem.separator())
            }
        }

        // Summary in status bar title
        updateStatusTitle()

        // Actions
        let refreshItem = NSMenuItem(title: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        let mascotItem = NSMenuItem(title: "Toggle Mascot", action: #selector(toggleMascot), keyEquivalent: "m")
        mascotItem.target = self
        menu.addItem(mascotItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(title: "Quit CodexFleet", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func updateStatusTitle() {
        guard let button = statusItem.button else { return }

        let activeAccounts = store.accounts.filter { $0.error == nil }
        if activeAccounts.isEmpty {
            button.title = ""
            return
        }

        // Focus: worst weekly (7-day) usage across all accounts
        let worstWeekly = activeAccounts.compactMap(\.weekly).max(by: { $0.usedPercent < $1.usedPercent })
        if let worst = worstWeekly {
            let remaining = 100 - worst.usedPercent
            let daysLeft = Double(worst.resetAfterSeconds) / 86400
            button.title = " \(remaining)% · \(String(format: "%.0f", daysLeft))d"
            // Dynamic icon based on weekly remaining
            let iconName: String
            if remaining >= 75 {
                iconName = "gauge.with.dots.needle.33percent"
            } else if remaining >= 40 {
                iconName = "gauge.with.dots.needle.50percent"
            } else if remaining >= 15 {
                iconName = "gauge.with.dots.needle.67percent"
            } else {
                iconName = "gauge.with.dots.needle.100percent"
            }
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "CodexFleet")
        } else {
            // Fallback to session %
            let worstSession = activeAccounts.compactMap(\.session).max(by: { $0.usedPercent < $1.usedPercent })
            if let worst = worstSession {
                button.title = " \(100 - worst.usedPercent)%"
            } else {
                button.title = ""
            }
        }
    }

    @objc func refreshNow() {
        Task {
            await store.refreshAll()
            rebuildMenu()
        }
    }

    @objc func toggleMascot() {
        mascot.toggle()
    }

    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if #available(macOS 14, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Text bar for menu items (no color — NSMenu is plain text)

private func formatDate(_ date: Date) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "EEE HH:mm"
    fmt.timeZone = .current
    return fmt.string(from: date)
}

private func usageBarText(usedPercent: Int, width: Int = 15) -> String {
    let remaining = 100 - usedPercent
    let filled = Int(Double(remaining) / 100.0 * Double(width))
    let empty = width - filled
    return "[" + String(repeating: "■", count: filled) + String(repeating: "□", count: empty) + "]"
}
