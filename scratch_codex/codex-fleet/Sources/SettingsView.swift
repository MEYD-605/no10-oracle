import SwiftUI

struct SettingsView: View {
    @Environment(FleetStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CodexFleet")
                .font(.title2.bold())

            GroupBox("Discovered Accounts") {
                if store.accounts.isEmpty {
                    Text("No accounts found.\nDrop auth.json into ~/.codex or ~/.codex-<name>/")
                        .foregroundStyle(.secondary)
                        .padding(8)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.accounts) { snap in
                            HStack {
                                Image(systemName: snap.error == nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(snap.error == nil ? .green : .red)

                                VStack(alignment: .leading) {
                                    Text("[\(snap.label)] \(snap.email)")
                                        .font(.body.monospaced())
                                    Text(snap.home)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(snap.plan)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.blue.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(8)
                }
            }

            GroupBox("How to add accounts") {
                Text("""
                1. Create a directory: mkdir ~/.codex-<name>
                2. Login: CODEX_HOME=~/.codex-<name> codex
                3. Restart CodexFleet — it auto-discovers ~/.codex-*
                """)
                .font(.callout.monospaced())
                .padding(8)
            }

            HStack {
                Spacer()
                Button("Refresh Now") {
                    Task { await store.refreshAll() }
                }
                .keyboardShortcut("r")
            }
        }
        .padding(20)
        .frame(width: 500)
    }
}
