import SwiftUI

// MARK: - Zipper Slider

func mechDrawZipper(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)

    // Slider travels up (closing) then back down (opening).
    let up = mechSmooth(mechPulse(t, 0, 1))          // 0 at bottom, 1 at top
    let sy = 72.0 - 42.0 * up                        // slider y in scene units

    func spread(_ y: Double) -> Double {
        // Teeth converge above the slider, fan out below it.
        let d = (y - sy) / 26.0
        return 1.6 + 17.0 * mechSmooth(min(max(d, 0), 1))
    }

    // Tapes (fabric bands) follow the teeth edges.
    func tapePath(_ side: Double) -> Path {
        var path = Path()
        var first = true
        var y = 6.0
        while y <= 94.0 {
            let x = 50.0 + side * (spread(y) + 3.6)
            let pt = p.P(x, y)
            if first { path.move(to: pt); first = false } else { path.addLine(to: pt) }
            y += 2.0
        }
        return path
    }

    p.part("leftrow", explode: CGVector(dx: -14, dy: 0)) { c in
        c.stroke(tapePath(-1), with: .color(CogTheme.teal.opacity(0.9)),
                 style: StrokeStyle(lineWidth: p.L(3.2), lineCap: .round))
        var i = 0
        var y = 8.0
        while y <= 92.0 {
            if i % 2 == 0 {
                let x = 50.0 - spread(y)
                let r = CGRect(x: p.P(x - 2.6, y - 1.2).x, y: p.P(x, y - 1.2).y,
                               width: p.L(3.4), height: p.L(2.4))
                let tooth = Path(roundedRect: r, cornerRadius: p.L(0.9))
                p.metalFill(&c, tooth, .brass,
                            from: CGPoint(x: r.minX, y: r.minY),
                            to: CGPoint(x: r.maxX, y: r.maxY))
            }
            i += 1; y += 2.1
        }
    }

    p.part("rightrow", explode: CGVector(dx: 14, dy: 0)) { c in
        c.stroke(tapePath(1), with: .color(CogTheme.teal.opacity(0.9)),
                 style: StrokeStyle(lineWidth: p.L(3.2), lineCap: .round))
        var i = 0
        var y = 8.0
        while y <= 92.0 {
            if i % 2 == 1 {
                let x = 50.0 + spread(y)
                let r = CGRect(x: p.P(x - 0.8, y - 1.2).x, y: p.P(x, y - 1.2).y,
                               width: p.L(3.4), height: p.L(2.4))
                let tooth = Path(roundedRect: r, cornerRadius: p.L(0.9))
                p.metalFill(&c, tooth, .brass,
                            from: CGPoint(x: r.minX, y: r.minY),
                            to: CGPoint(x: r.maxX, y: r.maxY))
            }
            i += 1; y += 2.1
        }
    }

    // Wedge (the hidden heart of the slider) — drawn under the slider shell.
    p.part("wedge", explode: CGVector(dx: 0, dy: -16)) { c in
        var w = Path()
        w.move(to: p.P(50, sy - 6))
        w.addLine(to: p.P(46, sy + 7))
        w.addLine(to: p.P(50, sy + 4.4))
        w.addLine(to: p.P(54, sy + 7))
        w.closeSubpath()
        p.metalFill(&c, w, .ruby, from: p.P(46, sy - 6), to: p.P(54, sy + 7))
    }

    p.part("slider", explode: CGVector(dx: 17, dy: 6)) { c in
        var s = Path()
        s.move(to: p.P(43.5, sy - 7))
        s.addLine(to: p.P(56.5, sy - 7))
        s.addLine(to: p.P(58.5, sy + 3))
        s.addLine(to: p.P(55.5, sy + 8.5))
        s.addLine(to: p.P(44.5, sy + 8.5))
        s.addLine(to: p.P(41.5, sy + 3))
        s.closeSubpath()
        p.metalFill(&c, s, .steel, from: p.P(42, sy - 7), to: p.P(58, sy + 9))
        // Cutaway window hinting at the wedge inside.
        let win = Path(roundedRect: CGRect(x: p.P(46.4, sy - 4.4).x, y: p.P(46.4, sy - 4.4).y,
                                           width: p.L(7.2), height: p.L(9.6)),
                       cornerRadius: p.L(1.4))
        c.stroke(win, with: .color(mechInk.opacity(0.55)),
                 style: StrokeStyle(lineWidth: p.thinLine, dash: [p.L(1.2), p.L(1.0)]))
    }

    p.part("tab", explode: CGVector(dx: 18, dy: 14)) { c in
        let swing = 8.0 * (up - 0.5)   // tab trails the motion a little
        let ax = 50.0 + swing * 0.4
        let hinge = p.P(50, sy + 8.5)
        let end = p.P(ax, sy + 20)
        p.drawRod(&c, from: hinge, to: end, width: p.L(2.2), metal: .steel)
        let ring = Path(ellipseIn: CGRect(x: end.x - p.L(3.2), y: end.y - p.L(1.6),
                                          width: p.L(6.4), height: p.L(8.0)))
        p.metalFill(&c, ring, .steel, from: end,
                    to: CGPoint(x: end.x, y: end.y + p.L(8)))
    }
}

