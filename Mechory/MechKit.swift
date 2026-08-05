import SwiftUI

// MARK: - Metal palettes

struct MechMetal {
    let light: Color
    let base: Color
    let dark: Color

    static let brass = MechMetal(
        light: Color(red: 0.949, green: 0.816, blue: 0.510),
        base: Color(red: 0.804, green: 0.612, blue: 0.263),
        dark: Color(red: 0.545, green: 0.388, blue: 0.133))
    static let steel = MechMetal(
        light: Color(red: 0.847, green: 0.878, blue: 0.906),
        base: Color(red: 0.612, green: 0.663, blue: 0.718),
        dark: Color(red: 0.357, green: 0.404, blue: 0.463))
    static let iron = MechMetal(
        light: Color(red: 0.557, green: 0.596, blue: 0.647),
        base: Color(red: 0.373, green: 0.412, blue: 0.463),
        dark: Color(red: 0.204, green: 0.231, blue: 0.271))
    static let copper = MechMetal(
        light: Color(red: 0.898, green: 0.647, blue: 0.478),
        base: Color(red: 0.741, green: 0.459, blue: 0.302),
        dark: Color(red: 0.502, green: 0.286, blue: 0.180))
    static let gold = MechMetal(
        light: Color(red: 0.980, green: 0.878, blue: 0.573),
        base: Color(red: 0.929, green: 0.753, blue: 0.337),
        dark: Color(red: 0.663, green: 0.494, blue: 0.169))
    static let wood = MechMetal(
        light: Color(red: 0.788, green: 0.616, blue: 0.427),
        base: Color(red: 0.639, green: 0.463, blue: 0.298),
        dark: Color(red: 0.427, green: 0.290, blue: 0.173))
    static let ruby = MechMetal(
        light: Color(red: 0.898, green: 0.510, blue: 0.412),
        base: Color(red: 0.769, green: 0.353, blue: 0.263),
        dark: Color(red: 0.518, green: 0.216, blue: 0.157))
    static let sky = MechMetal(
        light: Color(red: 0.573, green: 0.769, blue: 0.827),
        base: Color(red: 0.361, green: 0.596, blue: 0.671),
        dark: Color(red: 0.192, green: 0.388, blue: 0.451))
}

let mechInk = Color(red: 0.043, green: 0.075, blue: 0.145)

// MARK: - Scene painter

/// Maps a 100x100 scene coordinate space onto the stage canvas and applies
/// per-part explode offsets and highlight dimming.
struct MechScenePainter {
    let base: GraphicsContext
    let size: CGSize
    let opt: MechRenderOptions
    let scale: CGFloat
    let ox: CGFloat
    let oy: CGFloat

    init(_ ctx: GraphicsContext, _ size: CGSize, _ opt: MechRenderOptions) {
        self.base = ctx
        self.size = size
        self.opt = opt
        let s = min(size.width, size.height) / 100
        self.scale = s
        self.ox = (size.width - 100 * s) / 2
        self.oy = (size.height - 100 * s) / 2
    }

    func P(_ x: Double, _ y: Double) -> CGPoint {
        CGPoint(x: ox + CGFloat(x) * scale, y: oy + CGFloat(y) * scale)
    }

    func L(_ v: Double) -> CGFloat { CGFloat(v) * scale }

    var line: CGFloat { max(1, 0.45 * scale) }
    var thinLine: CGFloat { max(0.7, 0.28 * scale) }

    /// Draw one named part; the closure receives a context already offset for
    /// explode and faded when another part is highlighted.
    func part(_ id: String, explode v: CGVector = CGVector(dx: 0, dy: 0),
              _ body: (inout GraphicsContext) -> Void) {
        if opt.hideCallouts && id == "callout" { return }
        var c = base
        c.opacity = Double(opt.alpha(for: id))
        if opt.explode > 0 {
            c.translateBy(x: v.dx * opt.explode * scale, y: v.dy * opt.explode * scale)
        }
        body(&c)
    }

    // MARK: Fills

    func metalFill(_ c: inout GraphicsContext, _ path: Path, _ metal: MechMetal,
                   from: CGPoint, to: CGPoint, outlined: Bool = true) {
        c.fill(path, with: .linearGradient(
            Gradient(colors: [metal.light, metal.base, metal.dark]),
            startPoint: from, endPoint: to))
        if outlined {
            c.stroke(path, with: .color(mechInk.opacity(0.85)), lineWidth: line)
        }
    }

