import SwiftUI

// MARK: - Crank and Slider

func mechDrawCrankSlider(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2
    let crankC = p.P(30, 58)
    let crankR = p.L(13)
    let rodLen = p.L(33)
    let pin = CGPoint(x: crankC.x + crankR * CGFloat(cos(spin)),
                      y: crankC.y + crankR * CGFloat(sin(spin)))
    // Slider is constrained to the guide line y = crank center y.
    let dy = pin.y - crankC.y
    let reach = sqrt(max(rodLen * rodLen - dy * dy, 0))
    let sliderX = pin.x + reach

    p.part("guide", explode: CGVector(dx: 0, dy: -16)) { c in
        for off in [-6.5, 6.5] {
            let rail = Path(roundedRect: CGRect(x: p.P(52, 58).x, y: crankC.y + p.L(off) - p.L(1.1),
                                                width: p.L(40), height: p.L(2.2)),
                            cornerRadius: p.L(1.1))
            p.metalFill(&c, rail, .iron, from: p.P(52, 52), to: p.P(92, 64))
        }
    }

    p.part("crank", explode: CGVector(dx: -16, dy: 8)) { c in
        let wheel = Path(ellipseIn: CGRect(x: crankC.x - crankR - p.L(3), y: crankC.y - crankR - p.L(3),
                                           width: (crankR + p.L(3)) * 2, height: (crankR + p.L(3)) * 2))
        p.metalFill(&c, wheel, .brass, from: CGPoint(x: crankC.x - crankR, y: crankC.y - crankR),
                    to: CGPoint(x: crankC.x + crankR, y: crankC.y + crankR))
        // Crank web from shaft to pin.
        p.drawRod(&c, from: crankC, to: pin, width: p.L(4), metal: .copper)
        p.drawPin(&c, at: crankC, radius: p.L(2.6), metal: .iron)
        p.drawArrowArc(&c, center: crankC, radius: crankR + p.L(6.5),
                       from: -2.2, to: -1.2, color: CogTheme.gold.opacity(0.9))
    }

    p.part("rod", explode: CGVector(dx: 0, dy: -20)) { c in
        p.drawRod(&c, from: pin, to: CGPoint(x: sliderX, y: crankC.y),
                  width: p.L(3), metal: .steel)
        p.drawPin(&c, at: pin, radius: p.L(2), metal: .iron)
    }

    p.part("piston", explode: CGVector(dx: 16, dy: 8)) { c in
        let r = CGRect(x: sliderX - p.L(6), y: crankC.y - p.L(5),
                       width: p.L(15), height: p.L(10))
        let body = Path(roundedRect: r, cornerRadius: p.L(1.6))
        p.metalFill(&c, body, .sky, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.maxX, y: r.maxY))
        for i in 0..<2 {
            var groove = Path()
            let gx = r.minX + p.L(3.5) + CGFloat(i) * p.L(3)
            groove.move(to: CGPoint(x: gx, y: r.minY + p.L(1)))
            groove.addLine(to: CGPoint(x: gx, y: r.maxY - p.L(1)))
            c.stroke(groove, with: .color(mechInk.opacity(0.5)), lineWidth: p.thinLine)
        }
        p.drawPin(&c, at: CGPoint(x: sliderX, y: crankC.y), radius: p.L(1.8), metal: .iron)
    }

    p.part("callout") { c in
        let text = Text("round and round  →  back and forth")
            .font(CogTheme.mono(11)).foregroundColor(CogTheme.gridLine)
        c.draw(c.resolve(text), at: p.P(50, 88), anchor: .center)
    }
}

// MARK: - Cam and Follower

private func camRadius(_ a: Double) -> Double {
    // Egg profile: gentle base circle with one smooth lobe at angle 0.
    let lobe = pow(0.5 * (1 + cos(a)), 3.0)
    return 9.5 + 7.5 * lobe
}