// MARK: - Pin Tumbler Lock

func mechDrawPinLock(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)

    let keyIn = mechSmooth(mechSeg(t, 0.02, 0.42))           // key slides in
    let aligned = mechSeg(t, 0.48, 0.60)                     // shear line glows
    let turn = mechSmooth(mechSeg(t, 0.62, 0.88))            // plug turns
    let keyX = -26.0 + 44.0 * keyIn                          // key tip x offset

    let stacks: [(x: Double, bitting: Double)] = [
        (32, 4.5), (42, 7.5), (52, 3.0), (62, 6.0), (72, 5.0)
    ]

    // Housing (outer body).
    p.part("housing", explode: CGVector(dx: 0, dy: -18)) { c in
        let body = Path(roundedRect: CGRect(x: p.P(16, 22).x, y: p.P(16, 22).y,
                                            width: p.L(70), height: p.L(24)),
                        cornerRadius: p.L(3))
        p.metalFill(&c, body, .iron, from: p.P(16, 22), to: p.P(86, 46))
        // Spring wells.
        for s in stacks {
            let well = Path(roundedRect: CGRect(x: p.P(s.x - 2.4, 24).x, y: p.P(s.x - 2.4, 24).y,
                                                width: p.L(4.8), height: p.L(21)),
                            cornerRadius: p.L(1))
            c.fill(well, with: .color(mechInk.opacity(0.45)))
        }
    }

    // Springs sit in the housing above the driver pins.
    p.part("springs", explode: CGVector(dx: 0, dy: -12)) { c in
        for s in stacks {
            let lift = pinLift(s: s, keyX: keyX)
            let topY = 25.0
            let botY = 33.0 - lift * 0.55
            p.drawSpring(&c, from: p.P(s.x, topY), to: p.P(s.x, botY),
                         coils: 4, amplitude: p.L(1.5))
        }
    }

    p.part("driverpins", explode: CGVector(dx: 0, dy: -7)) { c in
        for s in stacks {
            let lift = pinLift(s: s, keyX: keyX)
            let h = 6.0
            let y = 39.0 - lift * 0.55 - h
            let r = CGRect(x: p.P(s.x - 1.9, y).x, y: p.P(s.x - 1.9, y).y,
                           width: p.L(3.8), height: p.L(h))
            let pin = Path(roundedRect: r, cornerRadius: p.L(0.8))
            p.metalFill(&c, pin, .steel, from: CGPoint(x: r.minX, y: r.minY),
                        to: CGPoint(x: r.maxX, y: r.maxY))
        }
    }

    // Plug group rotates once pins align — cheat the side view with a slight tilt.
    var plug = ctx
    if turn > 0 {
        let pivot = p.P(51, 52)
        plug.translateBy(x: pivot.x, y: pivot.y)
        plug.rotate(by: .radians(turn * 0.16))
        plug.translateBy(x: -pivot.x, y: -pivot.y)
    }
    let plugPainter = MechScenePainter(plug, size, opt)

    plugPainter.part("plug", explode: CGVector(dx: 0, dy: 10)) { c in
        let body = Path(roundedRect: CGRect(x: p.P(16, 46).x, y: p.P(16, 46).y,
                                            width: p.L(70), height: p.L(13)),
                        cornerRadius: p.L(2))
        p.metalFill(&c, body, .brass, from: p.P(16, 46), to: p.P(86, 59))
        // Front-face dial shows the real rotation.
        let dialC = p.P(90.5, 52.5)
        let dial = Path(ellipseIn: CGRect(x: dialC.x - p.L(6.5), y: dialC.y - p.L(6.5),
                                          width: p.L(13), height: p.L(13)))
        p.metalFill(&c, dial, .brass, from: CGPoint(x: dialC.x - p.L(6), y: dialC.y - p.L(6)),
                    to: CGPoint(x: dialC.x + p.L(6), y: dialC.y + p.L(6)))
        var slot = Path()
        let a = -Double.pi / 2 + turn * 0.7
        slot.move(to: CGPoint(x: dialC.x - p.L(4.6) * CGFloat(cos(a)),
                              y: dialC.y - p.L(4.6) * CGFloat(sin(a))))
        slot.addLine(to: CGPoint(x: dialC.x + p.L(4.6) * CGFloat(cos(a)),
                                 y: dialC.y + p.L(4.6) * CGFloat(sin(a))))
        c.stroke(slot, with: .color(mechInk.opacity(0.9)), lineWidth: p.line * 1.8)
    }

    plugPainter.part("keypins", explode: CGVector(dx: 0, dy: 16)) { c in
        for s in stacks {
            let lift = pinLift(s: s, keyX: keyX)
            let h = 3.0 + s.bitting * 0.45
            let y = 52.5 - lift * 0.55 - h
            let r = CGRect(x: p.P(s.x - 1.9, y).x, y: p.P(s.x - 1.9, y).y,
                           width: p.L(3.8), height: p.L(h))
            var pin = Path(roundedRect: r, cornerRadius: p.L(0.8))
            // Pointed tip.
            pin.move(to: CGPoint(x: r.minX, y: r.maxY))
            pin.addLine(to: CGPoint(x: r.midX, y: r.maxY + p.L(1.4)))
            pin.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
            pin.closeSubpath()
            p.metalFill(&c, pin, .copper, from: CGPoint(x: r.minX, y: r.minY),
                        to: CGPoint(x: r.maxX, y: r.maxY))
        }
    }

    plugPainter.part("key", explode: CGVector(dx: -18, dy: 12)) { c in
        // Blade with bitting profile.
        var blade = Path()
        blade.move(to: p.P(keyX - 14, 56.5))
        blade.addLine(to: p.P(keyX + 56, 56.5))
        blade.addLine(to: p.P(keyX + 56, 54.4))
        var x = keyX + 56.0
        while x > keyX - 6 {
            let localBit = keyBitting(atTipDistance: (keyX + 56.0) - x)
            blade.addLine(to: p.P(x, 54.4 - localBit * 0.5))
            x -= 2.0
        }
        blade.addLine(to: p.P(keyX - 14, 53))
        blade.closeSubpath()
        p.metalFill(&c, blade, .gold, from: p.P(keyX - 14, 52), to: p.P(keyX + 56, 57))
        // Bow (the grip).
        let bowC = p.P(keyX - 18, 55)
        let bow = Path(ellipseIn: CGRect(x: bowC.x - p.L(7), y: bowC.y - p.L(7),
                                         width: p.L(14), height: p.L(14)))
        p.metalFill(&c, bow, .gold, from: CGPoint(x: bowC.x - p.L(7), y: bowC.y - p.L(7)),
                    to: CGPoint(x: bowC.x + p.L(7), y: bowC.y + p.L(7)))
        let hole = Path(ellipseIn: CGRect(x: bowC.x - p.L(2.2), y: bowC.y - p.L(2.2),
                                          width: p.L(4.4), height: p.L(4.4)))
        c.fill(hole, with: .color(CogTheme.blueprint))
        c.stroke(hole, with: .color(mechInk.opacity(0.7)), lineWidth: p.thinLine)
    }

    // Shear line — the magic boundary.
    p.part("shear") { c in
        var lp = Path()
        lp.move(to: p.P(16, 45.6))
        lp.addLine(to: p.P(86, 45.6))
        let glow = 0.35 + 0.65 * (aligned > 0 ? mechPulse(aligned, 0, 1) : 0)
        c.stroke(lp, with: .color(CogTheme.gold.opacity(glow)),
                 style: StrokeStyle(lineWidth: p.line * (aligned > 0 ? 1.8 : 1.0),
                                    dash: [p.L(2.2), p.L(1.6)]))
    }
}