    func flatFill(_ c: inout GraphicsContext, _ path: Path, _ color: Color, outlined: Bool = true) {
        c.fill(path, with: .color(color))
        if outlined {
            c.stroke(path, with: .color(mechInk.opacity(0.85)), lineWidth: line)
        }
    }

    // MARK: Gear

    func gearPath(center: CGPoint, teeth: Int, outer: CGFloat, root: CGFloat,
                  hub: CGFloat, rotation: Double) -> Path {
        var p = Path()
        let n = max(4, teeth)
        let step = .pi * 2 / Double(n)
        let halfTooth = step * 0.24
        let halfTip = step * 0.13
        for i in 0..<n {
            let a = rotation + Double(i) * step
            let rootL = CGPoint(x: center.x + root * CGFloat(cos(a - halfTooth)),
                                y: center.y + root * CGFloat(sin(a - halfTooth)))
            let tipL = CGPoint(x: center.x + outer * CGFloat(cos(a - halfTip)),
                               y: center.y + outer * CGFloat(sin(a - halfTip)))
            let tipR = CGPoint(x: center.x + outer * CGFloat(cos(a + halfTip)),
                               y: center.y + outer * CGFloat(sin(a + halfTip)))
            if i == 0 { p.move(to: rootL) } else { p.addLine(to: rootL) }
            p.addLine(to: tipL)
            p.addLine(to: tipR)
            p.addArc(center: center, radius: root,
                     startAngle: .radians(a + halfTooth),
                     endAngle: .radians(a + step - halfTooth),
                     clockwise: false)
        }
        p.closeSubpath()
        if hub > 0 {
            p.addEllipse(in: CGRect(x: center.x - hub, y: center.y - hub,
                                    width: hub * 2, height: hub * 2))
        }
        return p
    }

    /// Full decorated gear: toothed body, hub ring and lightening holes.
    func drawGear(_ c: inout GraphicsContext, center: CGPoint, teeth: Int,
                  outer: CGFloat, rotation: Double, metal: MechMetal = .brass,
                  hubScale: CGFloat = 0.18, holes: Int = 4) {
        let root = outer * 0.82
        let hub = outer * hubScale
        let path = gearPath(center: center, teeth: teeth, outer: outer,
                            root: root, hub: hub, rotation: rotation)
        let grad = CGRect(x: center.x - outer, y: center.y - outer,
                          width: outer * 2, height: outer * 2)
        c.fill(path, with: .linearGradient(
            Gradient(colors: [metal.light, metal.base, metal.dark]),
            startPoint: CGPoint(x: grad.minX, y: grad.minY),
            endPoint: CGPoint(x: grad.maxX, y: grad.maxY)),
               style: FillStyle(eoFill: true))
        c.stroke(path, with: .color(mechInk.opacity(0.85)), lineWidth: line)
        // Hub ring
        let ring = Path(ellipseIn: CGRect(x: center.x - hub * 1.7, y: center.y - hub * 1.7,
                                          width: hub * 3.4, height: hub * 3.4))
        c.stroke(ring, with: .color(mechInk.opacity(0.4)), lineWidth: thinLine)
        // Lightening holes rotate with the gear so motion reads clearly.
        if holes > 0 {
            let hr = outer * 0.5
            let hs = outer * 0.115
            for i in 0..<holes {
                let a = rotation + Double(i) * .pi * 2 / Double(holes) + .pi / Double(holes)
                let hc = CGPoint(x: center.x + hr * CGFloat(cos(a)),
                                 y: center.y + hr * CGFloat(sin(a)))
                let hole = Path(ellipseIn: CGRect(x: hc.x - hs, y: hc.y - hs,
                                                  width: hs * 2, height: hs * 2))
                c.fill(hole, with: .color(metal.dark.opacity(0.55)))
                c.stroke(hole, with: .color(mechInk.opacity(0.5)), lineWidth: thinLine)
            }
        }
    }

    // MARK: Rods, pins, springs

    func rodPath(from a: CGPoint, to b: CGPoint, width: CGFloat) -> Path {
        let dx = b.x - a.x, dy = b.y - a.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0.01 else { return Path() }
        let angle = atan2(dy, dx)
        var p = Path(roundedRect: CGRect(x: 0, y: -width / 2, width: len, height: width),
                     cornerRadius: width / 2)
        let t = CGAffineTransform(translationX: a.x, y: a.y).rotated(by: angle)
        p = p.applying(t)
        return p
    }

