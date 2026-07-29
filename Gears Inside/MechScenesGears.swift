import SwiftUI

// MARK: - Spur Gear Train

func mechDrawGearTrain(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2

    p.part("frame", explode: CGVector(dx: 0, dy: 18)) { c in
        let bar = Path(roundedRect: CGRect(x: p.P(14, 48).x, y: p.P(14, 48).y,
                                           width: p.L(72), height: p.L(8)),
                       cornerRadius: p.L(2))
        p.metalFill(&c, bar, .wood, from: p.P(14, 48), to: p.P(86, 56))
        for x in [33.0, 63.0] {
            let boss = Path(ellipseIn: CGRect(x: p.P(x - 3, 49).x, y: p.P(x - 3, 49).y,
                                              width: p.L(6), height: p.L(6)))
            p.metalFill(&c, boss, .iron, from: p.P(x - 3, 49), to: p.P(x + 3, 55))
        }
    }

    p.part("driver", explode: CGVector(dx: -16, dy: -6)) { c in
        p.drawGear(&c, center: p.P(33, 52), teeth: 24, outer: p.L(20),
                   rotation: spin, metal: .brass, holes: 5)
        p.drawArrowArc(&c, center: p.P(33, 52), radius: p.L(24),
                       from: -1.9, to: -0.9, color: CogTheme.gold.opacity(0.85))
    }

    p.part("driven", explode: CGVector(dx: 16, dy: -6)) { c in
        // Half-tooth offset keeps the teeth visually meshed.
        p.drawGear(&c, center: p.P(63.4, 52), teeth: 12, outer: p.L(10.6),
                   rotation: -spin * 2 + .pi / 12, metal: .copper, holes: 3)
        p.drawArrowArc(&c, center: p.P(63.4, 52), radius: p.L(14),
                       from: -1.2, to: -2.6, color: CogTheme.tealLight.opacity(0.9))
    }

    p.part("shafts", explode: CGVector(dx: 0, dy: -18)) { c in
        p.drawPin(&c, at: p.P(33, 52), radius: p.L(2.6), metal: .iron)
        p.drawPin(&c, at: p.P(63.4, 52), radius: p.L(2.0), metal: .iron)
    }

    p.part("callout") { c in
        let text = Text("24 : 12  —  small turns twice as fast")
            .font(CogTheme.mono(11)).foregroundColor(CogTheme.gridLine)
        c.draw(c.resolve(text), at: p.P(50, 86), anchor: .center)
    }
}

// MARK: - Rack and Pinion

func mechDrawRackPinion(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let sway = sin(t * .pi * 2)                        // -1...1
    let rot = sway * 1.15                              // pinion rotation
    let pitchR = 14.0
    let rackShift = -rot * pitchR                      // rack slide, scene units

    p.part("rails", explode: CGVector(dx: 0, dy: 16)) { c in
        for y in [57.5, 68.5] {
            let rail = Path(roundedRect: CGRect(x: p.P(10, y).x, y: p.P(10, y).y,
                                                width: p.L(80), height: p.L(2.2)),
                            cornerRadius: p.L(1.1))
            p.metalFill(&c, rail, .iron, from: p.P(10, y), to: p.P(90, y + 2.2))
        }
    }

    p.part("rack", explode: CGVector(dx: 0, dy: 10)) { c in
        let bar = Path(roundedRect: CGRect(x: p.P(6 + rackShift, 60).x, y: p.P(6, 60).y,
                                           width: p.L(88), height: p.L(8)),
                       cornerRadius: p.L(1.4))
        p.metalFill(&c, bar, .steel, from: p.P(6 + rackShift, 60), to: p.P(94 + rackShift, 68))
        // Teeth along the top edge.
        let pitch = 2 * Double.pi * pitchR / 16
        var teeth = Path()
        var x = -10.0 + rackShift.truncatingRemainder(dividingBy: pitch)
        while x < 108 {
            teeth.move(to: p.P(x, 60))
            teeth.addLine(to: p.P(x + pitch * 0.28, 56.6))
            teeth.addLine(to: p.P(x + pitch * 0.55, 56.6))
            teeth.addLine(to: p.P(x + pitch * 0.8, 60))
            x += pitch
        }
        teeth.closeSubpath()
        c.fill(teeth, with: .color(MechMetal.steel.base))
        c.stroke(teeth, with: .color(mechInk.opacity(0.8)), lineWidth: p.thinLine)
    }

    p.part("pinion", explode: CGVector(dx: 0, dy: -16)) { c in
        p.drawGear(&c, center: p.P(50, 42), teeth: 16, outer: p.L(15.4),
                   rotation: rot + .pi / 16, metal: .brass, holes: 4)
    }

    p.part("shaft", explode: CGVector(dx: 16, dy: -10)) { c in
        p.drawPin(&c, at: p.P(50, 42), radius: p.L(3), metal: .iron)
        // Steering-column hint.
        p.drawRod(&c, from: p.P(50, 42), to: p.P(66, 22), width: p.L(2.6), metal: .iron)
        let wheelC = p.P(69, 18.5)
        let wheel = Path(ellipseIn: CGRect(x: wheelC.x - p.L(7), y: wheelC.y - p.L(4.4),
                                           width: p.L(14), height: p.L(8.8)))
        c.stroke(wheel, with: .color(MechMetal.wood.base), lineWidth: p.line * 2.2)
        c.stroke(wheel, with: .color(mechInk.opacity(0.7)), lineWidth: p.thinLine)
    }
}

