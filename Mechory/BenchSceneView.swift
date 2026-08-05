import SwiftUI

/// The living workshop hero: a window that follows the real clock, a wooden
/// bench, a glowing oil lamp after dark, drifting dust motes — and the
/// Mechanism of the Day running live in its framed panel on the bench.
struct BenchSceneView: View {
    let daily: MechanismSpec

    private var hourNow: Double {
        #if DEBUG
        if let forced = ProcessInfo.processInfo.environment["COG_HOUR"],
           let h = Double(forced) {
            return h
        }
        #endif
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        return Double(comps.hour ?? 12) + Double(comps.minute ?? 0) / 60.0
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                drawScene(&ctx, size: size, time: t)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CogTheme.ink.opacity(0.22), lineWidth: 1.5)
        )
    }

    // MARK: Scene

    private func drawScene(_ ctx: inout GraphicsContext, size: CGSize, time: Double) {
        let w = size.width, h = size.height
        let hour = hourNow
        let night = hour < 5.5 || hour >= 21
        let dusk = (hour >= 18 && hour < 21) || (hour >= 5.5 && hour < 8)

        // Back wall.
        ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                 with: .linearGradient(
                    Gradient(colors: night
                        ? [Color(red: 0.10, green: 0.13, blue: 0.22), Color(red: 0.07, green: 0.09, blue: 0.16)]
                        : [Color(red: 0.36, green: 0.30, blue: 0.24), Color(red: 0.28, green: 0.23, blue: 0.18)]),
                    startPoint: .zero, endPoint: CGPoint(x: 0, y: h)))

        // Pegboard region with holes.
        let pegRect = CGRect(x: w * 0.04, y: h * 0.08, width: w * 0.38, height: h * 0.5)
        ctx.fill(Path(roundedRect: pegRect, cornerRadius: 8),
                 with: .color(MechMetal.wood.base.opacity(night ? 0.5 : 0.85)))
        let step = pegRect.width / 7
        for c in 1..<7 {
            for r in 1..<Int(pegRect.height / step) {
                let pt = CGPoint(x: pegRect.minX + CGFloat(c) * step,
                                 y: pegRect.minY + CGFloat(r) * step)
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 2, y: pt.y - 2, width: 4, height: 4)),
                         with: .color(MechMetal.wood.dark.opacity(0.7)))
            }
        }
        // A couple of hanging tools on the pegboard.
        var wrench = Path()
        wrench.move(to: CGPoint(x: pegRect.minX + step * 1.5, y: pegRect.minY + step))
        wrench.addLine(to: CGPoint(x: pegRect.minX + step * 2.4, y: pegRect.minY + step * 2.6))
        ctx.stroke(wrench, with: .color(MechMetal.steel.base.opacity(night ? 0.5 : 0.9)),
                   style: StrokeStyle(lineWidth: 5, lineCap: .round))
        var hammer = Path()
        hammer.move(to: CGPoint(x: pegRect.minX + step * 4.6, y: pegRect.minY + step))
        hammer.addLine(to: CGPoint(x: pegRect.minX + step * 4.6, y: pegRect.minY + step * 2.8))
        ctx.stroke(hammer, with: .color(MechMetal.wood.dark.opacity(night ? 0.5 : 0.9)),
                   style: StrokeStyle(lineWidth: 5, lineCap: .round))
        ctx.fill(Path(roundedRect: CGRect(x: pegRect.minX + step * 4.0, y: pegRect.minY + step * 0.7,
                                          width: step * 1.2, height: step * 0.55),
                      cornerRadius: 3),
                 with: .color(MechMetal.iron.base.opacity(night ? 0.5 : 0.9)))

        // Window with live sky.
        let win = CGRect(x: w * 0.50, y: h * 0.07, width: w * 0.30, height: h * 0.42)
        drawWindow(&ctx, win: win, hour: hour, time: time, night: night, dusk: dusk)

        // Bench top.
        let benchY = h * 0.62
        ctx.fill(Path(roundedRect: CGRect(x: -4, y: benchY, width: w + 8, height: h - benchY + 4),
                      cornerRadius: 6),
                 with: .linearGradient(
                    Gradient(colors: [MechMetal.wood.light.opacity(night ? 0.55 : 1),
                                      MechMetal.wood.dark.opacity(night ? 0.6 : 1)]),
                    startPoint: CGPoint(x: 0, y: benchY), endPoint: CGPoint(x: 0, y: h)))
        var edge = Path()
        edge.move(to: CGPoint(x: 0, y: benchY))
        edge.addLine(to: CGPoint(x: w, y: benchY))
        ctx.stroke(edge, with: .color(mechInk.opacity(0.5)), lineWidth: 2)

        // Oil lamp (right of the framed panel).
        drawLamp(&ctx, at: CGPoint(x: w * 0.87, y: benchY), night: night, time: time)

        // The framed daily-mechanism panel standing on the bench.
        let panelW = min(w * 0.46, h * 0.78)
        let panel = CGRect(x: w * 0.5 - panelW * 0.62, y: benchY - panelW * 0.96,
                           width: panelW, height: panelW)
        // Easel legs.
        var legs = Path()
        legs.move(to: CGPoint(x: panel.minX + 8, y: panel.maxY - 4))
        legs.addLine(to: CGPoint(x: panel.minX - 10, y: benchY + 14))
        legs.move(to: CGPoint(x: panel.maxX - 8, y: panel.maxY - 4))
        legs.addLine(to: CGPoint(x: panel.maxX + 10, y: benchY + 14))
        ctx.stroke(legs, with: .color(MechMetal.wood.dark), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        // Frame.
        ctx.fill(Path(roundedRect: panel.insetBy(dx: -7, dy: -7), cornerRadius: 12),
                 with: .color(MechMetal.wood.dark))
        ctx.fill(Path(roundedRect: panel, cornerRadius: 8),
                 with: .linearGradient(Gradient(colors: [CogTheme.blueprintHi, CogTheme.blueprint]),
                                       startPoint: CGPoint(x: panel.minX, y: panel.minY),
                                       endPoint: CGPoint(x: panel.minX, y: panel.maxY)))
        // Live mechanism inside the frame.
        var inner = ctx
        inner.clip(to: Path(roundedRect: panel, cornerRadius: 8))
        inner.translateBy(x: panel.minX, y: panel.minY)
        let phase = (time / daily.cycleSeconds).truncatingRemainder(dividingBy: 1)
        var mechCtx = inner
        daily.draw(&mechCtx, CGSize(width: panel.width, height: panel.height),
                   phase < 0 ? phase + 1 : phase, MechRenderOptions(hideCallouts: true))
        // Brass name plate under the frame.
        let plateW = panelW * 0.7
        let plate = CGRect(x: panel.midX - plateW / 2, y: panel.maxY + 10, width: plateW, height: 16)
        ctx.fill(Path(roundedRect: plate, cornerRadius: 4),
                 with: .linearGradient(Gradient(colors: [MechMetal.brass.light, MechMetal.brass.dark]),
                                       startPoint: CGPoint(x: plate.minX, y: plate.minY),
                                       endPoint: CGPoint(x: plate.maxX, y: plate.maxY)))
        let name = Text(daily.name.uppercased())
            .font(.system(size: 9, weight: .bold, design: .serif))
            .foregroundColor(Color(red: 0.28, green: 0.19, blue: 0.06))
        ctx.draw(ctx.resolve(name), at: CGPoint(x: plate.midX, y: plate.midY), anchor: .center)

        // Dust motes drifting in the light.
        for i in 0..<7 {
            let seed = Double(i) * 1.7
            let mx = w * CGFloat(0.15 + 0.7 * frac(seed * 0.37 + time * 0.008 * (1 + seed * 0.1)))
            let my = h * CGFloat(0.15 + 0.55 * frac(seed * 0.61 + time * 0.005 * (1 + seed * 0.07)))
            let alpha = 0.10 + 0.10 * sin(time * 0.7 + seed * 3)
            ctx.fill(Path(ellipseIn: CGRect(x: mx, y: my, width: 2.4, height: 2.4)),
                     with: .color(Color.white.opacity(max(0, alpha))))
        }

        // Night dimming vignette.
        if night {
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .color(Color(red: 0.03, green: 0.05, blue: 0.1).opacity(0.18)))
        }
    }

    private func frac(_ v: Double) -> Double {
        v - floor(v)
    }

    private func drawWindow(_ ctx: inout GraphicsContext, win: CGRect, hour: Double,
                            time: Double, night: Bool, dusk: Bool) {
        let skyColors: [Color]
        if night {
            skyColors = [Color(red: 0.06, green: 0.09, blue: 0.20), Color(red: 0.10, green: 0.14, blue: 0.28)]
        } else if dusk {
            skyColors = [Color(red: 0.94, green: 0.62, blue: 0.40), Color(red: 0.53, green: 0.42, blue: 0.56)]
        } else {
            skyColors = [Color(red: 0.53, green: 0.75, blue: 0.87), Color(red: 0.74, green: 0.87, blue: 0.92)]
        }
        var sky = ctx
        sky.clip(to: Path(roundedRect: win, cornerRadius: 8))
        sky.fill(Path(CGRect(x: win.minX, y: win.minY, width: win.width, height: win.height)),
                 with: .linearGradient(Gradient(colors: skyColors),
                                       startPoint: CGPoint(x: win.midX, y: win.minY),
                                       endPoint: CGPoint(x: win.midX, y: win.maxY)))
        // Sun or moon arcs across the pane through the day/night.
        let dayFrac = night
            ? frac((hour < 12 ? hour + 24 : hour) - 21) / 8.5
            : (hour - 5.5) / 15.5
        let discX = win.minX + win.width * CGFloat(min(max(dayFrac, 0.05), 0.95))
        let discY = win.minY + win.height * (0.28 + 0.3 * abs(CGFloat(dayFrac) - 0.5) * 2)
        if night {
            let moon = Path(ellipseIn: CGRect(x: discX - 8, y: discY - 8, width: 16, height: 16))
            sky.fill(moon, with: .color(Color(red: 0.92, green: 0.92, blue: 0.85)))
            let bite = Path(ellipseIn: CGRect(x: discX - 3, y: discY - 9, width: 14, height: 14))
            sky.fill(bite, with: .color(skyColors[0]))
            // Stars twinkle.
            for i in 0..<12 {
                let sx = win.minX + win.width * CGFloat(frac(Double(i) * 0.617 + 0.05))
                let sy = win.minY + win.height * CGFloat(frac(Double(i) * 0.371 + 0.1)) * 0.8
                let tw = 0.35 + 0.65 * abs(sin(time * (0.6 + Double(i % 4) * 0.23) + Double(i)))
                sky.fill(Path(ellipseIn: CGRect(x: sx, y: sy, width: 2, height: 2)),
                         with: .color(Color.white.opacity(tw * 0.85)))
            }
        } else {
            let sun = Path(ellipseIn: CGRect(x: discX - 9, y: discY - 9, width: 18, height: 18))
            sky.fill(sun, with: .color(dusk ? Color(red: 0.98, green: 0.55, blue: 0.30)
                                            : Color(red: 0.99, green: 0.85, blue: 0.45)))
            // A slow cloud.
            let cx = win.minX + win.width * CGFloat(frac(time * 0.012))
            let cloud = Path(ellipseIn: CGRect(x: cx - 14, y: win.minY + win.height * 0.3,
                                               width: 28, height: 10))
            sky.fill(cloud, with: .color(Color.white.opacity(0.55)))
        }
        // Frame + crossbars.
        ctx.stroke(Path(roundedRect: win, cornerRadius: 8),
                   with: .color(MechMetal.wood.dark), lineWidth: 6)
        var bars = Path()
        bars.move(to: CGPoint(x: win.midX, y: win.minY))
        bars.addLine(to: CGPoint(x: win.midX, y: win.maxY))
        bars.move(to: CGPoint(x: win.minX, y: win.midY))
        bars.addLine(to: CGPoint(x: win.maxX, y: win.midY))
        ctx.stroke(bars, with: .color(MechMetal.wood.dark), lineWidth: 3)
    }

    private func drawLamp(_ ctx: inout GraphicsContext, at base: CGPoint, night: Bool, time: Double) {
        // Warm glow first (behind the lamp), only after dark.
        if night {
            let flicker = 0.85 + 0.15 * sin(time * 5.3) * sin(time * 2.1)
            ctx.fill(Path(ellipseIn: CGRect(x: base.x - 46, y: base.y - 74, width: 92, height: 92)),
                     with: .radialGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.75, blue: 0.35).opacity(0.4 * flicker),
                                          Color.clear]),
                        center: CGPoint(x: base.x, y: base.y - 28),
                        startRadius: 2, endRadius: 48))
        }
        // Base + stem.
        ctx.fill(Path(roundedRect: CGRect(x: base.x - 10, y: base.y - 6, width: 20, height: 6),
                      cornerRadius: 2),
                 with: .color(MechMetal.brass.dark))
        ctx.fill(Path(roundedRect: CGRect(x: base.x - 2, y: base.y - 22, width: 4, height: 17),
                      cornerRadius: 2),
                 with: .color(MechMetal.brass.base))
        // Glass chimney.
        var glass = Path()
        glass.move(to: CGPoint(x: base.x - 7, y: base.y - 22))
        glass.addQuadCurve(to: CGPoint(x: base.x - 4, y: base.y - 40),
                           control: CGPoint(x: base.x - 9, y: base.y - 33))
        glass.addQuadCurve(to: CGPoint(x: base.x + 4, y: base.y - 40),
                           control: CGPoint(x: base.x, y: base.y - 44))
        glass.addQuadCurve(to: CGPoint(x: base.x + 7, y: base.y - 22),
                           control: CGPoint(x: base.x + 9, y: base.y - 33))
        glass.closeSubpath()
        ctx.fill(glass, with: .color(Color.white.opacity(night ? 0.22 : 0.14)))
        ctx.stroke(glass, with: .color(MechMetal.brass.dark.opacity(0.8)), lineWidth: 1.4)
        // Flame.
        if night {
            let sway = sin(time * 6.5) * 1.2
            var flame = Path()
            flame.move(to: CGPoint(x: base.x - 2.5, y: base.y - 25))
            flame.addQuadCurve(to: CGPoint(x: base.x + sway, y: base.y - 36),
                               control: CGPoint(x: base.x - 4 + sway, y: base.y - 32))
            flame.addQuadCurve(to: CGPoint(x: base.x + 2.5, y: base.y - 25),
                               control: CGPoint(x: base.x + 4 + sway, y: base.y - 32))
            flame.closeSubpath()
            ctx.fill(flame, with: .color(Color(red: 1.0, green: 0.8, blue: 0.35)))
        }
    }
}
