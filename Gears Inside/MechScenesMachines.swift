import SwiftUI

// MARK: - Anchor Escapement

func mechDrawEscapement(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let pivot = p.P(50, 20)
    let swing = 0.30 * sin(t * .pi * 2)
    let teethN = 15
    let pitch = Double.pi * 2 / Double(teethN)
    // The wheel advances half a tooth as each pallet releases.
    let stepA = mechSmooth(mechSeg(t, 0.20, 0.30))
    let stepB = mechSmooth(mechSeg(t, 0.70, 0.80))
    let wheelRot = pitch * 0.5 * (stepA + stepB)
    let wheelC = p.P(50, 52)
    let wheelR = p.L(15)

    p.part("frame", explode: CGVector(dx: 0, dy: -16)) { c in
        let plate = Path(roundedRect: CGRect(x: p.P(38, 14).x, y: p.P(38, 14).y,
                                             width: p.L(24), height: p.L(7)),
                         cornerRadius: p.L(2))
        p.metalFill(&c, plate, .wood, from: p.P(38, 14), to: p.P(62, 21))
    }

    p.part("drive", explode: CGVector(dx: -18, dy: 0)) { c in
        // Weighted cord powers the wheel; chain dashes crawl downward.
        var cord = Path()
        cord.move(to: p.P(28, 52))
        cord.addLine(to: p.P(28, 78))
        let phase = (t * p.L(4)).truncatingRemainder(dividingBy: p.L(4))
        c.stroke(cord, with: .color(MechMetal.iron.base),
                 style: StrokeStyle(lineWidth: p.line * 1.3, dash: [p.L(2), p.L(2)],
                                    dashPhase: -phase))
        p.drawRod(&c, from: p.P(28, 52), to: wheelC, width: p.L(2), metal: .iron)
        let weight = Path(roundedRect: CGRect(x: p.P(24.5, 78).x, y: p.P(24.5, 78).y,
                                              width: p.L(7), height: p.L(10)),
                          cornerRadius: p.L(1.6))
        p.metalFill(&c, weight, .brass, from: p.P(24.5, 78), to: p.P(31.5, 88))
    }

    p.part("escapewheel", explode: CGVector(dx: 14, dy: 8)) { c in
        var path = Path()
        for i in 0..<teethN {
            let a = wheelRot + Double(i) * pitch - .pi / 2
            let tip = CGPoint(x: wheelC.x + wheelR * CGFloat(cos(a)),
                              y: wheelC.y + wheelR * CGFloat(sin(a)))
            if i == 0 { path.move(to: tip) } else { path.addLine(to: tip) }
            path.addLine(to: CGPoint(x: wheelC.x + wheelR * 0.72 * CGFloat(cos(a + pitch * 0.15)),
                                     y: wheelC.y + wheelR * 0.72 * CGFloat(sin(a + pitch * 0.15))))
            path.addLine(to: CGPoint(x: wheelC.x + wheelR * 0.72 * CGFloat(cos(a + pitch * 0.85)),
                                     y: wheelC.y + wheelR * 0.72 * CGFloat(sin(a + pitch * 0.85))))
        }
        path.closeSubpath()
        p.metalFill(&c, path, .brass, from: CGPoint(x: wheelC.x - wheelR, y: wheelC.y - wheelR),
                    to: CGPoint(x: wheelC.x + wheelR, y: wheelC.y + wheelR))
        p.drawPin(&c, at: wheelC, radius: p.L(2.2), metal: .iron)
    }

    p.part("anchor", explode: CGVector(dx: 0, dy: -14)) { c in
        // Curved yoke with two pallets, rocking with the pendulum.
        var y = ctx
        y.opacity = Double(opt.alpha(for: "anchor"))
        y.translateBy(x: pivot.x, y: pivot.y)
        y.rotate(by: .radians(-swing * 0.55))
        y.translateBy(x: -pivot.x, y: -pivot.y)
        var yoke = Path()
        let spanY = wheelC.y - wheelR - p.L(2.5)
        yoke.move(to: CGPoint(x: wheelC.x - wheelR * 0.85, y: spanY + p.L(6)))
        yoke.addQuadCurve(to: CGPoint(x: wheelC.x + wheelR * 0.85, y: spanY + p.L(6)),
                          control: CGPoint(x: wheelC.x, y: spanY - p.L(8)))
        y.stroke(yoke, with: .color(MechMetal.steel.base), lineWidth: p.line * 3)
        y.stroke(yoke, with: .color(mechInk.opacity(0.8)), lineWidth: p.thinLine)
        // Pallets.
        for side in [-1.0, 1.0] {
            var pal = Path()
            let px = wheelC.x + wheelR * 0.85 * CGFloat(side)
            pal.move(to: CGPoint(x: px, y: spanY + p.L(6)))
            pal.addLine(to: CGPoint(x: px + p.L(1.6) * CGFloat(side), y: spanY + p.L(11)))
            y.stroke(pal, with: .color(MechMetal.steel.dark), lineWidth: p.line * 2)
        }
        // Link from pivot down to yoke.
        var stem = Path()
        stem.move(to: pivot)
        stem.addLine(to: CGPoint(x: wheelC.x, y: spanY - p.L(2)))
        y.stroke(stem, with: .color(MechMetal.steel.base), lineWidth: p.line * 1.6)
        p.drawPin(&y, at: pivot, radius: p.L(1.8), metal: .iron)
    }

    p.part("pendulum", explode: CGVector(dx: 0, dy: 18)) { c in
        var g = ctx
        g.opacity = Double(opt.alpha(for: "pendulum"))
        g.translateBy(x: pivot.x, y: pivot.y)
        g.rotate(by: .radians(swing))
        g.translateBy(x: -pivot.x, y: -pivot.y)
        let rodEnd = CGPoint(x: pivot.x, y: pivot.y + p.L(62))
        var rod = Path()
        rod.move(to: pivot)
        rod.addLine(to: rodEnd)
        g.stroke(rod, with: .color(MechMetal.wood.base), lineWidth: p.line * 2.2)
        g.stroke(rod, with: .color(mechInk.opacity(0.7)), lineWidth: p.thinLine)
        let bob = Path(ellipseIn: CGRect(x: rodEnd.x - p.L(6.5), y: rodEnd.y - p.L(6.5),
                                         width: p.L(13), height: p.L(13)))
        g.fill(bob, with: .linearGradient(
            Gradient(colors: [MechMetal.gold.light, MechMetal.gold.base, MechMetal.gold.dark]),
            startPoint: CGPoint(x: rodEnd.x - p.L(6), y: rodEnd.y - p.L(6)),
            endPoint: CGPoint(x: rodEnd.x + p.L(6), y: rodEnd.y + p.L(6))))
        g.stroke(bob, with: .color(mechInk.opacity(0.85)), lineWidth: p.line)
    }
}