func mechDrawCamFollower(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let rot = t * .pi * 2
    let camC = p.P(50, 66)
    // Contact happens at the top of the cam (angle -π/2 in screen space).
    let contactR = camRadius(-Double.pi / 2 - rot)
    let rollerR = p.L(3.2)
    let rollerC = CGPoint(x: camC.x, y: camC.y - p.L(contactR) - rollerR)

    p.part("frame", explode: CGVector(dx: 16, dy: -6)) { c in
        for off in [-5.5, 5.5] {
            let rail = Path(roundedRect: CGRect(x: camC.x + p.L(off) - p.L(1.1), y: p.P(50, 12).y,
                                                width: p.L(2.2), height: p.L(22)),
                            cornerRadius: p.L(1.1))
            p.metalFill(&c, rail, .iron, from: p.P(44, 12), to: p.P(56, 34))
        }
    }

    p.part("cam", explode: CGVector(dx: 0, dy: 16)) { c in
        var egg = Path()
        var a = 0.0
        var first = true
        while a <= .pi * 2 + 0.05 {
            let r = p.L(camRadius(a))
            let pt = CGPoint(x: camC.x + r * CGFloat(cos(a + rot)),
                             y: camC.y + r * CGFloat(sin(a + rot)))
            if first { egg.move(to: pt); first = false } else { egg.addLine(to: pt) }
            a += 0.12
        }
        egg.closeSubpath()
        p.metalFill(&c, egg, .copper, from: CGPoint(x: camC.x - p.L(17), y: camC.y - p.L(17)),
                    to: CGPoint(x: camC.x + p.L(17), y: camC.y + p.L(17)))
        p.drawPin(&c, at: camC, radius: p.L(2.4), metal: .iron)
        p.drawArrowArc(&c, center: camC, radius: p.L(20),
                       from: 1.0, to: 2.0, color: CogTheme.gold.opacity(0.9))
    }

    p.part("follower", explode: CGVector(dx: -16, dy: -8)) { c in
        // Roller.
        let roller = Path(ellipseIn: CGRect(x: rollerC.x - rollerR, y: rollerC.y - rollerR,
                                            width: rollerR * 2, height: rollerR * 2))
        p.metalFill(&c, roller, .steel, from: CGPoint(x: rollerC.x - rollerR, y: rollerC.y - rollerR),
                    to: CGPoint(x: rollerC.x + rollerR, y: rollerC.y + rollerR))
        // Stem up through the guide.
        p.drawRod(&c, from: CGPoint(x: rollerC.x, y: rollerC.y - rollerR),
                  to: CGPoint(x: rollerC.x, y: p.P(50, 13).y), width: p.L(3), metal: .steel)
        // Plate on top (the "valve").
        let plate = Path(roundedRect: CGRect(x: rollerC.x - p.L(6), y: p.P(50, 10.6).y,
                                             width: p.L(12), height: p.L(3)),
                         cornerRadius: p.L(1.4))
        p.metalFill(&c, plate, .ruby, from: p.P(44, 10), to: p.P(56, 14))
    }

    p.part("spring", explode: CGVector(dx: -14, dy: 6)) { c in
        let top = p.P(50, 15).y
        p.drawSpring(&c, from: CGPoint(x: rollerC.x - p.L(8.5), y: top),
                     to: CGPoint(x: rollerC.x - p.L(8.5), y: rollerC.y - rollerR * 0.4),
                     coils: 5, amplitude: p.L(1.8))
        p.drawSpring(&c, from: CGPoint(x: rollerC.x + p.L(8.5), y: top),
                     to: CGPoint(x: rollerC.x + p.L(8.5), y: rollerC.y - rollerR * 0.4),
                     coils: 5, amplitude: p.L(1.8))
    }
}

// MARK: - Ratchet and Pawl

