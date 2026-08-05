import SwiftUI

struct MechanismView: View {
    @EnvironmentObject var store: CogStore
    let spec: MechanismSpec
    var isDaily: Bool = false

    // Animation timebase: basePhase is the phase at baseDate.
    @State private var playing = true
    @State private var speed: Double = 1
    @State private var basePhase: Double = 0
    @State private var baseDate = Date()

    @State private var explodeAmount: CGFloat = 0
    @State private var showLabels = false
    @State private var selectedStage: Int? = nil
    @State private var selectedPart: String? = nil
    @State private var scrubbing = false
    @State private var scrubStartPhase: Double = 0
    @State private var scrubAccum: Double = 0
    @State private var explodeCounted = false
    @State private var showConfetti = false
    @State private var stageToken = UUID()
    @State private var appeared = false

    private var stageSpec: MechStageSpec? {
        guard let id = selectedStage else { return nil }
        return spec.stages.first { $0.id == id }
    }

    private var highlightSet: Set<String> {
        if let part = selectedPart { return [part] }
        if let stage = stageSpec { return Set(stage.highlight) }
        return []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                stagePanel
                    .aspectRatio(1.02, contentMode: .fit)
                controls
                stageStrip
                captionCard
                if let part = selectedPart, let partSpec = spec.part(part) {
                    partCard(partSpec)
                }
                aboutSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 6)
            .padding(.bottom, 30)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(spec.name)
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
            }
        }
        .onAppear {
            if !appeared {
                appeared = true
                store.mechOpened(spec.id, isDaily: isDaily)
                baseDate = Date()
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(spec.tagline)
                    .font(CogTheme.body(14, weight: .medium))
                    .foregroundColor(CogTheme.inkSoft)
                HStack(spacing: 8) {
                    CogTag(text: spec.wing.title, color: spec.wing.tint)
                    if store.isUnderstood(spec.id) {
                        CogTag(text: "Understood", color: CogTheme.leaf, filled: true)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Stage panel

    private var stagePanel: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [CogTheme.blueprintHi, CogTheme.blueprint],
                                         startPoint: .top, endPoint: .bottom))
                TimelineView(.animation(minimumInterval: 1.0 / 40.0, paused: !playing)) { tl in
                    Canvas { ctx, size in
                        drawGrid(&ctx, size: size)
                        var c = ctx
                        let phase = livePhase(tl.date)
                        let opts = MechRenderOptions(explode: explodeAmount, highlight: highlightSet)
                        spec.draw(&c, size, phase, opts)
                        drawAnchors(&ctx, size: size)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                if showConfetti {
                    CogConfettiView(seed: spec.id.hashValue & 0xFFFF)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(CogTheme.ink.opacity(0.25), lineWidth: 1.5)
            )
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .gesture(panelGesture(in: geo.size))
        }
    }

    private func drawGrid(_ ctx: inout GraphicsContext, size: CGSize) {
        let step = max(size.width, size.height) / 14
        var lines = Path()
        var x: CGFloat = 0
        while x <= size.width { lines.move(to: CGPoint(x: x, y: 0)); lines.addLine(to: CGPoint(x: x, y: size.height)); x += step }
        var y: CGFloat = 0
        while y <= size.height { lines.move(to: CGPoint(x: 0, y: y)); lines.addLine(to: CGPoint(x: size.width, y: y)); y += step }
        ctx.stroke(lines, with: .color(CogTheme.gridLine.opacity(0.13)), lineWidth: 0.7)
    }

    private func anchorPoint(_ part: MechPartSpec, size: CGSize) -> CGPoint {
        let s = min(size.width, size.height) / 100
        let ox = (size.width - 100 * s) / 2
        let oy = (size.height - 100 * s) / 2
        return CGPoint(
            x: ox + (part.anchor.x + part.explode.dx * explodeAmount) * s,
            y: oy + (part.anchor.y + part.explode.dy * explodeAmount) * s)
    }

    private func drawAnchors(_ ctx: inout GraphicsContext, size: CGSize) {
        guard showLabels || selectedPart != nil else { return }
        for part in spec.parts {
            if !showLabels && selectedPart != part.id { continue }
            let pt = anchorPoint(part, size: size)
            let selected = selectedPart == part.id
            let dotR: CGFloat = selected ? 5 : 3.5
            let dot = Path(ellipseIn: CGRect(x: pt.x - dotR, y: pt.y - dotR,
                                             width: dotR * 2, height: dotR * 2))
            ctx.fill(dot, with: .color(selected ? CogTheme.gold : CogTheme.paper.opacity(0.9)))
            ctx.stroke(dot, with: .color(CogTheme.ink.opacity(0.7)), lineWidth: 1)

            let label = Text(part.name)
                .font(CogTheme.body(10, weight: .semibold))
                .foregroundColor(CogTheme.ink)
            let resolved = ctx.resolve(label)
            let measure = resolved.measure(in: CGSize(width: 200, height: 40))
            var lx = pt.x
            let ly = pt.y - dotR - 4 - measure.height / 2
            lx = min(max(lx, measure.width / 2 + 6), size.width - measure.width / 2 - 6)
            let plate = CGRect(x: lx - measure.width / 2 - 4, y: ly - measure.height / 2 - 2,
                               width: measure.width + 8, height: measure.height + 4)
            ctx.fill(Path(roundedRect: plate, cornerRadius: 5),
                     with: .color(CogTheme.paper.opacity(selected ? 0.95 : 0.78)))
            ctx.draw(resolved, at: CGPoint(x: lx, y: ly), anchor: .center)
        }
    }

    // MARK: Gesture (scrub + tap)

    private func panelGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let dist = hypot(value.translation.width, value.translation.height)
                if !scrubbing && dist > 14 {
                    scrubbing = true
                    rebase()
                    playing = false
                    scrubStartPhase = basePhase
                    scrubAccum = 0
                }
                if scrubbing {
                    let deltaPhase = Double(value.translation.width / max(size.width, 1)) * 1.1
                    let old = basePhase
                    var next = (scrubStartPhase + deltaPhase).truncatingRemainder(dividingBy: 1)
                    if next < 0 { next += 1 }
                    if let s = stageSpec {
                        let span = s.phase.upperBound - s.phase.lowerBound
                        next = s.phase.lowerBound + (next.truncatingRemainder(dividingBy: max(span, 0.001)))
                    }
                    basePhase = next
                    baseDate = Date()
                    // Tick haptics at each quarter turn while cranking.
                    if Int(old * 4) != Int(next * 4) { CogHaptics.tick() }
                    scrubAccum = abs(Double(value.translation.width / max(size.width, 1)) * 1.1)
                }
            }
            .onEnded { value in
                if scrubbing {
                    scrubbing = false
                    if scrubAccum >= 0.5 {
                        store.crankCycled(max(1, Int(scrubAccum.rounded())))
                    }
                } else {
                    handleTap(at: value.location, size: size)
                }
            }
    }

    private func handleTap(at point: CGPoint, size: CGSize) {
        var best: (id: String, dist: CGFloat)? = nil
        for part in spec.parts {
            let pt = anchorPoint(part, size: size)
            let d = hypot(pt.x - point.x, pt.y - point.y)
            if d < 46, best == nil || d < best!.dist {
                best = (part.id, d)
            }
        }
        if let hit = best {
            if selectedPart == hit.id {
                selectedPart = nil
            } else {
                selectedPart = hit.id
                store.partInspected()
                CogHaptics.tick()
            }
        } else {
            selectedPart = nil
        }
    }

    // MARK: Timebase

    private func livePhase(_ date: Date) -> Double {
        if let s = stageSpec {
            let lower = s.phase.lowerBound
            let span = max(s.phase.upperBound - lower, 0.02)
            let dur = max(spec.cycleSeconds * span / speed, 0.15)
            guard playing else { return basePhase }
            let startFrac = min(max((basePhase - lower) / span, 0), 1)
            let f = (startFrac + date.timeIntervalSince(baseDate) / dur)
                .truncatingRemainder(dividingBy: 1)
            return lower + f * span
        }
        guard playing else { return basePhase }
        let dur = max(spec.cycleSeconds / speed, 0.3)
        var f = (basePhase + date.timeIntervalSince(baseDate) / dur)
            .truncatingRemainder(dividingBy: 1)
        if f < 0 { f += 1 }
        return f
    }

    private func rebase() {
        basePhase = livePhase(Date())
        baseDate = Date()
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                rebase()
                playing.toggle()
                if playing { baseDate = Date() }
            } label: {
                ZStack {
                    Circle().fill(CogTheme.brass)
                        .frame(width: 46, height: 46)
                        .shadow(color: CogTheme.shadow, radius: 4, y: 2)
                    if playing {
                        PauseGlyph().fill(CogTheme.card).frame(width: 20, height: 20)
                    } else {
                        PlayGlyph().fill(CogTheme.card).frame(width: 20, height: 20).offset(x: 1)
                    }
                }
            }
            .buttonStyle(.plain)

            Button {
                rebase()
                speed = speed >= 2 ? 0.5 : (speed >= 1 ? 2 : 1)
            } label: {
                Text(speed == 0.5 ? "1/2x" : (speed == 2 ? "2x" : "1x"))
                    .font(CogTheme.mono(13))
                    .foregroundColor(CogTheme.ink)
                    .frame(width: 44, height: 34)
                    .background(Capsule().fill(CogTheme.paperDeep))
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showLabels.toggle() }
            } label: {
                Text("Labels")
                    .font(CogTheme.body(13, weight: .semibold))
                    .foregroundColor(showLabels ? CogTheme.card : CogTheme.ink)
                    .frame(height: 34)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(showLabels ? CogTheme.teal : CogTheme.paperDeep))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                Text("Apart")
                    .font(CogTheme.body(12, weight: .semibold))
                    .foregroundColor(CogTheme.inkSoft)
                CogSlider(value: Binding(
                    get: { explodeAmount },
                    set: { newValue in
                        explodeAmount = newValue
                        if newValue > 0.5 && !explodeCounted {
                            explodeCounted = true
                            store.explodeUsed()
                        }
                    }))
                    .frame(maxWidth: 150)
            }
        }
    }

    // MARK: Stage strip

    private var stageStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("How it works")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
                Spacer()
                Text("\(store.stageSet(for: spec.id).count)/\(spec.stages.count) steps")
                    .font(CogTheme.mono(12))
                    .foregroundColor(CogTheme.inkSoft)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(spec.stages) { stage in
                        stageChip(stage)
                    }
                }
            }
        }
    }

    private func stageChip(_ stage: MechStageSpec) -> some View {
        let done = store.stageSet(for: spec.id).contains(stage.id)
        let active = selectedStage == stage.id
        return Button {
            selectStage(stage)
        } label: {
            HStack(spacing: 6) {
                if done {
                    CheckGlyph()
                        .stroke(active ? CogTheme.card : CogTheme.leaf,
                                style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                        .frame(width: 12, height: 12)
                } else {
                    Text("\(stage.id)")
                        .font(CogTheme.mono(12))
                        .foregroundColor(active ? CogTheme.card : CogTheme.inkSoft)
                }
                Text(stage.title)
                    .font(CogTheme.body(13, weight: .semibold))
                    .foregroundColor(active ? CogTheme.card : CogTheme.ink)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Capsule().fill(active ? spec.wing.tint : CogTheme.card)
                .shadow(color: CogTheme.shadow, radius: 3, y: 1))
        }
        .buttonStyle(.plain)
    }

    private func selectStage(_ stage: MechStageSpec) {
        selectedPart = nil
        if selectedStage == stage.id {
            selectedStage = nil
            rebase()
            return
        }
        selectedStage = stage.id
        basePhase = stage.phase.lowerBound
        baseDate = Date()
        playing = true
        CogHaptics.tick()
        // Watching a step for a few seconds marks it as learned.
        let token = UUID()
        stageToken = token
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard stageToken == token, selectedStage == stage.id else { return }
            let finished = store.stageDone(mech: spec.id, stage: stage.id)
            if finished {
                CogHaptics.success()
                withAnimation { showConfetti = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation { showConfetti = false }
                }
            }
        }
    }

    // MARK: Caption & part cards

    private var captionCard: some View {
        Group {
            if let stage = stageSpec {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(spec.wing.tint)
                        .frame(width: 4)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stage.title)
                            .font(CogTheme.body(14, weight: .bold))
                            .foregroundColor(CogTheme.ink)
                        Text(stage.caption)
                            .font(CogTheme.body(14))
                            .foregroundColor(CogTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .cogCard()
            } else if store.isUnderstood(spec.id) {
                HStack(spacing: 10) {
                    StarGlyph().fill(CogTheme.gold).frame(width: 20, height: 20)
                    Text("Mechanism understood — every step complete.")
                        .font(CogTheme.body(14, weight: .semibold))
                        .foregroundColor(CogTheme.ink)
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CogTheme.leaf.opacity(0.16)))
            } else {
                Text("Drag across the panel to crank the mechanism by hand, pull it apart with the slider, and walk the numbered steps to master it.")
                    .font(CogTheme.body(13))
                    .foregroundColor(CogTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func partCard(_ part: MechPartSpec) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(spec.wing.tint.opacity(0.16)).frame(width: 40, height: 40)
                GearGlyph(teeth: 8)
                    .fill(spec.wing.tint, style: FillStyle(eoFill: true))
                    .frame(width: 22, height: 22)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(part.name)
                    .font(CogTheme.body(15, weight: .bold))
                    .foregroundColor(CogTheme.ink)
                Text(part.role)
                    .font(CogTheme.body(13))
                    .foregroundColor(CogTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button { selectedPart = nil } label: {
                CrossGlyph()
                    .stroke(CogTheme.inkSoft, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 12, height: 12)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .cogCard()
    }

    // MARK: About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            CogArtImage(name: spec.posterName, corner: 18)
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CogTheme.ink.opacity(0.15), lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text("The story")
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
                Text(spec.era)
                    .font(CogTheme.mono(12))
                    .foregroundColor(spec.wing.tint)
                Text(spec.history)
                    .font(CogTheme.body(14))
                    .foregroundColor(CogTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .cogCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Did you know")
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
                ForEach(Array(spec.facts.enumerated()), id: \.offset) { _, fact in
                    HStack(alignment: .top, spacing: 10) {
                        StarGlyph().fill(CogTheme.gold).frame(width: 14, height: 14)
                            .padding(.top, 2)
                        Text(fact)
                            .font(CogTheme.body(13.5))
                            .foregroundColor(CogTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .cogCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Spot it in the wild")
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
                ForEach(Array(spec.spotIt.enumerated()), id: \.offset) { _, place in
                    HStack(alignment: .top, spacing: 10) {
                        Circle().fill(spec.wing.tint).frame(width: 7, height: 7)
                            .padding(.top, 6)
                        Text(place)
                            .font(CogTheme.body(13.5))
                            .foregroundColor(CogTheme.inkSoft)
                    }
                }
            }
            .cogCard()
        }
    }
}