// MARK: - Four-Stroke Engine

func mechDrawFourStroke(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let crankA = t * .pi * 4                          // two revolutions per cycle
    let crankC = p.P(50, 74)
    let crankR = p.L(8)
    let rodLen = p.L(19)
    let pin = CGPoint(x: crankC.x + crankR * CGFloat(sin(crankA)),
                      y: crankC.y + crankR * CGFloat(cos(crankA)))
    let dxp = pin.x - crankC.x
    let lift = sqrt(max(rodLen * rodLen - dxp * dxp, 0))
    let pistonY = pin.y - lift                        // piston pin y
    let headY = p.P(50, 22).y
    let boreL = p.P(41, 0).x, boreR = p.P(59, 0).x

    let intakeOpen = mechPulse(t, 0.0, 0.27)
    let exhaustOpen = mechPulse(t, 0.73, 1.0)
    let sparkFlash = mechPulse(t, 0.49, 0.545)

    // Gas charge above the piston.
    p.part("charge") { c in
        let top = headY
        let bottom = pistonY - p.L(5)
        guard bottom > top + 1 else { return }
        let rect = CGRect(x: boreL, y: top, width: boreR - boreL, height: bottom - top)
        let color: Color
        if t < 0.27 { color = MechMetal.sky.base.opacity(0.30 + 0.2 * intakeOpen) }
        else if t < 0.5 { color = MechMetal.sky.base.opacity(0.55) }
        else if t < 0.75 { color = Color.orange.opacity(0.55 - 0.3 * mechSeg(t, 0.5, 0.75)) }
        else { color = Color.gray.opacity(0.4 - 0.25 * exhaustOpen) }
        c.fill(Path(rect), with: .color(color))
    }

    p.part("cylinder", explode: CGVector(dx: 18, dy: -4)) { c in
        for x in [boreL - p.L(2.6), boreR] {
            let wall = Path(roundedRect: CGRect(x: x, y: headY - p.L(4), width: p.L(2.6),
                                                height: p.P(0, 64).y - headY + p.L(4)),
                            cornerRadius: p.L(1))
            p.metalFill(&c, wall, .iron, from: CGPoint(x: x, y: headY),
                        to: CGPoint(x: x + p.L(2.6), y: p.P(0, 64).y))
        }
        // Head with valve ports.
        var head = Path()
        head.move(to: CGPoint(x: boreL - p.L(2.6), y: headY))
        head.addLine(to: CGPoint(x: boreL + p.L(3.4), y: headY - p.L(6)))
        head.addLine(to: CGPoint(x: boreR - p.L(3.4), y: headY - p.L(6)))
        head.addLine(to: CGPoint(x: boreR + p.L(2.6), y: headY))
        p.flatFill(&c, head, MechMetal.iron.base)
    }

    p.part("intakevalve", explode: CGVector(dx: -16, dy: -10)) { c in
        let drop = p.L(3.2) * CGFloat(mechSmooth(intakeOpen))
        let vx = boreL + p.L(4.4)
        p.drawRod(&c, from: CGPoint(x: vx, y: headY - p.L(12)),
                  to: CGPoint(x: vx, y: headY - p.L(2) + drop), width: p.L(1.6), metal: .steel)
        var disc = Path()
        disc.addEllipse(in: CGRect(x: vx - p.L(3.4), y: headY - p.L(3) + drop,
                                   width: p.L(6.8), height: p.L(2.4)))
        p.metalFill(&c, disc, .sky, from: CGPoint(x: vx - p.L(3), y: headY + drop),
                    to: CGPoint(x: vx + p.L(3), y: headY + p.L(2) + drop))
    }

    p.part("exhaustvalve", explode: CGVector(dx: 16, dy: -10)) { c in
        let drop = p.L(3.2) * CGFloat(mechSmooth(exhaustOpen))
        let vx = boreR - p.L(4.4)
        p.drawRod(&c, from: CGPoint(x: vx, y: headY - p.L(12)),
                  to: CGPoint(x: vx, y: headY - p.L(2) + drop), width: p.L(1.6), metal: .steel)
        var disc = Path()
        disc.addEllipse(in: CGRect(x: vx - p.L(3.4), y: headY - p.L(3) + drop,
                                   width: p.L(6.8), height: p.L(2.4)))
        p.metalFill(&c, disc, .ruby, from: CGPoint(x: vx - p.L(3), y: headY + drop),
                    to: CGPoint(x: vx + p.L(3), y: headY + p.L(2) + drop))
    }

    p.part("spark", explode: CGVector(dx: 0, dy: -16)) { c in
        let sx = p.P(50, 0).x
        let plug = Path(roundedRect: CGRect(x: sx - p.L(1.6), y: headY - p.L(11),
                                            width: p.L(3.2), height: p.L(6)),
                        cornerRadius: p.L(0.8))
        p.metalFill(&c, plug, .steel, from: CGPoint(x: sx, y: headY - p.L(11)),
                    to: CGPoint(x: sx, y: headY - p.L(5)))
        if sparkFlash > 0 {
            let flash = CGFloat(sparkFlash)
            for i in 0..<6 {
                let a = Double(i) * .pi / 3
                var ray = Path()
                ray.move(to: CGPoint(x: sx, y: headY - p.L(3)))
                ray.addLine(to: CGPoint(x: sx + p.L(4.5) * flash * CGFloat(cos(a)),
                                        y: headY - p.L(3) + p.L(4.5) * flash * CGFloat(sin(a))))
                c.stroke(ray, with: .color(CogTheme.gold.opacity(Double(flash))),
                         lineWidth: p.line * 1.4)
            }
        }
    }

    p.part("piston", explode: CGVector(dx: -18, dy: 0)) { c in
        let r = CGRect(x: boreL + p.L(0.4), y: pistonY - p.L(5),
                       width: boreR - boreL - p.L(0.8), height: p.L(10))
        let body = Path(roundedRect: r, cornerRadius: p.L(1.2))
        p.metalFill(&c, body, .steel, from: CGPoint(x: r.minX, y: r.minY),
                    to: CGPoint(x: r.maxX, y: r.maxY))
        for i in 0..<2 {
            var ring = Path()
            let ry = r.minY + p.L(1.6) + CGFloat(i) * p.L(1.8)
            ring.move(to: CGPoint(x: r.minX + p.L(0.6), y: ry))
            ring.addLine(to: CGPoint(x: r.maxX - p.L(0.6), y: ry))
            c.stroke(ring, with: .color(mechInk.opacity(0.55)), lineWidth: p.thinLine)
        }
    }

    p.part("rod", explode: CGVector(dx: 0, dy: 14)) { c in
        p.drawRod(&c, from: CGPoint(x: pin.x, y: pistonY),
                  to: pin, width: p.L(2.8), metal: .copper)
        p.drawPin(&c, at: CGPoint(x: pin.x, y: pistonY), radius: p.L(1.7), metal: .iron)
    }

    p.part("crank", explode: CGVector(dx: 0, dy: 18)) { c in
        // Flywheel.
        let fly = Path(ellipseIn: CGRect(x: crankC.x - p.L(13), y: crankC.y - p.L(13),
                                         width: p.L(26), height: p.L(26)))
        p.metalFill(&c, fly, .iron, from: CGPoint(x: crankC.x - p.L(13), y: crankC.y - p.L(13)),
                    to: CGPoint(x: crankC.x + p.L(13), y: crankC.y + p.L(13)))
        for i in 0..<4 {
            let a = crankA + Double(i) * .pi / 2
            var spoke = Path()
            spoke.move(to: crankC)
            spoke.addLine(to: CGPoint(x: crankC.x + p.L(11.5) * CGFloat(cos(a)),
                                      y: crankC.y + p.L(11.5) * CGFloat(sin(a))))
            c.stroke(spoke, with: .color(MechMetal.iron.dark), lineWidth: p.line * 1.5)
        }
        p.drawRod(&c, from: crankC, to: pin, width: p.L(3.4), metal: .brass)
        p.drawPin(&c, at: pin, radius: p.L(1.8), metal: .iron)
        p.drawPin(&c, at: crankC, radius: p.L(2.4), metal: .steel)
    }
}