// MARK: - Worm Gear

func mechDrawWormGear(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2 * 6                        // worm spins fast
    let wheelRot = t * .pi * 2 * 6 / 24               // wheel creeps: one tooth per rev

    p.part("inshaft", explode: CGVector(dx: -16, dy: -8)) { c in
        p.drawRod(&c, from: p.P(12, 30), to: p.P(30, 30), width: p.L(3), metal: .iron)
        // Crank handle on the input.
        let a = spin
        let hub = p.P(12, 30)
        let handleEnd = CGPoint(x: hub.x + p.L(6.5) * CGFloat(cos(a)),
                                y: hub.y + p.L(6.5) * CGFloat(sin(a)) * 0.35)
        p.drawRod(&c, from: hub, to: handleEnd, width: p.L(2), metal: .brass)
        p.drawPin(&c, at: handleEnd, radius: p.L(1.7), metal: .ruby)
    }

    p.part("worm", explode: CGVector(dx: 0, dy: -16)) { c in
        let body = Path(roundedRect: CGRect(x: p.P(30, 24).x, y: p.P(30, 24).y,
                                            width: p.L(40), height: p.L(13)),
                        cornerRadius: p.L(6))
        p.metalFill(&c, body, .steel, from: p.P(30, 24), to: p.P(70, 37))
        // Screw threads slide along as it spins.
        let period = 6.0
        var x = 28.0 + (spin / (.pi * 2) * period).truncatingRemainder(dividingBy: period)
        var threads = Path()
        while x < 70 {
            let x0 = max(x, 30.5), x1 = min(x + 4.4, 69.5)
            if x1 > x0 {
                threads.move(to: p.P(x0, 36))
                threads.addLine(to: p.P(x1, 25))
            }
            x += period
        }
        c.stroke(threads, with: .color(mechInk.opacity(0.75)), lineWidth: p.line * 1.3)
    }

    p.part("wheel", explode: CGVector(dx: 0, dy: 14)) { c in
        p.drawGear(&c, center: p.P(50, 60), teeth: 24, outer: p.L(21),
                   rotation: wheelRot, metal: .brass, holes: 6)
    }

    p.part("outshaft", explode: CGVector(dx: 16, dy: 10)) { c in
        p.drawPin(&c, at: p.P(50, 60), radius: p.L(3.2), metal: .iron)
    }

    p.part("callout") { c in
        let text = Text("24 worm turns = 1 wheel turn")
            .font(CogTheme.mono(11)).foregroundColor(CogTheme.gridLine)
        c.draw(c.resolve(text), at: p.P(50, 92), anchor: .center)
    }
}

// MARK: - Planetary Gearset

