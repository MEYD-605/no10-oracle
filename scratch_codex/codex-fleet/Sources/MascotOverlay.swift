import AppKit
import SwiftUI

// MARK: - Fleet mascot manager — one cat per account

@MainActor
final class MascotController {
    private let store: FleetStore
    private var cats: [String: CatPetController] = [:]  // keyed by account home path
    private var syncTimer: Timer?
    private var isVisible = true

    init(store: FleetStore) {
        self.store = store
    }

    func show() {
        isVisible = true
        syncCats()
        // Re-sync cats with accounts every 10s
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.syncCats() }
        }
    }

    func hide() {
        isVisible = false
        syncTimer?.invalidate()
        syncTimer = nil
        for cat in cats.values { cat.hide() }
        cats.removeAll()
    }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    /// Sync cats with current account list — add new, remove stale
    private func syncCats() {
        guard isVisible else { return }
        let currentAccounts = store.accounts

        // Remove cats for accounts that no longer exist
        let liveIds = Set(currentAccounts.map(\.id))
        for (id, cat) in cats where !liveIds.contains(id) {
            cat.hide()
            cats.removeValue(forKey: id)
        }

        // Add cats for new accounts
        for (index, account) in currentAccounts.enumerated() {
            if cats[account.id] == nil {
                let cat = CatPetController(account: account, spawnIndex: index)
                cat.show()
                cats[account.id] = cat
            } else {
                // Update existing cat's account data
                cats[account.id]?.updateAccount(account)
            }
        }
    }
}

// MARK: - Individual cat pet controller

@MainActor
final class CatPetController {
    private var panel: NSPanel?
    private var account: AccountSnapshot
    private let spawnIndex: Int

    // Movement state
    private var posX: CGFloat = 0
    private var posY: CGFloat = 0
    private var velocityX: CGFloat = 0
    private var state: PetState = .walking
    private var stateTicksRemaining: Int = 0
    private var jumpVelocityY: CGFloat = 0
    private var groundY: CGFloat = 0
    private var dragCooldown: Int = 0

    private var walkTimer: Timer?
    let petModel = PetModel()

    private let petWidth: CGFloat = 140
    private let petHeight: CGFloat = 180

    init(account: AccountSnapshot, spawnIndex: Int) {
        self.account = account
        self.spawnIndex = spawnIndex
    }

    func updateAccount(_ account: AccountSnapshot) {
        self.account = account
        petModel.mood = computeMood()
        petModel.label = account.label
        petModel.weeklyRemaining = account.weekly.map { 100 - $0.usedPercent }
        petModel.budgetStatus = account.weekly?.budgetStatus
        petModel.timeLeft = account.weekly.map { Self.smartTimeLeft($0.resetAfterSeconds) }
    }

    /// Smart time formatting: "6d" / "23h" / "45m" / "< 1m"
    static func smartTimeLeft(_ seconds: Int) -> String {
        if seconds <= 0 { return "now" }
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60

        if days >= 2 { return "\(days)d" }                          // 2d, 3d, ...
        if days == 1 { return "1d \(hours)h" }                      // 1d 5h
        if hours >= 1 { return "\(hours)h" }                        // 23h, 2h
        if minutes >= 1 { return "\(minutes)m" }                    // 45m, 10m
        return "< 1m"
    }