private func keyBitting(atTipDistance d: Double) -> Double {
    // Matches the five pin stacks: valleys at pin positions.
    let cuts: [(pos: Double, depth: Double)] = [
        (46, 4.5), (36, 7.5), (26, 3.0), (16, 6.0), (6, 5.0)
    ]
    var h = 8.0
    for cut in cuts {
        let w = 5.0
        let dist = abs(d - cut.pos)
        if dist < w {
            h = min(h, 8.0 - (8.0 - cut.depth) * (1 - dist / w))
        }
    }
    return h
}

private func pinLift(s: (x: Double, bitting: Double), keyX: Double) -> Double {
    // How far the key has pushed this stack up (0...8-ish).
    let tip = keyX + 56.0
    guard tip > s.x - 2 else { return 0 }
    let ride = min((tip - (s.x - 2)) / 6.0, 1.0)
    return (8.0 - s.bitting) * mechSmooth(ride) + s.bitting * 0
}

// MARK: - Click Pen

func mechDrawClickPen(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)

    // Two full presses per cycle: extend then retract.
    let press1 = mechPulse(t, 0.02, 0.24)
    let press2 = mechPulse(t, 0.52, 0.74)
    let press = max(press1, press2)                          // 0...1 plunger down
    let extended: Double = (t >= 0.24 && t < 0.52) ? 1 : 0
    let camRest = extended * 5.0                             // cam sits lower when extended
    let camSpin = mechSmooth(mechSeg(t, 0.16, 0.26)) + mechSmooth(mechSeg(t, 0.66, 0.76))
    let plungerY = press * 7.0
    let camY = max(press * 7.0, camRest)

    // Barrel (cutaway walls).
    p.part("barrel", explode: CGVector(dx: 16, dy: 0)) { c in
        for side in [-1.0, 1.0] {
            var wall = Path()
            wall.move(to: p.P(50 + side * 8, 14))
            wall.addLine(to: p.P(50 + side * 8, 70))
            wall.addLine(to: p.P(50 + side * 2.6, 88))
            c.stroke(wall, with: .color(mechInk.opacity(0.85)), lineWidth: p.line * 1.6)
            var inner = Path()
            inner.move(to: p.P(50 + side * 6.4, 14))
            inner.addLine(to: p.P(50 + side * 6.4, 69))
            c.stroke(inner, with: .color(MechMetal.sky.base.opacity(0.7)), lineWidth: p.thinLine)
        }
    }

    p.part("button", explode: CGVector(dx: 0, dy: -14)) { c in
        let r = CGRect(x: p.P(45.5, 6 + plungerY).x, y: p.P(45.5, 6 + plungerY).y,
                       width: p.L(9), height: p.L(9))
        let b = Path(roundedRect: r, cornerRadius: p.L(2))
        p.metalFill(&c, b, .ruby, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.maxX, y: r.maxY))
    }

    p.part("plunger", explode: CGVector(dx: -14, dy: -6)) { c in
        let top = 15.0 + plungerY
        let r = CGRect(x: p.P(46.5, top).x, y: p.P(46.5, top).y,
                       width: p.L(7), height: p.L(12))
        let body = Path(roundedRect: r, cornerRadius: p.L(1))
        p.metalFill(&c, body, .steel, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.maxX, y: r.maxY))
        // Sawteeth on the plunger's lower edge.
        var teeth = Path()
        for i in 0..<3 {
            let x0 = 46.5 + Double(i) * 2.4
            teeth.move(to: p.P(x0, top + 12))
            teeth.addLine(to: p.P(x0 + 1.2, top + 14.2))
            teeth.addLine(to: p.P(x0 + 2.4, top + 12))
        }
        teeth.closeSubpath()
        c.fill(teeth, with: .color(MechMetal.steel.dark))
        c.stroke(teeth, with: .color(mechInk.opacity(0.8)), lineWidth: p.thinLine)
    }

    p.part("cam", explode: CGVector(dx: 14, dy: -2)) { c in
        let top = 31.0 + camY
        // Rotating cam drawn unrolled: tooth pattern shifts as it spins.
        let shift = camSpin * 2.4 + (extended > 0 ? 1.2 : 0)
        let r = CGRect(x: p.P(46.5, top).x, y: p.P(46.5, top).y,
                       width: p.L(7), height: p.L(9))
        let body = Path(roundedRect: r, cornerRadius: p.L(1))
        p.metalFill(&c, body, .copper, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.maxX, y: r.maxY))
        var teeth = Path()
        for i in -1..<4 {
            let x0 = 46.5 + Double(i) * 2.4 + shift.truncatingRemainder(dividingBy: 2.4)
            guard x0 >= 45.8, x0 <= 52.2 else { continue }
            teeth.move(to: p.P(x0, top))
            teeth.addLine(to: p.P(x0 + 1.2, top - 2.0))
            teeth.addLine(to: p.P(x0 + 2.4, top))
        }
        teeth.closeSubpath()
        c.fill(teeth, with: .color(MechMetal.copper.light))
        c.stroke(teeth, with: .color(mechInk.opacity(0.8)), lineWidth: p.thinLine)
    }

    p.part("spring", explode: CGVector(dx: -14, dy: 6)) { c in
        let top = 41.0 + camY
        p.drawSpring(&c, from: p.P(50, top), to: p.P(50, 62),
                     coils: 6, amplitude: p.L(2.6))
    }

    p.part("cartridge", explode: CGVector(dx: 0, dy: 16)) { c in
        let drop = camY
        let top = 44.0 + drop
        let tube = Path(roundedRect: CGRect(x: p.P(48.6, top).x, y: p.P(48.6, top).y,
                                            width: p.L(2.8), height: p.L(36)),
                        cornerRadius: p.L(1.2))
        p.metalFill(&c, tube, .sky, from: p.P(48.6, top), to: p.P(51.4, top + 36))
        // Tip pokes out when extended.
        var tip = Path()
        tip.move(to: p.P(48.9, top + 36))
        tip.addLine(to: p.P(50, top + 40.5))
        tip.addLine(to: p.P(51.1, top + 36))
        tip.closeSubpath()
        p.metalFill(&c, tip, .iron, from: p.P(49, top + 36), to: p.P(51, top + 41))
    }
}