// MARK: - Steam Locomotive Drive

func mechDrawSteamWheel(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let spin = t * .pi * 2
    let centers = [p.P(30, 62), p.P(55, 62), p.P(80, 62)]
    let wheelR = p.L(12.5)
    let pinR = p.L(6)
    let pins = centers.map { c in
        CGPoint(x: c.x + pinR * CGFloat(cos(spin)), y: c.y + pinR * CGFloat(sin(spin)))
    }
    let rodLen = p.L(26)
    let dyp = pins[0].y - p.P(0, 62).y
    let reach = sqrt(max(rodLen * rodLen - dyp * dyp, 0))
    let crossX = pins[0].x - reach
    let guideY = p.P(0, 62).y

    p.part("framebar", explode: CGVector(dx: 0, dy: -18)) { c in
        let bar = Path(roundedRect: CGRect(x: p.P(4, 44).x, y: p.P(4, 44).y,
                                           width: p.L(92), height: p.L(5)),
                       cornerRadius: p.L(1.4))
        p.metalFill(&c, bar, .ruby, from: p.P(4, 44), to: p.P(96, 49))
        var rail = Path()
        rail.move(to: p.P(2, 75.4))
        rail.addLine(to: p.P(98, 75.4))
        c.stroke(rail, with: .color(MechMetal.iron.dark), lineWidth: p.line * 2)
    }

    p.part("wheels", explode: CGVector(dx: 0, dy: 16)) { c in
        for center in centers {
            let tire = Path(ellipseIn: CGRect(x: center.x - wheelR, y: center.y - wheelR,
                                              width: wheelR * 2, height: wheelR * 2))
            p.metalFill(&c, tire, .iron, from: CGPoint(x: center.x - wheelR, y: center.y - wheelR),
                        to: CGPoint(x: center.x + wheelR, y: center.y + wheelR))
            let rim = Path(ellipseIn: CGRect(x: center.x - wheelR + p.line * 2.4,
                                             y: center.y - wheelR + p.line * 2.4,
                                             width: (wheelR - p.line * 2.4) * 2,
                                             height: (wheelR - p.line * 2.4) * 2))
            c.fill(rim, with: .color(MechMetal.ruby.base))
            c.stroke(rim, with: .color(mechInk.opacity(0.7)), lineWidth: p.thinLine)
            for i in 0..<8 {
                let a = spin + Double(i) * .pi / 4
                var spoke = Path()
                spoke.move(to: center)
                spoke.addLine(to: CGPoint(x: center.x + (wheelR - p.line * 2.4) * CGFloat(cos(a)),
                                          y: center.y + (wheelR - p.line * 2.4) * CGFloat(sin(a))))
                c.stroke(spoke, with: .color(MechMetal.gold.base), lineWidth: p.line * 1.2)
            }
            p.drawPin(&c, at: center, radius: p.L(2), metal: .steel)
        }
    }

    p.part("siderod", explode: CGVector(dx: 0, dy: 20)) { c in
        p.drawRod(&c, from: pins[0], to: pins[2], width: p.L(2.6), metal: .steel)
        for pin in pins { p.drawPin(&c, at: pin, radius: p.L(1.7), metal: .brass) }
    }

    p.part("crosshead", explode: CGVector(dx: 0, dy: -14)) { c in
        // Guide bars.
        for off in [-3.4, 3.4] {
            var g = Path()
            g.move(to: CGPoint(x: p.P(6, 0).x, y: guideY + p.L(off)))
            g.addLine(to: CGPoint(x: p.P(34, 0).x, y: guideY + p.L(off)))
            c.stroke(g, with: .color(MechMetal.iron.base), lineWidth: p.line * 1.3)
        }
        let block = Path(roundedRect: CGRect(x: crossX - p.L(3.4), y: guideY - p.L(3),
                                             width: p.L(6.8), height: p.L(6)),
                         cornerRadius: p.L(1))
        p.metalFill(&c, block, .brass, from: CGPoint(x: crossX, y: guideY - p.L(3)),
                    to: CGPoint(x: crossX, y: guideY + p.L(3)))
    }

    p.part("mainrod", explode: CGVector(dx: 8, dy: -20)) { c in
        p.drawRod(&c, from: CGPoint(x: crossX, y: guideY), to: pins[0],
                  width: p.L(2.4), metal: .copper)
    }

    p.part("piston", explode: CGVector(dx: -16, dy: 0)) { c in
        // Cylinder shell.
        let cyl = Path(roundedRect: CGRect(x: p.P(3, 0).x, y: guideY - p.L(6.5),
                                           width: p.L(14), height: p.L(13)),
                       cornerRadius: p.L(2))
        p.metalFill(&c, cyl, .iron, from: CGPoint(x: p.P(3, 0).x, y: guideY - p.L(6)),
                    to: CGPoint(x: p.P(17, 0).x, y: guideY + p.L(6)))
        // Piston rod from cylinder to crosshead.
        let rodStart = CGPoint(x: p.P(9, 0).x + (crossX - p.P(23, 0).x) * 0.28, y: guideY)
        p.drawRod(&c, from: rodStart, to: CGPoint(x: crossX, y: guideY),
                  width: p.L(1.8), metal: .steel)
        // Steam puffs.
        let puffPhase = (t * 2).truncatingRemainder(dividingBy: 1)
        let fade = sin(puffPhase * .pi)
        let puffC = CGPoint(x: p.P(10, 0).x, y: guideY - p.L(9) - p.L(6) * CGFloat(puffPhase))
        let puff = Path(ellipseIn: CGRect(x: puffC.x - p.L(3.4) * CGFloat(fade),
                                          y: puffC.y - p.L(2.4) * CGFloat(fade),
                                          width: p.L(6.8) * CGFloat(fade),
                                          height: p.L(4.8) * CGFloat(fade)))
        c.fill(puff, with: .color(Color.white.opacity(0.35 * fade)))
    }
}

