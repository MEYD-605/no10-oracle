import SwiftUI

// MARK: - Cat sprite drawn with Canvas — walk, sit, sleep, jump animations

struct CatSprite: View {
    let state: PetState
    let mood: PetMood
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height

            let bodyColor = catColor
            let darkColor = bodyColor.opacity(0.7)

            // Animation phase
            let phase = Double(frame)
            let walkCycle = sin(phase * 0.3)        // leg swing
            let breathe = sin(phase * 0.1) * 1.5    // idle breathing
            let bobY: CGFloat

            switch state {
            case .walking: bobY = CGFloat(sin(phase * 0.3) * 2)
            case .jumping: bobY = -8
            case .sitting: bobY = 6
            case .sleeping: bobY = 8
            case .idle: bobY = CGFloat(breathe)
            }

            let cx = w * 0.5   // center x
            let baseY = h * 0.78 + bobY  // body center y

            // ── Tail ──
            drawTail(ctx: ctx, cx: cx, baseY: baseY, w: w, color: bodyColor, phase: phase)

            // ── Back legs ──
            let legExtend: CGFloat = state == .walking ? CGFloat(walkCycle * 6) : 0
            let legExtendBack: CGFloat = state == .walking ? CGFloat(-walkCycle * 6) : 0

            // Back-left leg
            drawLeg(ctx: ctx, x: cx - 10, baseY: baseY + 8, extend: legExtendBack, color: darkColor)
            // Back-right leg
            drawLeg(ctx: ctx, x: cx + 10, baseY: baseY + 8, extend: legExtend, color: darkColor)

            // ── Body (ellipse) ──
            let bodyW: CGFloat
            let bodyH: CGFloat

            switch state {
            case .sitting, .sleeping:
                bodyW = 34; bodyH = 22
            default:
                bodyW = 38; bodyH = 20
            }

            let bodyRect = CGRect(x: cx - bodyW/2, y: baseY - bodyH/2, width: bodyW, height: bodyH)
            ctx.fill(Ellipse().path(in: bodyRect), with: .color(bodyColor))

            // ── Front legs ──
            drawLeg(ctx: ctx, x: cx - 12, baseY: baseY + 8, extend: legExtend, color: bodyColor)
            drawLeg(ctx: ctx, x: cx + 8, baseY: baseY + 8, extend: legExtendBack, color: bodyColor)

            // ── Paws (little circles at feet) ──
            if state != .sleeping {
                let pawY = baseY + 18 + (state == .sitting ? -4 : 0)
                let pawR: CGFloat = 3
                let frontLeftPawX = cx - 12 + (state == .walking ? legExtend * 0.3 : 0)
                let frontRightPawX = cx + 8 + (state == .walking ? legExtendBack * 0.3 : 0)

                ctx.fill(Circle().path(in: CGRect(x: frontLeftPawX - pawR, y: pawY - pawR, width: pawR*2, height: pawR*2)), with: .color(Color.pink.opacity(0.6)))
                ctx.fill(Circle().path(in: CGRect(x: frontRightPawX - pawR, y: pawY - pawR, width: pawR*2, height: pawR*2)), with: .color(Color.pink.opacity(0.6)))
            }

            // ── Head ──
            let headY = baseY - bodyH/2 - 10 + (state == .sleeping ? 10 : 0)
            let headSize: CGFloat = 26
            let headRect = CGRect(x: cx - headSize/2, y: headY - headSize/2, width: headSize, height: headSize)
            ctx.fill(RoundedRectangle(cornerRadius: 8).path(in: headRect), with: .color(bodyColor))

            // ── Ears (triangles) ──
            drawEar(ctx: ctx, tipX: cx - 10, tipY: headY - headSize/2 - 6, baseX1: cx - 15, baseX2: cx - 5, baseY: headY - headSize/2 + 2, outerColor: bodyColor, innerColor: Color.pink.opacity(0.4))
            drawEar(ctx: ctx, tipX: cx + 10, tipY: headY - headSize/2 - 6, baseX1: cx + 5, baseX2: cx + 15, baseY: headY - headSize/2 + 2, outerColor: bodyColor, innerColor: Color.pink.opacity(0.4))

