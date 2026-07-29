// Art generator for Gears Inside — deterministic CoreGraphics renderings.
// Build & run on macOS:  swiftc -O gen.swift -o gen && ./gen <outDir> <iconDir>
import Foundation
import CoreGraphics
import CoreText
import ImageIO

// MARK: - Utilities

struct Rand {
    var state: UInt64
    init(_ seed: UInt64) { state = seed &* 2654435761 &+ 909090909 }
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double((state >> 33) % 1_000_000) / 1_000_000
    }
    mutating func range(_ a: Double, _ b: Double) -> Double { a + (b - a) * next() }
}

func ctx(_ w: Int, _ h: Int) -> CGContext {
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    return CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                     bytesPerRow: 0, space: cs,
                     bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
}

func save(_ c: CGContext, _ path: String) {
    let img = c.makeImage()!
    let url = URL(fileURLWithPath: path) as CFURL
    let dest = CGImageDestinationCreateWithURL(url, "public.png" as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
}

func rgb(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor {
    CGColor(srgbRed: r, green: g, blue: b, alpha: a)
}

// Palette
let navyLo = rgb(0.086, 0.133, 0.224)
let navyHi = rgb(0.145, 0.220, 0.353)
let gridCol = rgb(0.427, 0.553, 0.698, 0.16)
let inkLine = rgb(0.859, 0.878, 0.827, 0.85)   // pale engraving line
let brass = rgb(0.804, 0.612, 0.263)
let brassHi = rgb(0.949, 0.816, 0.510)
let brassLo = rgb(0.545, 0.388, 0.133)
let copper = rgb(0.741, 0.459, 0.302)
let tealCol = rgb(0.365, 0.612, 0.671)
let goldCol = rgb(0.941, 0.765, 0.306)
let sealCol = rgb(0.769, 0.400, 0.310)
let cream = rgb(0.965, 0.937, 0.886)

// MARK: - Common passes

func background(_ c: CGContext, _ w: Int, _ h: Int, seed: UInt64) {
    let W = Double(w), H = Double(h)
    // Vertical gradient navy.
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let grad = CGGradient(colorsSpace: cs, colors: [navyHi, navyLo] as CFArray,
                          locations: [0, 1])!
    c.drawLinearGradient(grad, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    // Blueprint grid.
    let step = W / 18
    c.setStrokeColor(gridCol)
    c.setLineWidth(max(1, W / 1200))
    var x = 0.0
    while x <= W { c.move(to: CGPoint(x: x, y: 0)); c.addLine(to: CGPoint(x: x, y: H)); x += step }
    var y = 0.0
    while y <= H { c.move(to: CGPoint(x: 0, y: y)); c.addLine(to: CGPoint(x: W, y: y)); y += step }
    c.strokePath()
    // Faint radial glow centre.
    let glow = CGGradient(colorsSpace: cs,
                          colors: [rgb(0.30, 0.42, 0.58, 0.22), rgb(0, 0, 0, 0)] as CFArray,
                          locations: [0, 1])!
    c.drawRadialGradient(glow, startCenter: CGPoint(x: W / 2, y: H * 0.56), startRadius: 0,
                         endCenter: CGPoint(x: W / 2, y: H * 0.56), endRadius: W * 0.55, options: [])
    // Corner registration marks.
    c.setStrokeColor(rgb(0.86, 0.88, 0.83, 0.4))
    c.setLineWidth(max(1.4, W / 900))
    let m = W * 0.035, len = W * 0.05
    for (cx, cy, sx, sy) in [(m, m, 1.0, 1.0), (W - m, m, -1.0, 1.0),
                             (m, H - m, 1.0, -1.0), (W - m, H - m, -1.0, -1.0)] {
        c.move(to: CGPoint(x: cx, y: cy + sy * len)); c.addLine(to: CGPoint(x: cx, y: cy))
        c.addLine(to: CGPoint(x: cx + sx * len, y: cy))
    }
    c.strokePath()
    _ = seed
}

/// Film-grain: soft luminance speckle. Rendered at reduced resolution and
/// interpolated up so the final PNGs stay a reasonable size.
func grain(_ c: CGContext, _ w: Int, _ h: Int, seed: UInt64, alpha: Double = 0.05) {
    let gw = w / 3, gh = h / 3
    let count = gw * gh
    var data = [UInt8](repeating: 0, count: count)
    var r = Rand(seed)
    var i = 0
    while i < count {
        data[i] = UInt8(r.next() * 255)
        i += 1
    }
    let provider = CGDataProvider(data: Data(data) as CFData)!
    let gray = CGColorSpaceCreateDeviceGray()
    let img = CGImage(width: gw, height: gh, bitsPerComponent: 8, bitsPerPixel: 8,
                      bytesPerRow: gw, space: gray,
                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                      provider: provider, decode: nil, shouldInterpolate: true,
                      intent: .defaultIntent)!
    c.saveGState()
    c.setAlpha(CGFloat(alpha))
    c.setBlendMode(.overlay)
    c.interpolationQuality = .medium
    c.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
    c.restoreGState()
}

func drawText(_ c: CGContext, _ text: String, x: Double, y: Double, size: Double,
              color: CGColor, fontName: String = "Georgia-Bold", centered: Bool = true) {
    let font = CTFontCreateWithName(fontName as CFString, CGFloat(size), nil)
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
    ]
    let str = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(str)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    c.textPosition = CGPoint(x: centered ? CGFloat(x) - bounds.width / 2 : CGFloat(x),
                             y: CGFloat(y))
    CTLineDraw(line, c)
}

func cartouche(_ c: CGContext, _ w: Int, _ h: Int, title: String, subtitle: String) {
    let W = Double(w)
    let bandH = Double(h) * 0.15
    let rect = CGRect(x: W * 0.1, y: Double(h) * 0.045, width: W * 0.8, height: bandH)
    let path = CGPath(roundedRect: rect, cornerWidth: bandH * 0.2, cornerHeight: bandH * 0.2, transform: nil)
    c.setFillColor(rgb(0.06, 0.10, 0.18, 0.72))
    c.addPath(path); c.fillPath()
    c.setStrokeColor(brass)
    c.setLineWidth(max(2, W / 500))
    c.addPath(path); c.strokePath()
    drawText(c, title.uppercased(), x: W / 2, y: rect.minY + bandH * 0.48,
             size: bandH * 0.34, color: cream)
    drawText(c, subtitle, x: W / 2, y: rect.minY + bandH * 0.16,
             size: bandH * 0.18, color: CGColor(srgbRed: 0.55, green: 0.68, blue: 0.78, alpha: 1))
}

// MARK: - Motif primitives (engraving style)

func gearPath(center p: CGPoint, teeth: Int, outer: Double, hub: Double) -> CGPath {
    let path = CGMutablePath()
    let root = outer * 0.82
    let step = Double.pi * 2 / Double(teeth)
    let ht = step * 0.24, hp = step * 0.13
    for i in 0..<teeth {
        let a = Double(i) * step
        let rl = CGPoint(x: p.x + root * cos(a - ht), y: p.y + root * sin(a - ht))
        if i == 0 { path.move(to: rl) } else { path.addLine(to: rl) }
        path.addLine(to: CGPoint(x: p.x + outer * cos(a - hp), y: p.y + outer * sin(a - hp)))
        path.addLine(to: CGPoint(x: p.x + outer * cos(a + hp), y: p.y + outer * sin(a + hp)))
        path.addArc(center: p, radius: root, startAngle: a + ht, endAngle: a + step - ht, clockwise: false)
    }
    path.closeSubpath()
    if hub > 0 {
        path.addEllipse(in: CGRect(x: p.x - hub, y: p.y - hub, width: hub * 2, height: hub * 2))
    }
    return path
}

func fillGear(_ c: CGContext, center: CGPoint, teeth: Int, outer: Double,
              fill: CGColor, line: CGColor, lw: Double, spokes: Int = 5) {
    let path = gearPath(center: center, teeth: teeth, outer: outer, hub: outer * 0.16)
    c.setFillColor(fill)
    c.addPath(path)
    c.fillPath(using: .evenOdd)
    c.setStrokeColor(line)
    c.setLineWidth(lw)
    c.addPath(path)
    c.strokePath()
    if spokes > 0 {
        let hr = outer * 0.5, hs = outer * 0.1
        for i in 0..<spokes {
            let a = Double(i) * .pi * 2 / Double(spokes) + .pi / Double(spokes)
            let hc = CGPoint(x: center.x + hr * cos(a), y: center.y + hr * sin(a))
            c.setStrokeColor(line)
            c.strokeEllipse(in: CGRect(x: hc.x - hs, y: hc.y - hs, width: hs * 2, height: hs * 2))
        }
    }
}

func outlineGear(_ c: CGContext, center: CGPoint, teeth: Int, outer: Double,
                 line: CGColor, lw: Double) {
    let path = gearPath(center: center, teeth: teeth, outer: outer, hub: outer * 0.18)
    c.setStrokeColor(line)
    c.setLineWidth(lw)
    c.addPath(path)
    c.strokePath()
}

func dimensionArc(_ c: CGContext, center: CGPoint, radius: Double, from: Double, to: Double, lw: Double) {
    c.setStrokeColor(rgb(0.55, 0.68, 0.78, 0.55))
    c.setLineWidth(lw)
    c.setLineDash(phase: 0, lengths: [CGFloat(lw * 3), CGFloat(lw * 3)])
    c.addArc(center: center, radius: radius, startAngle: from, endAngle: to, clockwise: false)
    c.strokePath()
    c.setLineDash(phase: 0, lengths: [])
}

func crosshair(_ c: CGContext, at p: CGPoint, r: Double, lw: Double) {
    c.setStrokeColor(rgb(0.55, 0.68, 0.78, 0.5))
    c.setLineWidth(lw)
    c.strokeEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    c.move(to: CGPoint(x: p.x - r * 1.5, y: p.y)); c.addLine(to: CGPoint(x: p.x + r * 1.5, y: p.y))
    c.move(to: CGPoint(x: p.x, y: p.y - r * 1.5)); c.addLine(to: CGPoint(x: p.x, y: p.y + r * 1.5))
    c.strokePath()
}

func rod(_ c: CGContext, _ a: CGPoint, _ b: CGPoint, width: Double, color: CGColor, line: CGColor, lw: Double) {
    let dx = b.x - a.x, dy = b.y - a.y
    let len = sqrt(Double(dx * dx + dy * dy))
    guard len > 0.1 else { return }
    let ang = atan2(Double(dy), Double(dx))
    c.saveGState()
    c.translateBy(x: a.x, y: a.y)
    c.rotate(by: CGFloat(ang))
    let r = CGRect(x: 0, y: -width / 2, width: len, height: width)
    let p = CGPath(roundedRect: r, cornerWidth: width / 2, cornerHeight: width / 2, transform: nil)
    c.setFillColor(color); c.addPath(p); c.fillPath()
    c.setStrokeColor(line); c.setLineWidth(lw); c.addPath(p); c.strokePath()
    c.restoreGState()
}

func pin(_ c: CGContext, _ p: CGPoint, r: Double, fill: CGColor, line: CGColor, lw: Double) {
    c.setFillColor(fill)
    c.fillEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
    c.setStrokeColor(line); c.setLineWidth(lw)
    c.strokeEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
}

// MARK: - Poster motifs per mechanism

func motif(_ c: CGContext, id: String, w: Int, h: Int) {
    let W = Double(w), H = Double(h)
    let cx = W / 2, cy = H * 0.58
    let u = min(W, H) / 100        // motif unit
    let lw = max(2.2, u * 0.5)
    let thin = max(1.4, u * 0.3)

    switch id {
    case "zipper":
        for side in [-1.0, 1.0] {
            for i in 0..<7 {
                let y = cy - 24 * u + Double(i) * 7 * u
                let spread = Double(i) < 3 ? 2.4 * u : (Double(i) - 2) * 5.5 * u
                let x = cx + side * spread + side * 2 * u
                let r = CGRect(x: x - 3 * u, y: y - 2 * u, width: 6 * u, height: 4 * u)
                c.setFillColor(i % 2 == 0 ? brass : copper)
                c.addPath(CGPath(roundedRect: r, cornerWidth: u, cornerHeight: u, transform: nil))
                c.fillPath()
                c.setStrokeColor(inkLine); c.setLineWidth(thin)
                c.addPath(CGPath(roundedRect: r, cornerWidth: u, cornerHeight: u, transform: nil))
                c.strokePath()
            }
        }
        // Slider silhouette.
        let sp = CGMutablePath()
        sp.move(to: CGPoint(x: cx - 9 * u, y: cy + 4 * u))
        sp.addLine(to: CGPoint(x: cx + 9 * u, y: cy + 4 * u))
        sp.addLine(to: CGPoint(x: cx + 6 * u, y: cy - 12 * u))
        sp.addLine(to: CGPoint(x: cx - 6 * u, y: cy - 12 * u))
        sp.closeSubpath()
        c.setFillColor(tealCol); c.addPath(sp); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw); c.addPath(sp); c.strokePath()
        rod(c, CGPoint(x: cx, y: cy - 12 * u), CGPoint(x: cx, y: cy - 22 * u),
            width: 2.6 * u, color: brass, line: inkLine, lw: thin)
        dimensionArc(c, center: CGPoint(x: cx, y: cy), radius: 34 * u, from: -0.6, to: 0.9, lw: thin)

    case "pinlock":
        let body = CGRect(x: cx - 30 * u, y: cy - 6 * u, width: 60 * u, height: 20 * u)
        c.setFillColor(rgb(0.35, 0.40, 0.46))
        c.addPath(CGPath(roundedRect: body, cornerWidth: 3 * u, cornerHeight: 3 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.addPath(CGPath(roundedRect: body, cornerWidth: 3 * u, cornerHeight: 3 * u, transform: nil)); c.strokePath()
        for i in 0..<5 {
            let x = cx - 22 * u + Double(i) * 11 * u
            let hgt = [7.0, 10.0, 5.0, 9.0, 6.0][i] * u
            let r = CGRect(x: x - 2 * u, y: cy - 2 * u, width: 4 * u, height: hgt)
            c.setFillColor(brass); c.fill(r)
            c.setStrokeColor(inkLine); c.setLineWidth(thin); c.stroke(r)
        }
        // Key below.
        rod(c, CGPoint(x: cx - 34 * u, y: cy - 14 * u), CGPoint(x: cx + 22 * u, y: cy - 14 * u),
            width: 3.4 * u, color: goldCol, line: inkLine, lw: thin)
        pin(c, CGPoint(x: cx - 38 * u, y: cy - 14 * u), r: 6 * u, fill: goldCol, line: inkLine, lw: lw)
        dimensionArc(c, center: CGPoint(x: cx, y: cy + 4 * u), radius: 40 * u, from: 2.4, to: 3.6, lw: thin)

    case "clickpen":
        rod(c, CGPoint(x: cx, y: cy - 30 * u), CGPoint(x: cx, y: cy + 18 * u),
            width: 9 * u, color: tealCol, line: inkLine, lw: lw)
        // Spring.
        c.setStrokeColor(brassHi); c.setLineWidth(thin * 1.4)
        var yy = cy - 8.0 * u
        c.move(to: CGPoint(x: cx - 3 * u, y: yy))
        var flip = 1.0
        while yy < cy + 10 * u {
            yy += 2.2 * u
            c.addLine(to: CGPoint(x: cx + flip * 3 * u, y: yy))
            flip = -flip
        }
        c.strokePath()
        // Tip.
        let tip = CGMutablePath()
        tip.move(to: CGPoint(x: cx - 2.4 * u, y: cy + 18 * u))
        tip.addLine(to: CGPoint(x: cx, y: cy + 26 * u))
        tip.addLine(to: CGPoint(x: cx + 2.4 * u, y: cy + 18 * u))
        tip.closeSubpath()
        c.setFillColor(brass); c.addPath(tip); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(thin); c.addPath(tip); c.strokePath()
        // Button.
        let btn = CGRect(x: cx - 4 * u, y: cy - 38 * u, width: 8 * u, height: 8 * u)
        c.setFillColor(sealCol)
        c.addPath(CGPath(roundedRect: btn, cornerWidth: 2 * u, cornerHeight: 2 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(thin)
        c.addPath(CGPath(roundedRect: btn, cornerWidth: 2 * u, cornerHeight: 2 * u, transform: nil)); c.strokePath()
        crosshair(c, at: CGPoint(x: cx + 20 * u, y: cy - 10 * u), r: 5 * u, lw: thin)

    case "musicbox":
        // Cylinder.
        let cyl = CGRect(x: cx - 30 * u, y: cy - 12 * u, width: 44 * u, height: 24 * u)
        c.setFillColor(brass)
        c.addPath(CGPath(roundedRect: cyl, cornerWidth: 6 * u, cornerHeight: 6 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.addPath(CGPath(roundedRect: cyl, cornerWidth: 6 * u, cornerHeight: 6 * u, transform: nil)); c.strokePath()
        var r = Rand(42)
        for _ in 0..<26 {
            let px = cyl.minX + 4 * u + r.next() * (Double(cyl.width) - 8 * u)
            let py = cyl.minY + 3 * u + r.next() * (Double(cyl.height) - 6 * u)
            pin(c, CGPoint(x: px, y: py), r: 0.9 * u, fill: brassHi, line: inkLine, lw: thin * 0.7)
        }
        // Comb.
        for i in 0..<8 {
            let y = cy - 11 * u + Double(i) * 3.1 * u
            let len = (14.0 - Double(i) * 1.1) * u
            rod(c, CGPoint(x: cx + 32 * u, y: y), CGPoint(x: cx + 32 * u - len, y: y),
                width: 1.5 * u, color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin * 0.6)
        }
        dimensionArc(c, center: CGPoint(x: cx - 8 * u, y: cy), radius: 30 * u, from: 3.5, to: 4.6, lw: thin)

    case "geartrain":
        fillGear(c, center: CGPoint(x: cx - 12 * u, y: cy), teeth: 24, outer: 22 * u,
                 fill: brass, line: inkLine, lw: lw, spokes: 5)
        fillGear(c, center: CGPoint(x: cx + 20 * u, y: cy), teeth: 12, outer: 11 * u,
                 fill: copper, line: inkLine, lw: lw, spokes: 3)
        dimensionArc(c, center: CGPoint(x: cx - 12 * u, y: cy), radius: 27 * u, from: 1.9, to: 2.9, lw: thin)
        crosshair(c, at: CGPoint(x: cx - 12 * u, y: cy), r: 2.4 * u, lw: thin)
        crosshair(c, at: CGPoint(x: cx + 20 * u, y: cy), r: 2 * u, lw: thin)

    case "rackpinion":
        fillGear(c, center: CGPoint(x: cx, y: cy + 6 * u), teeth: 16, outer: 15 * u,
                 fill: brass, line: inkLine, lw: lw, spokes: 4)
        let bar = CGRect(x: cx - 34 * u, y: cy - 18 * u, width: 68 * u, height: 6 * u)
        c.setFillColor(rgb(0.61, 0.66, 0.72)); c.fill(bar)
        c.setStrokeColor(inkLine); c.setLineWidth(thin); c.stroke(bar)
        for i in 0..<12 {
            let x = bar.minX + 2 * u + Double(i) * 5.6 * u
            let t = CGMutablePath()
            t.move(to: CGPoint(x: x, y: bar.maxY))
            t.addLine(to: CGPoint(x: x + 1.5 * u, y: bar.maxY + 2.6 * u))
            t.addLine(to: CGPoint(x: x + 3 * u, y: bar.maxY))
            t.closeSubpath()
            c.setFillColor(rgb(0.61, 0.66, 0.72)); c.addPath(t); c.fillPath()
            c.setStrokeColor(inkLine); c.setLineWidth(thin * 0.7); c.addPath(t); c.strokePath()
        }

    case "wormgear":
        let worm = CGRect(x: cx - 26 * u, y: cy + 10 * u, width: 52 * u, height: 12 * u)
        c.setFillColor(rgb(0.61, 0.66, 0.72))
        c.addPath(CGPath(roundedRect: worm, cornerWidth: 6 * u, cornerHeight: 6 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.addPath(CGPath(roundedRect: worm, cornerWidth: 6 * u, cornerHeight: 6 * u, transform: nil)); c.strokePath()
        c.setLineWidth(thin)
        var x = worm.minX + 3 * u
        while x < worm.maxX - 2 * u {
            c.move(to: CGPoint(x: x, y: worm.minY + u))
            c.addLine(to: CGPoint(x: x + 4 * u, y: worm.maxY - u))
            x += 6.4 * u
        }
        c.strokePath()
        fillGear(c, center: CGPoint(x: cx, y: cy - 14 * u), teeth: 24, outer: 19 * u,
                 fill: brass, line: inkLine, lw: lw, spokes: 6)

    case "planetary":
        outlineGear(c, center: CGPoint(x: cx, y: cy), teeth: 30, outer: 33 * u, line: inkLine, lw: lw)
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.strokeEllipse(in: CGRect(x: cx - 37 * u, y: cy - 37 * u, width: 74 * u, height: 74 * u))
        fillGear(c, center: CGPoint(x: cx, y: cy), teeth: 12, outer: 10 * u,
                 fill: goldCol, line: inkLine, lw: lw, spokes: 0)
        for i in 0..<3 {
            let a = Double(i) * .pi * 2 / 3 - .pi / 2
            let pc = CGPoint(x: cx + 20 * u * cos(a), y: cy + 20 * u * sin(a))
            fillGear(c, center: pc, teeth: 9, outer: 8.4 * u,
                     fill: copper, line: inkLine, lw: thin, spokes: 0)
        }

    case "crankslider":
        pin(c, CGPoint(x: cx - 20 * u, y: cy), r: 15 * u, fill: brass, line: inkLine, lw: lw)
        pin(c, CGPoint(x: cx - 20 * u, y: cy), r: 2.6 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: thin)
        let pinP = CGPoint(x: cx - 20 * u + 10 * u * cos(-0.7), y: cy + 10 * u * sin(-0.7))
        rod(c, pinP, CGPoint(x: cx + 24 * u, y: cy), width: 3 * u,
            color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        let box = CGRect(x: cx + 20 * u, y: cy - 5 * u, width: 15 * u, height: 10 * u)
        c.setFillColor(tealCol)
        c.addPath(CGPath(roundedRect: box, cornerWidth: 1.6 * u, cornerHeight: 1.6 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.addPath(CGPath(roundedRect: box, cornerWidth: 1.6 * u, cornerHeight: 1.6 * u, transform: nil)); c.strokePath()
        dimensionArc(c, center: CGPoint(x: cx - 20 * u, y: cy), radius: 19 * u, from: -1.9, to: -0.6, lw: thin)

    case "camfollower":
        let egg = CGMutablePath()
        var a = 0.0
        var first = true
        while a <= .pi * 2 + 0.05 {
            let rr = (10 + 7.5 * pow(0.5 * (1 + cos(a - .pi / 2)), 3)) * u * 1.5
            let pt = CGPoint(x: cx + rr * cos(a), y: cy - 6 * u + rr * sin(a))
            if first { egg.move(to: pt); first = false } else { egg.addLine(to: pt) }
            a += 0.1
        }
        egg.closeSubpath()
        c.setFillColor(copper); c.addPath(egg); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw); c.addPath(egg); c.strokePath()
        pin(c, CGPoint(x: cx, y: cy - 6 * u), r: 2.6 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: thin)
        pin(c, CGPoint(x: cx, y: cy + 24 * u), r: 4 * u, fill: rgb(0.76, 0.80, 0.84), line: inkLine, lw: lw)
        rod(c, CGPoint(x: cx, y: cy + 26 * u), CGPoint(x: cx, y: cy + 40 * u),
            width: 3 * u, color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)

    case "ratchet":
        let teethN = 12
        let path = CGMutablePath()
        let R = 20.0 * u
        for i in 0..<teethN {
            let a = Double(i) * .pi * 2 / Double(teethN)
            let tip = CGPoint(x: cx + R * cos(a), y: cy + R * sin(a))
            if i == 0 { path.move(to: tip) } else { path.addLine(to: tip) }
            path.addLine(to: CGPoint(x: cx + R * 0.76 * cos(a + 0.08), y: cy + R * 0.76 * sin(a + 0.08)))
            path.addLine(to: CGPoint(x: cx + R * 0.76 * cos(a + 0.46), y: cy + R * 0.76 * sin(a + 0.46)))
        }
        path.closeSubpath()
        c.setFillColor(brass); c.addPath(path); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw); c.addPath(path); c.strokePath()
        rod(c, CGPoint(x: cx + 26 * u, y: cy - 20 * u), CGPoint(x: cx + 10 * u, y: cy - 8 * u),
            width: 2.6 * u, color: copper, line: inkLine, lw: thin)
        pin(c, CGPoint(x: cx + 26 * u, y: cy - 20 * u), r: 2 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: thin)
        crosshair(c, at: CGPoint(x: cx, y: cy), r: 2.6 * u, lw: thin)

    case "fourbar":
        let p1 = CGPoint(x: cx - 26 * u, y: cy - 14 * u)
        let p2 = CGPoint(x: cx + 10 * u, y: cy - 14 * u)
        let t1 = CGPoint(x: cx - 2 * u, y: cy + 16 * u)
        let t2 = CGPoint(x: cx + 22 * u, y: cy + 16 * u)
        let cp = CGPoint(x: cx - 22 * u, y: cy - 4 * u)
        pin(c, p1, r: 7 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: lw)
        rod(c, p1, cp, width: 2.6 * u, color: brass, line: inkLine, lw: thin)
        rod(c, cp, t1, width: 2.4 * u, color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        rod(c, p2, t1, width: 2.8 * u, color: copper, line: inkLine, lw: thin)
        rod(c, t1, t2, width: 2.2 * u, color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        rod(c, CGPoint(x: p2.x + 24 * u, y: p2.y), t2, width: 2.8 * u, color: copper, line: inkLine, lw: thin)
        for pt in [p1, p2, CGPoint(x: p2.x + 24 * u, y: p2.y), t1, t2, cp] {
            pin(c, pt, r: 1.8 * u, fill: goldCol, line: inkLine, lw: thin * 0.8)
        }
        dimensionArc(c, center: p2, radius: 36 * u, from: 0.6, to: 1.6, lw: thin)
        dimensionArc(c, center: CGPoint(x: p2.x + 24 * u, y: p2.y), radius: 36 * u, from: 0.6, to: 1.6, lw: thin)

    case "escapement":
        // Escape wheel.
        let R = 16.0 * u
        let wc = CGPoint(x: cx, y: cy + 6 * u)
        let path = CGMutablePath()
        for i in 0..<15 {
            let a = Double(i) * .pi * 2 / 15
            let tip = CGPoint(x: wc.x + R * cos(a), y: wc.y + R * sin(a))
            if i == 0 { path.move(to: tip) } else { path.addLine(to: tip) }
            path.addLine(to: CGPoint(x: wc.x + R * 0.72 * cos(a + 0.06), y: wc.y + R * 0.72 * sin(a + 0.06)))
            path.addLine(to: CGPoint(x: wc.x + R * 0.72 * cos(a + 0.36), y: wc.y + R * 0.72 * sin(a + 0.36)))
        }
        path.closeSubpath()
        c.setFillColor(brass); c.addPath(path); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(lw); c.addPath(path); c.strokePath()
        // Anchor arc.
        c.setStrokeColor(rgb(0.76, 0.80, 0.84)); c.setLineWidth(lw * 1.6)
        c.addArc(center: CGPoint(x: wc.x, y: wc.y + 30 * u), radius: 34 * u,
                 startAngle: -2.2, endAngle: -0.94, clockwise: false)
        c.strokePath()
        // Pendulum.
        rod(c, CGPoint(x: cx, y: cy + 30 * u), CGPoint(x: cx + 8 * u, y: cy - 34 * u),
            width: 2 * u, color: rgb(0.64, 0.46, 0.30), line: inkLine, lw: thin)
        pin(c, CGPoint(x: cx + 9 * u, y: cy - 38 * u), r: 6.4 * u, fill: goldCol, line: inkLine, lw: lw)
        dimensionArc(c, center: CGPoint(x: cx, y: cy + 30 * u), radius: 42 * u, from: -2.2, to: -0.9, lw: thin)

    case "fourstroke":
        // Cylinder cutaway with piston.
        let bore = CGRect(x: cx - 12 * u, y: cy - 10 * u, width: 24 * u, height: 34 * u)
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.stroke(bore.insetBy(dx: -2.4 * u, dy: -2.4 * u))
        let pistonR = CGRect(x: bore.minX + u, y: bore.minY + 4 * u, width: bore.width - 2 * u, height: 10 * u)
        c.setFillColor(rgb(0.76, 0.80, 0.84)); c.fill(pistonR)
        c.setStrokeColor(inkLine); c.setLineWidth(thin); c.stroke(pistonR)
        // Charge glow.
        c.setFillColor(rgb(1.0, 0.62, 0.25, 0.5))
        c.fill(CGRect(x: bore.minX + u, y: pistonR.maxY + u, width: bore.width - 2 * u,
                      height: bore.maxY - pistonR.maxY - 3 * u))
        // Crank below.
        pin(c, CGPoint(x: cx, y: cy - 22 * u), r: 11 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: lw)
        rod(c, CGPoint(x: cx - 4 * u, y: pistonR.midY), CGPoint(x: cx + 5 * u, y: cy - 22 * u),
            width: 2.6 * u, color: copper, line: inkLine, lw: thin)
        // Spark rays.
        c.setStrokeColor(goldCol); c.setLineWidth(thin * 1.3)
        for i in 0..<6 {
            let a = Double(i) * .pi / 3
            c.move(to: CGPoint(x: cx, y: bore.maxY + 5 * u))
            c.addLine(to: CGPoint(x: cx + 4.5 * u * cos(a), y: bore.maxY + 5 * u + 4.5 * u * sin(a)))
        }
        c.strokePath()

    case "steamwheel":
        for i in 0..<3 {
            let wcx = cx - 26 * u + Double(i) * 26 * u
            pin(c, CGPoint(x: wcx, y: cy - 4 * u), r: 12.5 * u, fill: rgb(0.35, 0.40, 0.46), line: inkLine, lw: lw)
            pin(c, CGPoint(x: wcx, y: cy - 4 * u), r: 9.6 * u, fill: sealCol, line: inkLine, lw: thin)
            for k in 0..<8 {
                let a = Double(k) * .pi / 4 + 0.3
                c.setStrokeColor(goldCol); c.setLineWidth(thin)
                c.move(to: CGPoint(x: wcx, y: cy - 4 * u))
                c.addLine(to: CGPoint(x: wcx + 9 * u * cos(a), y: cy - 4 * u + 9 * u * sin(a)))
                c.strokePath()
            }
        }
        // Side rod through pins.
        rod(c, CGPoint(x: cx - 30 * u, y: cy - 8.5 * u), CGPoint(x: cx + 30 * u, y: cy - 8.5 * u),
            width: 2.6 * u, color: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        // Rail.
        c.setStrokeColor(inkLine); c.setLineWidth(lw)
        c.move(to: CGPoint(x: cx - 42 * u, y: cy - 18 * u))
        c.addLine(to: CGPoint(x: cx + 42 * u, y: cy - 18 * u))
        c.strokePath()

    case "blocktackle":
        pin(c, CGPoint(x: cx, y: cy + 22 * u), r: 8 * u, fill: rgb(0.64, 0.46, 0.30), line: inkLine, lw: lw)
        pin(c, CGPoint(x: cx, y: cy + 22 * u), r: 5.4 * u, fill: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        pin(c, CGPoint(x: cx, y: cy - 4 * u), r: 8 * u, fill: rgb(0.64, 0.46, 0.30), line: inkLine, lw: lw)
        pin(c, CGPoint(x: cx, y: cy - 4 * u), r: 5.4 * u, fill: rgb(0.76, 0.80, 0.84), line: inkLine, lw: thin)
        c.setStrokeColor(rgb(0.85, 0.72, 0.45)); c.setLineWidth(thin * 1.6)
        c.move(to: CGPoint(x: cx - 5.4 * u, y: cy + 22 * u))
        c.addLine(to: CGPoint(x: cx - 5.4 * u, y: cy - 4 * u))
        c.move(to: CGPoint(x: cx + 5.4 * u, y: cy + 22 * u))
        c.addLine(to: CGPoint(x: cx + 5.4 * u, y: cy - 4 * u))
        c.move(to: CGPoint(x: cx + 5.4 * u, y: cy + 22 * u))
        c.addLine(to: CGPoint(x: cx + 14 * u, y: cy - 10 * u))
        c.strokePath()
        // Crate.
        let crate = CGRect(x: cx - 10 * u, y: cy - 28 * u, width: 20 * u, height: 15 * u)
        c.setFillColor(rgb(0.64, 0.46, 0.30))
        c.addPath(CGPath(roundedRect: crate, cornerWidth: 1.4 * u, cornerHeight: 1.4 * u, transform: nil)); c.fillPath()
        c.setStrokeColor(inkLine); c.setLineWidth(thin)
        c.addPath(CGPath(roundedRect: crate, cornerWidth: 1.4 * u, cornerHeight: 1.4 * u, transform: nil)); c.strokePath()
        c.move(to: CGPoint(x: crate.minX, y: crate.minY)); c.addLine(to: CGPoint(x: crate.maxX, y: crate.maxY))
        c.move(to: CGPoint(x: crate.maxX, y: crate.minY)); c.addLine(to: CGPoint(x: crate.minX, y: crate.maxY))
        c.strokePath()
        rod(c, CGPoint(x: cx, y: cy - 9.5 * u), CGPoint(x: cx, y: cy - 13 * u),
            width: 1.6 * u, color: rgb(0.64, 0.46, 0.30), line: inkLine, lw: thin * 0.8)

    default:
        // Generic gear cluster.
        fillGear(c, center: CGPoint(x: cx - 10 * u, y: cy), teeth: 18, outer: 18 * u,
                 fill: brass, line: inkLine, lw: lw, spokes: 5)
        fillGear(c, center: CGPoint(x: cx + 16 * u, y: cy + 10 * u), teeth: 10, outer: 9 * u,
                 fill: copper, line: inkLine, lw: lw, spokes: 0)
        fillGear(c, center: CGPoint(x: cx + 12 * u, y: cy - 16 * u), teeth: 8, outer: 7 * u,
                 fill: tealCol, line: inkLine, lw: thin, spokes: 0)
    }
}

// MARK: - Image builders

func poster(_ id: String, _ title: String, _ subtitle: String, _ path: String, seed: UInt64) {
    let w = 1440, h = 1080
    let c = ctx(w, h)
    background(c, w, h, seed: seed)
    motif(c, id: id, w: w, h: h)
    cartouche(c, w, h, title: title, subtitle: subtitle)
    grain(c, w, h, seed: seed, alpha: 0.06)
    save(c, path)
}

func banner(_ id: String, _ path: String, seed: UInt64, motifs: [String]) {
    let w = 1600, h = 800
    let c = ctx(w, h)
    background(c, w, h, seed: seed)
    // Row of small motifs.
    let W = Double(w), H = Double(h)
    let count = motifs.count
    for (i, m) in motifs.enumerated() {
        c.saveGState()
        let mx = W * (Double(i) + 0.5) / Double(count)
        c.translateBy(x: mx - W / 2, y: H * 0.0)
        c.saveGState()
        c.translateBy(x: W / 2, y: H / 2)
        c.scaleBy(x: 0.42, y: 0.42)
        c.translateBy(x: -W / 2, y: -H * 0.58)
        motif(c, id: m, w: w, h: h)
        c.restoreGState()
        c.restoreGState()
    }
    grain(c, w, h, seed: seed, alpha: 0.06)
    save(c, path)
}

func cover(_ motifID: String, _ path: String, seed: UInt64, tint: CGColor? = nil) {
    let w = 1280, h = 768
    let c = ctx(w, h)
    background(c, w, h, seed: seed)
    if let t = tint {
        c.setFillColor(t)
        c.fill(CGRect(x: 0, y: 0, width: w, height: h))
    }
    c.saveGState()
    c.translateBy(x: CGFloat(w) / 2, y: CGFloat(h) / 2)
    c.scaleBy(x: 0.8, y: 0.8)
    c.translateBy(x: -CGFloat(w) / 2, y: -CGFloat(h) * 0.56)
    motif(c, id: motifID, w: w, h: h)
    c.restoreGState()
    // Decorative border.
    c.setStrokeColor(brass)
    c.setLineWidth(5)
    c.stroke(CGRect(x: 26, y: 26, width: w - 52, height: h - 52))
    grain(c, w, h, seed: seed, alpha: 0.06)
    save(c, path)
}

func onboard(_ idx: Int, _ path: String) {
    let w = 1200, h = 1400
    let c = ctx(w, h)
    background(c, w, h, seed: UInt64(900 + idx))
    let W = Double(w), H = Double(h)
    switch idx {
    case 1:
        // Big gear trio.
        fillGear(c, center: CGPoint(x: W * 0.42, y: H * 0.58), teeth: 20, outer: W * 0.22,
                 fill: brass, line: inkLine, lw: 6, spokes: 6)
        fillGear(c, center: CGPoint(x: W * 0.72, y: H * 0.44), teeth: 12, outer: W * 0.12,
                 fill: copper, line: inkLine, lw: 5, spokes: 3)
        fillGear(c, center: CGPoint(x: W * 0.66, y: H * 0.76), teeth: 9, outer: W * 0.09,
                 fill: tealCol, line: inkLine, lw: 4, spokes: 0)
        crosshair(c, at: CGPoint(x: W * 0.42, y: H * 0.58), r: W * 0.03, lw: 3)
    case 2:
        // Hand-crank arrows around a gear.
        fillGear(c, center: CGPoint(x: W * 0.5, y: H * 0.58), teeth: 16, outer: W * 0.2,
                 fill: brass, line: inkLine, lw: 6, spokes: 4)
        dimensionArc(c, center: CGPoint(x: W * 0.5, y: H * 0.58), radius: W * 0.28, from: -0.6, to: 1.2, lw: 5)
        dimensionArc(c, center: CGPoint(x: W * 0.5, y: H * 0.58), radius: W * 0.28, from: 2.5, to: 4.3, lw: 5)
        // Exploded parts drifting.
        pin(c, CGPoint(x: W * 0.2, y: H * 0.8), r: W * 0.045, fill: copper, line: inkLine, lw: 4)
        pin(c, CGPoint(x: W * 0.82, y: H * 0.34), r: W * 0.035, fill: tealCol, line: inkLine, lw: 4)
    default:
        // Medal above small gears.
        pin(c, CGPoint(x: W * 0.5, y: H * 0.62), r: W * 0.15, fill: goldCol, line: inkLine, lw: 6)
        pin(c, CGPoint(x: W * 0.5, y: H * 0.62), r: W * 0.10, fill: brass, line: inkLine, lw: 4)
        let star = CGMutablePath()
        for i in 0..<10 {
            let r = i % 2 == 0 ? W * 0.055 : W * 0.024
            let a = Double(i) * .pi / 5 - .pi / 2
            let pt = CGPoint(x: W * 0.5 + r * cos(a), y: H * 0.62 - r * sin(a))
            if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
        }
        star.closeSubpath()
        c.setFillColor(cream); c.addPath(star); c.fillPath()
        fillGear(c, center: CGPoint(x: W * 0.24, y: H * 0.36), teeth: 10, outer: W * 0.07,
                 fill: copper, line: inkLine, lw: 4, spokes: 0)
        fillGear(c, center: CGPoint(x: W * 0.78, y: H * 0.4), teeth: 8, outer: W * 0.06,
                 fill: tealCol, line: inkLine, lw: 4, spokes: 0)
    }
    grain(c, w, h, seed: UInt64(900 + idx), alpha: 0.06)
    save(c, path)
}

func appIcon(_ path: String) {
    let w = 1024, h = 1024
    let c = ctx(w, h)
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    // Muted navy radial background.
    let grad = CGGradient(colorsSpace: cs,
                          colors: [rgb(0.20, 0.28, 0.42), rgb(0.09, 0.13, 0.22)] as CFArray,
                          locations: [0, 1])!
    c.drawRadialGradient(grad, startCenter: CGPoint(x: 512, y: 600), startRadius: 0,
                         endCenter: CGPoint(x: 512, y: 512), endRadius: 800, options: [])
    // Abstract faceted amber token (not a literal gear).
    let center = CGPoint(x: 512, y: 512)
    let R = 300.0
    let hex = CGMutablePath()
    for i in 0..<8 {
        let a = Double(i) * .pi / 4 + .pi / 8
        let pt = CGPoint(x: center.x + R * cos(a), y: center.y + R * sin(a))
        if i == 0 { hex.move(to: pt) } else { hex.addLine(to: pt) }
    }
    hex.closeSubpath()
    let tokenGrad = CGGradient(colorsSpace: cs,
                               colors: [rgb(0.95, 0.82, 0.51), rgb(0.80, 0.61, 0.26), rgb(0.55, 0.39, 0.13)] as CFArray,
                               locations: [0, 0.55, 1])!
    c.saveGState()
    c.addPath(hex)
    c.clip()
    c.drawLinearGradient(tokenGrad, start: CGPoint(x: 300, y: 800), end: CGPoint(x: 750, y: 250), options: [])
    c.restoreGState()
    // Facet lines.
    c.setStrokeColor(rgb(0.55, 0.39, 0.13, 0.65))
    c.setLineWidth(7)
    for i in 0..<8 {
        let a = Double(i) * .pi / 4 + .pi / 8
        c.move(to: center)
        c.addLine(to: CGPoint(x: center.x + R * cos(a), y: center.y + R * sin(a)))
    }
    c.strokePath()
    c.setLineWidth(12)
    c.setStrokeColor(rgb(0.35, 0.25, 0.09))
    c.addPath(hex)
    c.strokePath()
    // Inner ring accent.
    c.setStrokeColor(rgb(0.36, 0.61, 0.67, 0.85))
    c.setLineWidth(10)
    c.strokeEllipse(in: CGRect(x: center.x - 130, y: center.y - 130, width: 260, height: 260))
    // Small centre dot.
    c.setFillColor(rgb(0.95, 0.82, 0.51))
    c.fillEllipse(in: CGRect(x: center.x - 34, y: center.y - 34, width: 68, height: 68))
    // Sparkles.
    for (sx, sy, sr) in [(760.0, 780.0, 22.0), (270.0, 300.0, 15.0), (800.0, 330.0, 12.0)] {
        let star = CGMutablePath()
        for i in 0..<8 {
            let r = i % 2 == 0 ? sr : sr * 0.4
            let a = Double(i) * .pi / 4
            let pt = CGPoint(x: sx + r * cos(a), y: sy + r * sin(a))
            if i == 0 { star.move(to: pt) } else { star.addLine(to: pt) }
        }
        star.closeSubpath()
        c.setFillColor(rgb(0.96, 0.90, 0.72, 0.9))
        c.addPath(star)
        c.fillPath()
    }
    save(c, path)
}

// MARK: - Main

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "./Art"
let iconDir = args.count > 2 ? args[2] : "./"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

let posters: [(String, String, String)] = [
    ("zipper", "Zipper Slider", "Around the House · Plate I"),
    ("pinlock", "Pin Tumbler Lock", "Around the House · Plate II"),
    ("clickpen", "Click Pen", "Around the House · Plate III"),
    ("musicbox", "Music Box", "Around the House · Plate IV"),
    ("geartrain", "Spur Gear Pair", "Gear Works · Plate I"),
    ("rackpinion", "Rack and Pinion", "Gear Works · Plate II"),
    ("wormgear", "Worm Gear", "Gear Works · Plate III"),
    ("planetary", "Planetary Gearset", "Gear Works · Plate IV"),
    ("crankslider", "Crank and Slider", "Cranks & Linkages · Plate I"),
    ("camfollower", "Cam and Follower", "Cranks & Linkages · Plate II"),
    ("ratchet", "Ratchet and Pawl", "Cranks & Linkages · Plate III"),
    ("fourbar", "Wiper Linkage", "Cranks & Linkages · Plate IV"),
    ("escapement", "Anchor Escapement", "Great Machines · Plate I"),
    ("fourstroke", "Four-Stroke Engine", "Great Machines · Plate II"),
    ("steamwheel", "Locomotive Drive", "Great Machines · Plate III"),
    ("blocktackle", "Block and Tackle", "Great Machines · Plate IV"),
]

for (i, p) in posters.enumerated() {
    poster(p.0, p.1, p.2, "\(outDir)/poster_\(p.0).png", seed: UInt64(100 + i))
    print("poster_\(p.0).png")
}

banner("house", "\(outDir)/wing_house.png", seed: 201, motifs: ["zipper", "pinlock", "musicbox"])
banner("gears", "\(outDir)/wing_gears.png", seed: 202, motifs: ["geartrain", "wormgear", "planetary"])
banner("linkages", "\(outDir)/wing_linkages.png", seed: 203, motifs: ["crankslider", "camfollower", "ratchet"])
banner("machines", "\(outDir)/wing_machines.png", seed: 204, motifs: ["escapement", "fourstroke", "steamwheel"])
print("wing banners done")

cover("geartrain", "\(outDir)/guide_gears.png", seed: 301)
cover("wormgear", "\(outDir)/guide_ratio.png", seed: 302)
cover("blocktackle", "\(outDir)/guide_simple.png", seed: 303)
cover("escapement", "\(outDir)/guide_clock.png", seed: 304)
cover("steamwheel", "\(outDir)/guide_steam.png", seed: 305)
cover("fourbar", "\(outDir)/guide_linkage.png", seed: 306)
cover("camfollower", "\(outDir)/guide_friction.png", seed: 307)
cover("pinlock", "\(outDir)/guide_locks.png", seed: 308)
print("guide covers done")

banner("hero", "\(outDir)/hero_workshop.png", seed: 401, motifs: ["geartrain", "escapement", "crankslider"])
cover("default", "\(outDir)/quiz_banner.png", seed: 402)
cover("planetary", "\(outDir)/progress_banner.png", seed: 403)
cover("musicbox", "\(outDir)/more_banner.png", seed: 404)
print("misc banners done")

onboard(1, "\(outDir)/onboard_1.png")
onboard(2, "\(outDir)/onboard_2.png")
onboard(3, "\(outDir)/onboard_3.png")
print("onboarding done")

appIcon("\(iconDir)/AppIcon-1024.png")
print("icon done")