func mechDrawRatchet(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let teethN = 12
    let pitch = Double.pi * 2 / Double(teethN)
    let forward = mechSmooth(mechSeg(t, 0.05, 0.45))
    let back = mechSmooth(mechSeg(t, 0.55, 0.95))
    let wheelRot = -pitch * forward                 // advance exactly one tooth per cycle
    let leverA = -pitch * forward + pitch * back    // lever swings and returns
    let wheelC = p.P(46, 54)
    let wheelR = p.L(21)

    p.part("frame", explode: CGVector(dx: 0, dy: 18)) { c in
        let base = Path(roundedRect: CGRect(x: p.P(20, 84).x, y: p.P(20, 84).y,
                                            width: p.L(60), height: p.L(6)),
                        cornerRadius: p.L(2))
        p.metalFill(&c, base, .wood, from: p.P(20, 84), to: p.P(80, 90))
        p.drawRod(&c, from: p.P(46, 84), to: CGPoint(x: wheelC.x, y: wheelC.y),
                  width: p.L(4), metal: .iron)
    }

    p.part("wheel", explode: CGVector(dx: -16, dy: -8)) { c in
        // Saw-toothed ratchet wheel.
        var path = Path()
        for i in 0..<teethN {
            let a = wheelRot + Double(i) * pitch
            let tip = CGPoint(x: wheelC.x + wheelR * CGFloat(cos(a)),
                              y: wheelC.y + wheelR * CGFloat(sin(a)))
            let rootA = a + pitch * 0.92
            let root = CGPoint(x: wheelC.x + wheelR * 0.78 * CGFloat(cos(rootA)),
                               y: wheelC.y + wheelR * 0.78 * CGFloat(sin(rootA)))
            if i == 0 { path.move(to: tip) } else { path.addLine(to: tip) }
            // Steep leading face, long sloping back.
            path.addLine(to: CGPoint(x: wheelC.x + wheelR * 0.78 * CGFloat(cos(a + pitch * 0.08)),
                                     y: wheelC.y + wheelR * 0.78 * CGFloat(sin(a + pitch * 0.08))))
            path.addLine(to: root)
        }
        path.closeSubpath()
        p.metalFill(&c, path, .brass, from: CGPoint(x: wheelC.x - wheelR, y: wheelC.y - wheelR),
                    to: CGPoint(x: wheelC.x + wheelR, y: wheelC.y + wheelR))
        p.drawPin(&c, at: wheelC, radius: p.L(2.8), metal: .iron)
    }

    p.part("lever", explode: CGVector(dx: 16, dy: 10)) { c in
        let a = leverA + 0.55
        let tipR = wheelR + p.L(9)
        let tip = CGPoint(x: wheelC.x + tipR * CGFloat(cos(a)),
                          y: wheelC.y + tipR * CGFloat(sin(a)))
        p.drawRod(&c, from: wheelC, to: tip, width: p.L(3.4), metal: .wood)
        // Grip.
        let grip = Path(ellipseIn: CGRect(x: tip.x - p.L(2.6), y: tip.y - p.L(2.6),
                                          width: p.L(5.2), height: p.L(5.2)))
        p.metalFill(&c, grip, .ruby, from: tip, to: CGPoint(x: tip.x + p.L(5), y: tip.y + p.L(5)))
    }

    p.part("drivepawl", explode: CGVector(dx: 12, dy: -14)) { c in
        // Rides on the lever; hops over a tooth on the return stroke.
        let a = leverA + 0.55
        let mountR = wheelR + p.L(5)
        let mount = CGPoint(x: wheelC.x + mountR * CGFloat(cos(a - 0.18)),
                            y: wheelC.y + mountR * CGFloat(sin(a - 0.18)))
        let hop = back > 0 ? pow(sin(back * .pi), 4.0) * 3.0 : 0.0
        let tip = CGPoint(x: wheelC.x + (wheelR * 0.84 - p.L(hop)) * CGFloat(cos(a - 0.42)),
                          y: wheelC.y + (wheelR * 0.84 - p.L(hop)) * CGFloat(sin(a - 0.42)))
        p.drawRod(&c, from: mount, to: tip, width: p.L(2.4), metal: .steel)
        p.drawPin(&c, at: mount, radius: p.L(1.6), metal: .iron)
    }

    p.part("holdpawl", explode: CGVector(dx: -6, dy: -18)) { c in
        // Anchored to the frame; blocks any backward turn.
        let anchor = p.P(23, 26)
        let jig = forward > 0.97 || back > 0 ? pow(sin(back * .pi), 6.0) * 2.0 : 0.0
        let tip = CGPoint(x: wheelC.x + (wheelR * 0.85 - p.L(jig * 0.4)) * CGFloat(cos(-2.35)),
                          y: wheelC.y + (wheelR * 0.85 - p.L(jig * 0.4)) * CGFloat(sin(-2.35)))
        p.drawRod(&c, from: anchor, to: tip, width: p.L(2.4), metal: .copper)
        p.drawPin(&c, at: anchor, radius: p.L(1.8), metal: .iron)
        p.drawSpring(&c, from: CGPoint(x: anchor.x - p.L(1), y: anchor.y - p.L(4)),
                     to: CGPoint(x: anchor.x + p.L(6), y: anchor.y - p.L(1)),
                     coils: 3, amplitude: p.L(1.2))
    }
}

// MARK: - Wiper Linkage (four-bar)