            // ── Eyes ──
            let eyeY = headY - 1
            let eyeSpacing: CGFloat = 7

            switch state {
            case .sleeping:
                // Closed eyes (lines)
                drawClosedEye(ctx: ctx, x: cx - eyeSpacing, y: eyeY)
                drawClosedEye(ctx: ctx, x: cx + eyeSpacing, y: eyeY)
            default:
                // Open eyes — mood affects shape
                let eyeW: CGFloat = 5
                let eyeH: CGFloat = mood == .panic ? 7 : 5
                let pupilSize: CGFloat = mood == .stressed ? 1.5 : 2.5

                // White
                ctx.fill(Ellipse().path(in: CGRect(x: cx - eyeSpacing - eyeW/2, y: eyeY - eyeH/2, width: eyeW, height: eyeH)), with: .color(.white))
                ctx.fill(Ellipse().path(in: CGRect(x: cx + eyeSpacing - eyeW/2, y: eyeY - eyeH/2, width: eyeW, height: eyeH)), with: .color(.white))

                // Pupils
                let pupilOffsetX: CGFloat = mood == .worried ? -0.5 : 0
                ctx.fill(Circle().path(in: CGRect(x: cx - eyeSpacing - pupilSize/2 + pupilOffsetX, y: eyeY - pupilSize/2, width: pupilSize, height: pupilSize)), with: .color(.black))
                ctx.fill(Circle().path(in: CGRect(x: cx + eyeSpacing - pupilSize/2 + pupilOffsetX, y: eyeY - pupilSize/2, width: pupilSize, height: pupilSize)), with: .color(.black))

                // Blink every ~4s
                if (frame / 30) % 8 == 0 && frame % 30 < 4 {
                    // Blink: draw half-lid
                    ctx.fill(Ellipse().path(in: CGRect(x: cx - eyeSpacing - eyeW/2, y: eyeY - eyeH/2, width: eyeW, height: eyeH/2)), with: .color(bodyColor))
                    ctx.fill(Ellipse().path(in: CGRect(x: cx + eyeSpacing - eyeW/2, y: eyeY - eyeH/2, width: eyeW, height: eyeH/2)), with: .color(bodyColor))
                }
            }

            // ── Nose + mouth ──
            let noseY = eyeY + 5
            ctx.fill(Ellipse().path(in: CGRect(x: cx - 1.5, y: noseY, width: 3, height: 2)), with: .color(Color.pink))

            // Whiskers
            if state != .sleeping {
                drawWhiskers(ctx: ctx, cx: cx, y: noseY + 1, color: darkColor)
            }

            // ── Mood indicator ──
            if mood == .panic {
                // Sweat drop
                ctx.fill(Circle().path(in: CGRect(x: cx + headSize/2 + 2, y: headY - 4, width: 4, height: 5)), with: .color(Color.cyan.opacity(0.7)))
            }
            if mood == .stressed || mood == .worried {
                // Sweat
                let sweatY = headY - headSize/2 + CGFloat(sin(phase * 0.15) * 3)
                ctx.fill(Ellipse().path(in: CGRect(x: cx + headSize/2, y: sweatY, width: 3, height: 4)), with: .color(Color.cyan.opacity(0.5)))
            }