    func drawRod(_ c: inout GraphicsContext, from a: CGPoint, to b: CGPoint,
                 width: CGFloat, metal: MechMetal = .steel) {
        let p = rodPath(from: a, to: b, width: width)
        metalFill(&c, p, metal, from: a, to: b)
    }

    func drawPin(_ c: inout GraphicsContext, at pt: CGPoint, radius: CGFloat,
                 metal: MechMetal = .iron) {
        let p = Path(ellipseIn: CGRect(x: pt.x - radius, y: pt.y - radius,
                                       width: radius * 2, height: radius * 2))
        metalFill(&c, p, metal,
                  from: CGPoint(x: pt.x - radius, y: pt.y - radius),
                  to: CGPoint(x: pt.x + radius, y: pt.y + radius))
    }

    func springPath(from a: CGPoint, to b: CGPoint, coils: Int, amplitude: CGFloat) -> Path {
        var p = Path()
        let dx = b.x - a.x, dy = b.y - a.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0.01 else { return p }
        let ux = dx / len, uy = dy / len
        let px = -uy, py = ux
        p.move(to: a)
        let seg = 2 * coils
        for i in 1..<seg {
            let f = CGFloat(i) / CGFloat(seg)
            let side: CGFloat = i % 2 == 0 ? -1 : 1
            p.addLine(to: CGPoint(x: a.x + dx * f + px * amplitude * side,
                                  y: a.y + dy * f + py * amplitude * side))
        }
        p.addLine(to: b)
        return p
    }

    func drawSpring(_ c: inout GraphicsContext, from a: CGPoint, to b: CGPoint,
                    coils: Int, amplitude: CGFloat, color: Color = MechMetal.iron.base) {
        let p = springPath(from: a, to: b, coils: coils, amplitude: amplitude)
        c.stroke(p, with: .color(mechInk.opacity(0.8)), lineWidth: line * 1.5)
        c.stroke(p, with: .color(color), lineWidth: line * 0.8)
    }

    // MARK: Frames & plates

    func drawPlate(_ c: inout GraphicsContext, rect: CGRect, corner: CGFloat,
                   metal: MechMetal = .iron) {
        let p = Path(roundedRect: rect, cornerRadius: corner)
        metalFill(&c, p, metal,
                  from: CGPoint(x: rect.minX, y: rect.minY),
                  to: CGPoint(x: rect.maxX, y: rect.maxY))
    }

    /// Small motion arrow used to hint direction.
    func drawArrowArc(_ c: inout GraphicsContext, center: CGPoint, radius: CGFloat,
                      from a0: Double, to a1: Double, color: Color) {
        var p = Path()
        p.addArc(center: center, radius: radius,
                 startAngle: .radians(a0), endAngle: .radians(a1), clockwise: a1 < a0)
        c.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: line, lineCap: .round, dash: [L(1.4), L(1.6)]))
        // Arrow head at end angle.
        let end = CGPoint(x: center.x + radius * CGFloat(cos(a1)),
                          y: center.y + radius * CGFloat(sin(a1)))
        let tangent = a1 + (a1 >= a0 ? 1 : -1) * Double.pi / 2
        var head = Path()
        let hs = L(2.2)
        head.move(to: CGPoint(x: end.x + hs * CGFloat(cos(tangent)),
                              y: end.y + hs * CGFloat(sin(tangent))))
        head.addLine(to: CGPoint(x: end.x + hs * 0.6 * CGFloat(cos(tangent + 2.5)),
                                 y: end.y + hs * 0.6 * CGFloat(sin(tangent + 2.5))))
        head.addLine(to: CGPoint(x: end.x + hs * 0.6 * CGFloat(cos(tangent - 2.5)),
                                 y: end.y + hs * 0.6 * CGFloat(sin(tangent - 2.5))))
        head.closeSubpath()
        c.fill(head, with: .color(color))
    }
}

// MARK: - Easing helpers shared by scenes

func mechSmooth(_ t: Double) -> Double {
    let c = min(max(t, 0), 1)
    return c * c * (3 - 2 * c)
}

/// Piecewise segment progress: maps t in [a,b] to 0...1, clamped outside.
func mechSeg(_ t: Double, _ a: Double, _ b: Double) -> Double {
    guard b > a else { return 0 }
    return min(max((t - a) / (b - a), 0), 1)
}

/// Triangle wave 0→1→0 across [a,b].
func mechPulse(_ t: Double, _ a: Double, _ b: Double) -> Double {
    let s = mechSeg(t, a, b)
    return s < 0.5 ? s * 2 : (1 - s) * 2
}