// MARK: - Block and Tackle

func mechDrawBlockTackle(_ ctx: inout GraphicsContext, size: CGSize, t: Double, opt: MechRenderOptions) {
    let p = MechScenePainter(ctx, size, opt)
    let pull = mechSmooth(mechPulse(t, 0, 1))          // 0...1...0
    let loadRise = p.L(11) * CGFloat(pull)
    let upperC = p.P(50, 18)
    let sheaveR = p.L(5)
    let lowerC = CGPoint(x: upperC.x, y: p.P(50, 56).y - loadRise)
    let handY = p.P(0, 34).y + p.L(23) * CGFloat(pull)
    let travel = Double(loadRise) * 2                   // rope pulled = twice the rise

    p.part("beam", explode: CGVector(dx: 0, dy: -14)) { c in
        let beam = Path(roundedRect: CGRect(x: p.P(20, 6).x, y: p.P(20, 6).y,
                                            width: p.L(60), height: p.L(6)),
                        cornerRadius: p.L(1.6))
        p.metalFill(&c, beam, .wood, from: p.P(20, 6), to: p.P(80, 12))
        p.drawRod(&c, from: p.P(50, 12), to: CGPoint(x: upperC.x, y: upperC.y - sheaveR),
                  width: p.L(2), metal: .iron)
    }

    p.part("rope", explode: CGVector(dx: -10, dy: 0)) { c in
        var rope = Path()
        // Tie-off on the upper block, down and around the lower sheave, up over
        // the upper sheave, then out to the pulling end.
        rope.move(to: CGPoint(x: upperC.x - sheaveR, y: upperC.y))
        rope.addLine(to: CGPoint(x: lowerC.x - sheaveR, y: lowerC.y))
        rope.addArc(center: lowerC, radius: sheaveR, startAngle: .radians(.pi),
                    endAngle: .radians(0), clockwise: true)
        rope.addLine(to: CGPoint(x: upperC.x + sheaveR, y: upperC.y))
        rope.addArc(center: upperC, radius: sheaveR, startAngle: .radians(0),
                    endAngle: .radians(-.pi / 3), clockwise: true)
        let exitPt = CGPoint(x: upperC.x + sheaveR * CGFloat(cos(-Double.pi / 3)) + p.L(11),
                             y: handY)
        rope.addQuadCurve(to: exitPt,
                          control: CGPoint(x: upperC.x + p.L(13), y: (upperC.y + exitPt.y) / 2))
        c.stroke(rope, with: .color(MechMetal.wood.dark), lineWidth: p.line * 1.8)
        c.stroke(rope, with: .color(MechMetal.gold.light.opacity(0.5)),
                 style: StrokeStyle(lineWidth: p.thinLine, dash: [p.L(1.2), p.L(1.2)],
                                    dashPhase: CGFloat(-travel)))
        // Pull ring.
        let ring = Path(ellipseIn: CGRect(x: exitPt.x - p.L(2.6), y: exitPt.y,
                                          width: p.L(5.2), height: p.L(5.2)))
        p.metalFill(&c, ring, .brass, from: exitPt,
                    to: CGPoint(x: exitPt.x, y: exitPt.y + p.L(5.2)))
    }

    p.part("upperblock", explode: CGVector(dx: 14, dy: -8)) { c in
        let shell = Path(roundedRect: CGRect(x: upperC.x - sheaveR - p.L(2.4),
                                             y: upperC.y - sheaveR - p.L(2.4),
                                             width: (sheaveR + p.L(2.4)) * 2,
                                             height: (sheaveR + p.L(2.4)) * 2),
                         cornerRadius: p.L(3))
        p.metalFill(&c, shell, .wood, from: CGPoint(x: upperC.x - sheaveR, y: upperC.y - sheaveR),
                    to: CGPoint(x: upperC.x + sheaveR, y: upperC.y + sheaveR))
        let sheave = Path(ellipseIn: CGRect(x: upperC.x - sheaveR, y: upperC.y - sheaveR,
                                            width: sheaveR * 2, height: sheaveR * 2))
        p.metalFill(&c, sheave, .steel, from: CGPoint(x: upperC.x - sheaveR, y: upperC.y - sheaveR),
                    to: CGPoint(x: upperC.x + sheaveR, y: upperC.y + sheaveR))
        // Rotation marks.
        let rot = travel / Double(sheaveR)
        for i in 0..<3 {
            let a = rot + Double(i) * .pi * 2 / 3
            var mark = Path()
            mark.move(to: upperC)
            mark.addLine(to: CGPoint(x: upperC.x + sheaveR * 0.75 * CGFloat(cos(a)),
                                     y: upperC.y + sheaveR * 0.75 * CGFloat(sin(a))))
            c.stroke(mark, with: .color(mechInk.opacity(0.5)), lineWidth: p.thinLine)
        }
    }

    p.part("lowerblock", explode: CGVector(dx: 14, dy: 8)) { c in
        let shell = Path(roundedRect: CGRect(x: lowerC.x - sheaveR - p.L(2.4),
                                             y: lowerC.y - sheaveR - p.L(2.4),
                                             width: (sheaveR + p.L(2.4)) * 2,
                                             height: (sheaveR + p.L(2.4)) * 2),
                         cornerRadius: p.L(3))
        p.metalFill(&c, shell, .wood, from: CGPoint(x: lowerC.x - sheaveR, y: lowerC.y - sheaveR),
                    to: CGPoint(x: lowerC.x + sheaveR, y: lowerC.y + sheaveR))
        let sheave = Path(ellipseIn: CGRect(x: lowerC.x - sheaveR, y: lowerC.y - sheaveR,
                                            width: sheaveR * 2, height: sheaveR * 2))
        p.metalFill(&c, sheave, .steel, from: CGPoint(x: lowerC.x - sheaveR, y: lowerC.y - sheaveR),
                    to: CGPoint(x: lowerC.x + sheaveR, y: lowerC.y + sheaveR))
        let rot = -travel / Double(sheaveR)
        for i in 0..<3 {
            let a = rot + Double(i) * .pi * 2 / 3
            var mark = Path()
            mark.move(to: lowerC)
            mark.addLine(to: CGPoint(x: lowerC.x + sheaveR * 0.75 * CGFloat(cos(a)),
                                     y: lowerC.y + sheaveR * 0.75 * CGFloat(sin(a))))
            c.stroke(mark, with: .color(mechInk.opacity(0.5)), lineWidth: p.thinLine)
        }
        // Hook.
        var hook = Path()
        hook.move(to: CGPoint(x: lowerC.x, y: lowerC.y + sheaveR + p.L(2.4)))
        hook.addArc(center: CGPoint(x: lowerC.x, y: lowerC.y + sheaveR + p.L(5.4)),
                    radius: p.L(3), startAngle: .radians(-.pi / 2),
                    endAngle: .radians(.pi * 0.75), clockwise: false)
        c.stroke(hook, with: .color(MechMetal.iron.base), lineWidth: p.line * 2)
    }

    p.part("load", explode: CGVector(dx: 0, dy: 16)) { c in
        let topY = lowerC.y + sheaveR + p.L(8)
        let crate = Path(roundedRect: CGRect(x: lowerC.x - p.L(11), y: topY,
                                             width: p.L(22), height: p.L(17)),
                         cornerRadius: p.L(1.6))
        p.metalFill(&c, crate, .wood, from: CGPoint(x: lowerC.x - p.L(11), y: topY),
                    to: CGPoint(x: lowerC.x + p.L(11), y: topY + p.L(17)))
        var braces = Path()
        braces.move(to: CGPoint(x: lowerC.x - p.L(11), y: topY))
        braces.addLine(to: CGPoint(x: lowerC.x + p.L(11), y: topY + p.L(17)))
        braces.move(to: CGPoint(x: lowerC.x + p.L(11), y: topY))
        braces.addLine(to: CGPoint(x: lowerC.x - p.L(11), y: topY + p.L(17)))
        c.stroke(braces, with: .color(MechMetal.wood.dark.opacity(0.7)), lineWidth: p.thinLine * 1.4)
        // Sling up to the hook.
        var sling = Path()
        sling.move(to: CGPoint(x: lowerC.x, y: lowerC.y + sheaveR + p.L(6.2)))
        sling.addLine(to: CGPoint(x: lowerC.x, y: topY))
        c.stroke(sling, with: .color(MechMetal.wood.dark), lineWidth: p.line * 1.4)
    }

    p.part("callout") { c in
        let text = Text("pull 2 m of rope  →  lift rises 1 m, twice the force")
            .font(CogTheme.mono(10.5)).foregroundColor(CogTheme.gridLine)
        c.draw(c.resolve(text), at: p.P(50, 94), anchor: .center)
    }
}