            // ── "Zzz" for sleeping ──
            if state == .sleeping {
                let zOffset = CGFloat(sin(phase * 0.08) * 3)
                let zStr = "z"
                ctx.draw(Text(zStr).font(.system(size: 10, weight: .bold)).foregroundColor(.white.opacity(0.6)), at: CGPoint(x: cx + 18, y: headY - 16 + zOffset))
                ctx.draw(Text("z").font(.system(size: 8, weight: .bold)).foregroundColor(.white.opacity(0.4)), at: CGPoint(x: cx + 24, y: headY - 24 + zOffset * 0.7))
                ctx.draw(Text("z").font(.system(size: 6, weight: .bold)).foregroundColor(.white.opacity(0.3)), at: CGPoint(x: cx + 28, y: headY - 30 + zOffset * 0.5))
            }
        }
    }

    // MARK: - Cat color based on mood

    private var catColor: Color {
        switch mood {
        case .happy: return Color(red: 1.0, green: 0.65, blue: 0.2)     // orange tabby
        case .neutral: return Color(red: 0.6, green: 0.6, blue: 0.65)   // grey
        case .concerned: return Color(red: 0.85, green: 0.75, blue: 0.3) // yellowish
        case .worried: return Color(red: 0.9, green: 0.55, blue: 0.2)   // darker orange
        case .stressed: return Color(red: 0.85, green: 0.35, blue: 0.2) // reddish
        case .panic: return Color(red: 0.9, green: 0.2, blue: 0.15)     // red
        case .unknown: return Color(red: 0.5, green: 0.5, blue: 0.55)   // grey
        }
    }

    // MARK: - Draw helpers

    private func drawTail(ctx: GraphicsContext, cx: CGFloat, baseY: CGFloat, w: CGFloat, color: Color, phase: Double) {
        let tailWag = CGFloat(sin(phase * 0.2) * 8)
        var path = Path()
        let startX = cx - 18
        let startY = baseY - 2
        path.move(to: CGPoint(x: startX, y: startY))
        path.addCurve(
            to: CGPoint(x: startX - 20 + tailWag, y: startY - 25),
            control1: CGPoint(x: startX - 15, y: startY - 5),
            control2: CGPoint(x: startX - 25 + tailWag * 0.5, y: startY - 18)
        )
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 4, lineCap: .round))
    }

    private func drawLeg(ctx: GraphicsContext, x: CGFloat, baseY: CGFloat, extend: CGFloat, color: Color) {
        let legH: CGFloat = state == .sitting ? 6 : 10
        var path = Path()
        path.move(to: CGPoint(x: x, y: baseY))
        path.addLine(to: CGPoint(x: x + extend * 0.3, y: baseY + legH))
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 4, lineCap: .round))
    }

    private func drawEar(ctx: GraphicsContext, tipX: CGFloat, tipY: CGFloat, baseX1: CGFloat, baseX2: CGFloat, baseY: CGFloat, outerColor: Color, innerColor: Color) {
        // Outer ear
        var outer = Path()
        outer.move(to: CGPoint(x: tipX, y: tipY))
        outer.addLine(to: CGPoint(x: baseX1, y: baseY))
        outer.addLine(to: CGPoint(x: baseX2, y: baseY))
        outer.closeSubpath()
        ctx.fill(outer, with: .color(outerColor))

        // Inner ear (smaller pink)
        var inner = Path()
        let insetX: CGFloat = 2
        let insetY: CGFloat = 3
        inner.move(to: CGPoint(x: tipX, y: tipY + insetY))
        inner.addLine(to: CGPoint(x: baseX1 + insetX, y: baseY))
        inner.addLine(to: CGPoint(x: baseX2 - insetX, y: baseY))
        inner.closeSubpath()
        ctx.fill(inner, with: .color(innerColor))
    }

    private func drawClosedEye(ctx: GraphicsContext, x: CGFloat, y: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: x - 3, y: y))
        path.addQuadCurve(to: CGPoint(x: x + 3, y: y), control: CGPoint(x: x, y: y + 2))
        ctx.stroke(path, with: .color(.black.opacity(0.6)), style: StrokeStyle(lineWidth: 1))
    }

    private func drawWhiskers(ctx: GraphicsContext, cx: CGFloat, y: CGFloat, color: Color) {
        let whiskerLen: CGFloat = 10
        let style = StrokeStyle(lineWidth: 0.5)
        // Left whiskers
        for i in -1...1 {
            var p = Path()
            p.move(to: CGPoint(x: cx - 4, y: y + CGFloat(i) * 2))
            p.addLine(to: CGPoint(x: cx - 4 - whiskerLen, y: y + CGFloat(i) * 3.5))
            ctx.stroke(p, with: .color(color), style: style)
        }
        // Right whiskers
        for i in -1...1 {
            var p = Path()
            p.move(to: CGPoint(x: cx + 4, y: y + CGFloat(i) * 2))
            p.addLine(to: CGPoint(x: cx + 4 + whiskerLen, y: y + CGFloat(i) * 3.5))
            ctx.stroke(p, with: .color(color), style: style)
        }
    }
}