func mechDrawPlanetary(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let sunRot = t * .pi * 2
    let carrierRot = sunRot * 12.0 / 42.0             // ring fixed: Zs/(Zs+Zr)
    let planetSelf = carrierRot - (sunRot - carrierRot) * 12.0 / 9.0
    let center = p.P(50, 50)
    let orbitR = 17.0

    p.part("ring", explode: CGVector(dx: 0, dy: 0)) { c in
        // Fixed internal ring gear: annulus with inward teeth.
        let outer = Path(ellipseIn: CGRect(x: center.x - p.L(31), y: center.y - p.L(31),
                                           width: p.L(62), height: p.L(62)))
        let inner = Path(ellipseIn: CGRect(x: center.x - p.L(26.5), y: center.y - p.L(26.5),
                                           width: p.L(53), height: p.L(53)))
        var ringPath = outer
        ringPath.addPath(inner)
        c.fill(ringPath, with: .linearGradient(
            Gradient(colors: [MechMetal.iron.light, MechMetal.iron.base, MechMetal.iron.dark]),
            startPoint: CGPoint(x: center.x - p.L(31), y: center.y - p.L(31)),
            endPoint: CGPoint(x: center.x + p.L(31), y: center.y + p.L(31))),
               style: FillStyle(eoFill: true))
        c.stroke(outer, with: .color(mechInk.opacity(0.85)), lineWidth: p.line)
        c.stroke(inner, with: .color(mechInk.opacity(0.85)), lineWidth: p.line)
        // Inward-facing teeth.
        for i in 0..<30 {
            let a = Double(i) * .pi * 2 / 30
            var tooth = Path()
            let r0 = p.L(26.5), r1 = p.L(24.2)
            let w = 0.055
            tooth.move(to: CGPoint(x: center.x + r0 * CGFloat(cos(a - w)),
                                   y: center.y + r0 * CGFloat(sin(a - w))))
            tooth.addLine(to: CGPoint(x: center.x + r1 * CGFloat(cos(a - w * 0.5)),
                                      y: center.y + r1 * CGFloat(sin(a - w * 0.5))))
            tooth.addLine(to: CGPoint(x: center.x + r1 * CGFloat(cos(a + w * 0.5)),
                                      y: center.y + r1 * CGFloat(sin(a + w * 0.5))))
            tooth.addLine(to: CGPoint(x: center.x + r0 * CGFloat(cos(a + w)),
                                      y: center.y + r0 * CGFloat(sin(a + w))))
            tooth.closeSubpath()
            c.fill(tooth, with: .color(MechMetal.iron.base))
            c.stroke(tooth, with: .color(mechInk.opacity(0.6)), lineWidth: p.thinLine)
        }
    }

    p.part("carrier", explode: CGVector(dx: 0, dy: 20)) { c in
        for i in 0..<3 {
            let a = carrierRot + Double(i) * .pi * 2 / 3
            let end = CGPoint(x: center.x + p.L(orbitR) * CGFloat(cos(a)),
                              y: center.y + p.L(orbitR) * CGFloat(sin(a)))
            p.drawRod(&c, from: center, to: end, width: p.L(3.4), metal: .wood)
        }
        p.drawPin(&c, at: center, radius: p.L(2.2), metal: .iron)
    }

    p.part("planets", explode: CGVector(dx: 14, dy: -14)) { c in
        for i in 0..<3 {
            let a = carrierRot + Double(i) * .pi * 2 / 3
            let pc = CGPoint(x: center.x + p.L(orbitR) * CGFloat(cos(a)),
                             y: center.y + p.L(orbitR) * CGFloat(sin(a)))
            p.drawGear(&c, center: pc, teeth: 9, outer: p.L(8.2),
                       rotation: planetSelf + Double(i), metal: .copper, holes: 0)
            p.drawPin(&c, at: pc, radius: p.L(1.5), metal: .iron)
        }
    }

    p.part("sun", explode: CGVector(dx: -14, dy: -14)) { c in
        p.drawGear(&c, center: center, teeth: 12, outer: p.L(10),
                   rotation: sunRot, metal: .gold, holes: 0)
        p.drawArrowArc(&c, center: center, radius: p.L(13),
                       from: -2.0, to: -1.0, color: CogTheme.gold.opacity(0.9))
    }
}