    func show() {
        guard panel == nil else { return }

        let view = SingleCatView(model: petModel, onDismiss: { [weak self] in self?.hide() })
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: petWidth, height: petHeight)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: petWidth, height: petHeight),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = false
        panel.contentView = hostingView

        // Spread spawn positions across the screen
        if let screen = NSScreen.main {
            let vis = screen.visibleFrame
            groundY = vis.minY
            let spacing = vis.width / 5
            posX = vis.minX + spacing * CGFloat(spawnIndex + 1)
            posY = groundY
            panel.setFrameOrigin(NSPoint(x: posX, y: posY))
        }

        // Initialize model
        petModel.label = account.label
        petModel.mood = computeMood()
        petModel.weeklyRemaining = account.weekly.map { 100 - $0.usedPercent }
        petModel.budgetStatus = account.weekly?.budgetStatus
        petModel.timeLeft = account.weekly.map { Self.smartTimeLeft($0.resetAfterSeconds) }

        // Random initial direction
        let speed = CGFloat.random(in: 0.6...1.8)
        velocityX = Bool.random() ? speed : -speed
        petModel.facingRight = velocityX > 0
        stateTicksRemaining = Int.random(in: 100...300)

        panel.orderFront(nil)
        self.panel = panel

        // 30fps walk loop
        walkTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func hide() {
        walkTimer?.invalidate()
        walkTimer = nil
        panel?.orderOut(nil)
        panel = nil
    }

    // MARK: - Tick

    private func tick() {
        guard let panel, let screen = NSScreen.main else { return }
        let vis = screen.visibleFrame

        // Detect drag
        let origin = panel.frame.origin
        if abs(origin.x - posX) > 2 || abs(origin.y - posY) > 2 {
            posX = origin.x
            posY = origin.y
            groundY = posY
            dragCooldown = 90
            state = .idle
            petModel.currentState = .idle
        }

        if dragCooldown > 0 {
            dragCooldown -= 1
            petModel.animFrame = (petModel.animFrame + 1) % 120
            return
        }

        stateTicksRemaining -= 1
        if stateTicksRemaining <= 0 { transitionState() }

        switch state {
        case .walking:
            posX += velocityX
            if posX <= vis.minX + 5 {
                posX = vis.minX + 5
                velocityX = abs(velocityX)
                petModel.facingRight = true
            } else if posX >= vis.maxX - petWidth - 5 {
                posX = vis.maxX - petWidth - 5
                velocityX = -abs(velocityX)
                petModel.facingRight = false
            }
            petModel.animFrame = (petModel.animFrame + 1) % 120
            petModel.currentState = .walking

        case .idle:
            petModel.animFrame = (petModel.animFrame + 1) % 120
            petModel.currentState = .idle

        case .jumping:
            posX += velocityX * 0.7
            posY += jumpVelocityY
            jumpVelocityY -= 0.8
            if posY <= groundY {
                posY = groundY
                state = .walking
                stateTicksRemaining = Int.random(in: 90...200)
            }
            petModel.currentState = .jumping

        case .sitting:
            petModel.animFrame = (petModel.animFrame + 1) % 120
            petModel.currentState = .sitting

        case .sleeping:
            petModel.animFrame = (petModel.animFrame + 1) % 120
            petModel.currentState = .sleeping
        }

        panel.setFrameOrigin(NSPoint(x: posX, y: posY))
    }

    private func transitionState() {
        let roll = Int.random(in: 0...100)
        let used = account.weekly?.usedPercent ?? 0

        if roll < 45 {
            state = .walking
            stateTicksRemaining = Int.random(in: 120...350)
            let speed = CGFloat.random(in: 0.6...1.8)
            velocityX = petModel.facingRight ? speed : -speed
        } else if roll < 65 {
            state = .idle
            stateTicksRemaining = Int.random(in: 60...150)
        } else if roll < 78 {
            state = .jumping
            stateTicksRemaining = 999
            jumpVelocityY = CGFloat.random(in: 5...9)
        } else if roll < 90 {
            state = .sitting
            stateTicksRemaining = Int.random(in: 90...250)
        } else {
            if used < 50 {
                state = .sleeping
                stateTicksRemaining = Int.random(in: 150...300)
            } else {
                // Too stressed to sleep — pace
                state = .walking
                stateTicksRemaining = Int.random(in: 90...180)
                velocityX = petModel.facingRight ? 2.0 : -2.0
            }
        }
    }

    private func computeMood() -> PetMood {
        guard account.error == nil, let weekly = account.weekly else { return .unknown }
        let used = weekly.usedPercent
        let ratio: Double = {
            guard let b = weekly.burnPerDay, let s = weekly.safeDailyRate, s > 0 else { return 0 }
            return b / s
        }()

        if used >= 90 { return .panic }
        if ratio > 2.5 { return .stressed }
        if used >= 70 { return .worried }
        if ratio > 1.5 { return .concerned }
        if used >= 40 { return .neutral }
        return .happy
    }
}

// MARK: - Shared observable for a single cat

@MainActor
@Observable
final class PetModel {
    var currentState: PetState = .idle
    var mood: PetMood = .happy
    var facingRight: Bool = true
    var animFrame: Int = 0
    var label: String = ""
    var weeklyRemaining: Int? = nil
    var budgetStatus: String? = nil
    var timeLeft: String? = nil     // "6d", "23h", "45m", etc.
}

enum PetState: String { case walking, idle, jumping, sitting, sleeping }
enum PetMood: String { case happy, neutral, concerned, worried, stressed, panic, unknown }

// MARK: - Single cat SwiftUI view (one per account)

struct SingleCatView: View {
    let model: PetModel
    let onDismiss: () -> Void
    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 0) {
            // Name tag + usage (always visible)
            nameTag
                .padding(.bottom, 2)

            // Speech bubble on hover
            if isHovering {
                hoverBubble
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .padding(.bottom, 2)
            }

            // Cat sprite
            CatSprite(state: model.currentState, mood: model.mood, frame: model.animFrame)
                .frame(width: 70, height: 70)
                .scaleEffect(x: model.facingRight ? 1 : -1, y: 1)
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
        }
        .frame(width: 140, height: 180, alignment: .bottom)
        .onHover { h in
            withAnimation(.easeInOut(duration: 0.2)) { isHovering = h }
        }
        .contextMenu {
            Button("Hide Cat") { onDismiss() }
        }
    }

    private var nameTag: some View {
        HStack(spacing: 3) {
            Text(model.label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if let pct = model.weeklyRemaining {
                Text("\(pct)%")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundStyle(pct < 20 ? .red : pct < 50 ? .orange : .green)
            }
            if let time = model.timeLeft {
                Text(time)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Capsule().fill(.black.opacity(0.5)))
    }

    @ViewBuilder
    private var hoverBubble: some View {
        VStack(spacing: 1) {
            if let status = model.budgetStatus {
                Text(status)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(statusColor(status))
            }
            if let pct = model.weeklyRemaining, let time = model.timeLeft {
                Text("\(pct)% left · \(time)")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }

    private func statusColor(_ status: String) -> Color {
        if status.contains("SAFE") { return .green }
        if status.contains("WARNING") { return .yellow }
        if status.contains("OVER") { return .orange }
        return .secondary
    }
}

// MARK: - Triangle shape for speech bubble tail

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX - rect.width / 2, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX + rect.width / 2, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
