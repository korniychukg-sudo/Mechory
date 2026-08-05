import SwiftUI

// Custom Path-drawn icons — no SF Symbols anywhere in the app.

struct GearGlyph: Shape {
    var teeth: Int = 8
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let root = outer * 0.74
        let hub = outer * 0.3
        let step = .pi * 2 / Double(teeth)
        let halfTooth = step * 0.26
        let halfTip = step * 0.14
        for i in 0..<teeth {
            let a = Double(i) * step - .pi / 2
            let rootL = CGPoint(x: c.x + root * CGFloat(cos(a - halfTooth)),
                                y: c.y + root * CGFloat(sin(a - halfTooth)))
            if i == 0 { p.move(to: rootL) } else { p.addLine(to: rootL) }
            p.addLine(to: CGPoint(x: c.x + outer * CGFloat(cos(a - halfTip)),
                                  y: c.y + outer * CGFloat(sin(a - halfTip))))
            p.addLine(to: CGPoint(x: c.x + outer * CGFloat(cos(a + halfTip)),
                                  y: c.y + outer * CGFloat(sin(a + halfTip))))
            p.addArc(center: c, radius: root,
                     startAngle: .radians(a + halfTooth),
                     endAngle: .radians(a + step - halfTooth),
                     clockwise: false)
        }
        p.closeSubpath()
        p.addEllipse(in: CGRect(x: c.x - hub, y: c.y - hub, width: hub * 2, height: hub * 2))
        return p
    }
}

struct DrawerGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h * 0.42),
                         cornerSize: CGSize(width: w * 0.08, height: w * 0.08))
        p.addRoundedRect(in: CGRect(x: 0, y: h * 0.52, width: w, height: h * 0.42),
                         cornerSize: CGSize(width: w * 0.08, height: w * 0.08))
        p.addRoundedRect(in: CGRect(x: w * 0.36, y: h * 0.14, width: w * 0.28, height: h * 0.1),
                         cornerSize: CGSize(width: w * 0.04, height: w * 0.04))
        p.addRoundedRect(in: CGRect(x: w * 0.36, y: h * 0.66, width: w * 0.28, height: h * 0.1),
                         cornerSize: CGSize(width: w * 0.04, height: w * 0.04))
        return p
    }
}

struct BookGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Left page.
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.16))
        p.addQuadCurve(to: CGPoint(x: w * 0.06, y: h * 0.12),
                       control: CGPoint(x: w * 0.26, y: h * 0.0))
        p.addLine(to: CGPoint(x: w * 0.06, y: h * 0.82))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.9),
                       control: CGPoint(x: w * 0.28, y: h * 0.74))
        p.closeSubpath()
        // Right page.
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.16))
        p.addQuadCurve(to: CGPoint(x: w * 0.94, y: h * 0.12),
                       control: CGPoint(x: w * 0.74, y: h * 0.0))
        p.addLine(to: CGPoint(x: w * 0.94, y: h * 0.82))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.9),
                       control: CGPoint(x: w * 0.72, y: h * 0.74))
        p.closeSubpath()
        return p
    }
}

struct MedalGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Ribbons.
        p.move(to: CGPoint(x: w * 0.3, y: 0))
        p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.34))
        p.addLine(to: CGPoint(x: w * 0.24, y: h * 0.42))
        p.addLine(to: CGPoint(x: w * 0.12, y: h * 0.06))
        p.closeSubpath()
        p.move(to: CGPoint(x: w * 0.7, y: 0))
        p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.34))
        p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.42))
        p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.06))
        p.closeSubpath()
        // Disc.
        p.addEllipse(in: CGRect(x: w * 0.22, y: h * 0.36, width: w * 0.56, height: h * 0.56))
        return p
    }
}

struct WrenchGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Simple angled spanner silhouette.
        p.move(to: CGPoint(x: w * 0.18, y: h * 0.06))
        p.addLine(to: CGPoint(x: w * 0.4, y: h * 0.06))
        p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.72))
        p.addLine(to: CGPoint(x: w * 0.92, y: h * 0.64))
        p.addLine(to: CGPoint(x: w * 0.92, y: h * 0.88))
        p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.94))
        p.addLine(to: CGPoint(x: w * 0.7, y: h * 0.8))
        p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.3))
        p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.34))
        p.closeSubpath()
        return p
    }
}

struct DotsGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = rect.width * 0.12
        for i in 0..<3 {
            let x = rect.width * (0.2 + 0.3 * CGFloat(i))
            p.addEllipse(in: CGRect(x: x - r, y: rect.midY - r, width: r * 2, height: r * 2))
        }
        return p
    }
}

struct ChevronGlyph: Shape {
    var pointRight = true
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        if pointRight {
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.12))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.5))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.88))
        } else {
            p.move(to: CGPoint(x: w * 0.68, y: h * 0.12))
            p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.5))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.88))
        }
        return p
    }
}

struct PlayGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.28, y: h * 0.14))
        p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.5))
        p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.86))
        p.closeSubpath()
        return p
    }
}

struct PauseGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.addRoundedRect(in: CGRect(x: w * 0.22, y: h * 0.14, width: w * 0.2, height: h * 0.72),
                         cornerSize: CGSize(width: w * 0.06, height: w * 0.06))
        p.addRoundedRect(in: CGRect(x: w * 0.58, y: h * 0.14, width: w * 0.2, height: h * 0.72),
                         cornerSize: CGSize(width: w * 0.06, height: w * 0.06))
        return p
    }
}

struct CheckGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.14, y: h * 0.54))
        p.addLine(to: CGPoint(x: w * 0.4, y: h * 0.8))
        p.addLine(to: CGPoint(x: w * 0.86, y: h * 0.22))
        return p
    }
}

struct CrossGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.2, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.8, y: h * 0.8))
        p.move(to: CGPoint(x: w * 0.8, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.2, y: h * 0.8))
        return p
    }
}

struct FlameGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.04))
        p.addQuadCurve(to: CGPoint(x: w * 0.84, y: h * 0.62),
                       control: CGPoint(x: w * 0.88, y: h * 0.28))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.96),
                       control: CGPoint(x: w * 0.84, y: h * 0.96))
        p.addQuadCurve(to: CGPoint(x: w * 0.16, y: h * 0.62),
                       control: CGPoint(x: w * 0.16, y: h * 0.96))
        p.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.3),
                       control: CGPoint(x: w * 0.12, y: h * 0.4))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.04),
                       control: CGPoint(x: w * 0.46, y: h * 0.18))
        p.closeSubpath()
        return p
    }
}

struct StarGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.42
        for i in 0..<10 {
            let r = i % 2 == 0 ? outer : inner
            let a = Double(i) * .pi / 5 - .pi / 2
            let pt = CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y + r * CGFloat(sin(a)))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

/// Tab bar icon wrapper.
struct CogTabIcon: View {
    let kind: Kind
    let active: Bool

    enum Kind { case workshop, library, learn, progress, more, bench }

    var body: some View {
        let color = active ? CogTheme.brass : CogTheme.inkSoft.opacity(0.7)
        Group {
            switch kind {
            case .workshop:
                GearGlyph(teeth: 8).fill(color, style: FillStyle(eoFill: true))
            case .library:
                DrawerGlyph().fill(color, style: FillStyle(eoFill: true))
            case .learn:
                BookGlyph().fill(color)
            case .progress:
                MedalGlyph().fill(color)
            case .more:
                DotsGlyph().fill(color)
            case .bench:
                WrenchGlyph().fill(color)
            }
        }
        .frame(width: 25, height: 25)
    }
}