// MARK: - Music Box

func mechDrawMusicBox(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2

    // Wooden bed.
    p.part("bed", explode: CGVector(dx: 0, dy: 16)) { c in
        let bed = Path(roundedRect: CGRect(x: p.P(8, 74).x, y: p.P(8, 74).y,
                                           width: p.L(84), height: p.L(12)),
                       cornerRadius: p.L(2.4))
        p.metalFill(&c, bed, .wood, from: p.P(8, 74), to: p.P(92, 86))
        for i in 0..<5 {
            var grain = Path()
            let y = 76.5 + Double(i) * 2.0
            grain.move(to: p.P(11, y))
            grain.addCurve(to: p.P(89, y + 0.8),
                           control1: p.P(35, y - 1.2), control2: p.P(65, y + 1.6))
            c.stroke(grain, with: .color(MechMetal.wood.dark.opacity(0.5)), lineWidth: p.thinLine)
        }
    }

    // Mainspring drum.
    p.part("drum", explode: CGVector(dx: -16, dy: 8)) { c in
        let center = p.P(20, 62)
        let drum = Path(ellipseIn: CGRect(x: center.x - p.L(9), y: center.y - p.L(9),
                                          width: p.L(18), height: p.L(18)))
        p.metalFill(&c, drum, .brass, from: CGPoint(x: center.x - p.L(9), y: center.y - p.L(9)),
                    to: CGPoint(x: center.x + p.L(9), y: center.y + p.L(9)))
        // Coiled spring inside.
        var coil = Path()
        var a = 0.0
        var first = true
        while a < .pi * 6 {
            let r = p.L(1.2 + 6.5 * a / (.pi * 6))
            let pt = CGPoint(x: center.x + r * CGFloat(cos(a - spin * 0.15)),
                             y: center.y + r * CGFloat(sin(a - spin * 0.15)))
            if first { coil.move(to: pt); first = false } else { coil.addLine(to: pt) }
            a += 0.25
        }
        c.stroke(coil, with: .color(mechInk.opacity(0.65)), lineWidth: p.thinLine * 1.3)
    }

    // Drive gearing.
    p.part("gearing", explode: CGVector(dx: -6, dy: 14)) { c in
        p.drawGear(&c, center: p.P(33, 68), teeth: 12, outer: p.L(6.5),
                   rotation: -spin * 1.6, metal: .brass, holes: 0)
        p.drawGear(&c, center: p.P(44, 70), teeth: 9, outer: p.L(4.6),
                   rotation: spin * 2.2, metal: .gold, holes: 0)
    }

    // Pinned cylinder.
    p.part("cylinder", explode: CGVector(dx: 0, dy: -16)) { c in
        let r = CGRect(x: p.P(24, 40).x, y: p.P(24, 40).y, width: p.L(42), height: p.L(20))
        let body = Path(roundedRect: r, cornerRadius: p.L(4))
        p.metalFill(&c, body, .brass, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.minX, y: r.maxY))
        // Pins ride over the surface as the cylinder turns.
        for row in 0..<7 {
            let rowX = 27.5 + Double(row) * 5.6
            for k in 0..<3 {
                let phase = (t * 1.0 + Double(k) / 3.0 + Double(row) * 0.13)
                    .truncatingRemainder(dividingBy: 1.0)
                let y = 40.0 + 20.0 * phase
                guard y > 41.5, y < 58.5 else { continue }
                // Foreshorten near the edges to fake the curve.
                let depth = sin(Double.pi * phase)
                let pinR = p.L(0.75 + 0.55 * depth)
                let pt = p.P(rowX, y)
                let pin = Path(ellipseIn: CGRect(x: pt.x - pinR, y: pt.y - pinR,
                                                 width: pinR * 2, height: pinR * 2))
                c.fill(pin, with: .color(MechMetal.gold.light.opacity(0.5 + 0.5 * depth)))
                c.stroke(pin, with: .color(mechInk.opacity(0.5)), lineWidth: p.thinLine)
            }
        }
        // End caps.
        for ex in [24.0, 66.0] {
            let cap = Path(ellipseIn: CGRect(x: p.P(ex - 2.4, 40).x, y: p.P(ex - 2.4, 40).y,
                                             width: p.L(4.8), height: p.L(20)))
            p.metalFill(&c, cap, .copper, from: p.P(ex, 40), to: p.P(ex, 60))
        }
    }

    // Steel comb.
    p.part("comb", explode: CGVector(dx: 16, dy: 0)) { c in
        let baseR = CGRect(x: p.P(80, 38).x, y: p.P(80, 38).y, width: p.L(9), height: p.L(26))
        let bar = Path(roundedRect: baseR, cornerRadius: p.L(1.6))
        p.metalFill(&c, bar, .iron, from: CGPoint(x: baseR.minX, y: baseR.minY),
                    to: CGPoint(x: baseR.maxX, y: baseR.maxY))
        for i in 0..<8 {
            let y = 40.5 + Double(i) * 2.9
            let len = 12.0 - Double(i) * 0.7
            // Each tooth gets plucked on its own beat and springs back.
            let beat = (t * 2.0 + Double(i) * 0.21).truncatingRemainder(dividingBy: 1.0)
            let deflect = beat < 0.12 ? sin(beat / 0.12 * .pi) * 1.6 : 0.0
            var tooth = Path()
            tooth.move(to: p.P(80.5, y - 0.8))
            tooth.addLine(to: p.P(80.5 - len, y - 0.4 + deflect))
            tooth.addLine(to: p.P(80.5 - len, y + 0.5 + deflect))
            tooth.addLine(to: p.P(80.5, y + 1.0))
            tooth.closeSubpath()
            p.metalFill(&c, tooth, .steel, from: p.P(80.5 - len, y), to: p.P(80.5, y),
                        outlined: false)
            c.stroke(tooth, with: .color(mechInk.opacity(0.7)), lineWidth: p.thinLine)
        }
    }

    // Governor fan keeps the tempo steady.
    p.part("governor", explode: CGVector(dx: 6, dy: -16)) { c in
        let center = p.P(57, 26)
        p.drawRod(&c, from: p.P(50, 40), to: center, width: p.L(1.6), metal: .iron)
        for i in 0..<3 {
            let a = spin * 5 + Double(i) * .pi * 2 / 3
            let tip = CGPoint(x: center.x + p.L(8.5) * CGFloat(cos(a)),
                              y: center.y + p.L(3.6) * CGFloat(sin(a)))
            var blade = Path()
            blade.move(to: center)
            blade.addQuadCurve(to: tip, control: CGPoint(x: center.x + p.L(5) * CGFloat(cos(a + 0.5)),
                                                         y: center.y + p.L(4.5) * CGFloat(sin(a + 0.5))))
            c.stroke(blade, with: .color(MechMetal.steel.base.opacity(0.85)),
                     lineWidth: p.line * 1.4)
        }
        p.drawPin(&c, at: center, radius: p.L(1.6), metal: .gold)
    }
}