func mechDrawFourBar(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2
    let crankC = p.P(24, 78)
    let crankR = p.L(6.5)
    let pivot1 = p.P(52, 78)
    let pivot2 = p.P(78, 78)
    let rockerLen = p.L(11)
    let couplerLen = p.L(25)

    let pin = CGPoint(x: crankC.x + crankR * CGFloat(cos(spin)),
                      y: crankC.y + crankR * CGFloat(sin(spin)))

    // Circle intersection: rocker tip lies on both the rocker and coupler circles.
    let dx = pin.x - pivot1.x, dy = pin.y - pivot1.y
    let d = max(sqrt(dx * dx + dy * dy), 0.001)
    let a = (rockerLen * rockerLen - couplerLen * couplerLen + d * d) / (2 * d)
    let h = sqrt(max(rockerLen * rockerLen - a * a, 0))
    let mx = pivot1.x + a * dx / d, my = pivot1.y + a * dy / d
    // Upper intersection (negative y offset).
    let tip1 = CGPoint(x: mx + h * dy / d, y: my - h * dx / d)
    let armAngle = atan2(tip1.y - pivot1.y, tip1.x - pivot1.x)
    let tip2 = CGPoint(x: pivot2.x + rockerLen * CGFloat(cos(armAngle)),
                       y: pivot2.y + rockerLen * CGFloat(sin(armAngle)))

    // Windscreen sweep hints.
    p.part("screen") { c in
        for pv in [pivot1, pivot2] {
            var arc = Path()
            arc.addArc(center: pv, radius: p.L(34), startAngle: .radians(-2.5),
                       endAngle: .radians(-0.6), clockwise: false)
            c.stroke(arc, with: .color(CogTheme.gridLine.opacity(0.4)),
                     style: StrokeStyle(lineWidth: p.thinLine, dash: [p.L(1.6), p.L(2)]))
        }
    }

    p.part("crank", explode: CGVector(dx: -14, dy: 10)) { c in
        let disc = Path(ellipseIn: CGRect(x: crankC.x - crankR - p.L(2.4), y: crankC.y - crankR - p.L(2.4),
                                          width: (crankR + p.L(2.4)) * 2, height: (crankR + p.L(2.4)) * 2))
        p.metalFill(&c, disc, .iron, from: CGPoint(x: crankC.x - crankR, y: crankC.y - crankR),
                    to: CGPoint(x: crankC.x + crankR, y: crankC.y + crankR))
        p.drawRod(&c, from: crankC, to: pin, width: p.L(2.8), metal: .brass)
        p.drawPin(&c, at: crankC, radius: p.L(2), metal: .steel)
        p.drawArrowArc(&c, center: crankC, radius: crankR + p.L(5),
                       from: 2.6, to: 3.9, color: CogTheme.gold.opacity(0.9))
    }

    p.part("coupler", explode: CGVector(dx: 0, dy: 16)) { c in
        p.drawRod(&c, from: pin, to: tip1, width: p.L(2.6), metal: .steel)
        p.drawPin(&c, at: pin, radius: p.L(1.7), metal: .iron)
    }

    p.part("rockers", explode: CGVector(dx: 0, dy: -6)) { c in
        p.drawRod(&c, from: pivot1, to: tip1, width: p.L(3), metal: .copper)
        p.drawRod(&c, from: pivot2, to: tip2, width: p.L(3), metal: .copper)
        p.drawPin(&c, at: pivot1, radius: p.L(2.2), metal: .iron)
        p.drawPin(&c, at: pivot2, radius: p.L(2.2), metal: .iron)
    }

    p.part("link", explode: CGVector(dx: 0, dy: -14)) { c in
        p.drawRod(&c, from: tip1, to: tip2, width: p.L(2.2), metal: .steel)
        p.drawPin(&c, at: tip1, radius: p.L(1.6), metal: .iron)
        p.drawPin(&c, at: tip2, radius: p.L(1.6), metal: .iron)
    }

    p.part("blades", explode: CGVector(dx: 8, dy: -18)) { c in
        for pv in [pivot1, pivot2] {
            let bladeLen = p.L(30)
            let end = CGPoint(x: pv.x + bladeLen * CGFloat(cos(armAngle)),
                              y: pv.y + bladeLen * CGFloat(sin(armAngle)))
            p.drawRod(&c, from: pv, to: end, width: p.L(1.8), metal: .iron)
            // Rubber blade.
            let bStart = CGPoint(x: pv.x + bladeLen * 0.3 * CGFloat(cos(armAngle)),
                                 y: pv.y + bladeLen * 0.3 * CGFloat(sin(armAngle)))
            var rubber = Path()
            rubber.move(to: bStart)
            rubber.addLine(to: end)
            c.stroke(rubber, with: .color(mechInk.opacity(0.9)), lineWidth: p.line * 2.6)
        }
    }
}
