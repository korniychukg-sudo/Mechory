import SwiftUI

// MARK: - Bench tab root

struct BenchView: View {
    @EnvironmentObject var store: CogStore
    @State private var section = 0   // 0 free play, 1 challenges

    #if DEBUG
    private var forcedSection: Int? {
        ProcessInfo.processInfo.environment["COG_BENCH"] == "challenges" ? 1 : nil
    }
    #endif

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CogSectionHeader(title: "Test Bench",
                                 subtitle: "Mount gears on the pegboard and watch real ratios at work.")
                    .padding(.top, 12)

                HStack(spacing: 8) {
                    segButton("Free Play", index: 0)
                    segButton("Challenges", index: 1)
                    Spacer(minLength: 0)
                    Text("\(store.state.challengesDone.count)/\(BenchChallenge.all.count) solved")
                        .font(CogTheme.mono(12))
                        .foregroundColor(CogTheme.inkSoft)
                }

                if section == 0 {
                    FreePlayBench()
                        .environmentObject(store)
                } else {
                    challengeList
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            #if DEBUG
            if let forced = forcedSection { section = forced }
            #endif
        }
    }

    private func segButton(_ label: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { section = index }
        } label: {
            Text(label)
                .font(CogTheme.body(13, weight: .bold))
                .foregroundColor(section == index ? CogTheme.card : CogTheme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(section == index ? CogTheme.teal : CogTheme.card)
                    .shadow(color: CogTheme.shadow, radius: 3, y: 1))
        }
        .buttonStyle(.plain)
    }

    private var challengeList: some View {
        VStack(spacing: 10) {
            ForEach(BenchChallenge.all) { challenge in
                NavigationLink {
                    BenchChallengeView(challenge: challenge)
                        .environmentObject(store)
                } label: {
                    challengeRow(challenge)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func challengeRow(_ challenge: BenchChallenge) -> some View {
        let done = store.state.challengesDone.contains(challenge.id)
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(done ? CogTheme.leaf.opacity(0.15) : CogTheme.paperDeep)
                    .frame(width: 38, height: 38)
                if done {
                    CheckGlyph()
                        .stroke(CogTheme.leaf, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                        .frame(width: 15, height: 15)
                } else {
                    Text(String(challenge.id.dropFirst()))
                        .font(CogTheme.mono(13))
                        .foregroundColor(CogTheme.inkSoft)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(CogTheme.body(15, weight: .bold))
                    .foregroundColor(CogTheme.ink)
                Text(challenge.brief)
                    .font(CogTheme.body(12))
                    .foregroundColor(CogTheme.inkSoft)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            ChevronGlyph()
                .stroke(CogTheme.inkSoft.opacity(0.7),
                        style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                .frame(width: 12, height: 12)
        }
        .cogCard(padding: 12, corner: 16)
    }
}

// MARK: - Free play

struct FreePlayBench: View {
    @EnvironmentObject var store: CogStore
    @State private var board = BenchBoard()
    @State private var loaded = false

    var body: some View {
        BenchBoardPanel(board: $board, showOutputs: false) {
            store.saveBenchLayout(board.placed)
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            board.placed = store.state.benchLayout
            board.sanitize()
        }
    }
}

// MARK: - Challenge screen

struct BenchChallengeView: View {
    @EnvironmentObject var store: CogStore
    let challenge: BenchChallenge
    @State private var board: BenchBoard
    @State private var solvedNow = false
    @State private var showHint = false

    init(challenge: BenchChallenge) {
        self.challenge = challenge
        _board = State(initialValue: challenge.makeBoard())
    }

    private var alreadyDone: Bool {
        store.state.challengesDone.contains(challenge.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2).fill(CogTheme.teal).frame(width: 4)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.brief)
                            .font(CogTheme.body(14, weight: .semibold))
                            .foregroundColor(CogTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        if showHint {
                            Text("Hint: \(challenge.hint)")
                                .font(CogTheme.body(12.5))
                                .foregroundColor(CogTheme.teal)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Button { withAnimation { showHint = true } } label: {
                                Text("Show hint")
                                    .font(CogTheme.body(12.5, weight: .bold))
                                    .foregroundColor(CogTheme.teal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer(minLength: 0)
                    if alreadyDone || solvedNow {
                        CogTag(text: "Solved", color: CogTheme.leaf, filled: true)
                    }
                }
                .cogCard(padding: 13)

                ZStack {
                    BenchBoardPanel(board: $board, showOutputs: true) {
                        checkGoal()
                    }
                    if solvedNow {
                        CogConfettiView(seed: challenge.id.hashValue & 0xFFF)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(challenge.title)
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
    }

    private func checkGoal() {
        guard !solvedNow else { return }
        if challenge.isMet(board) {
            solvedNow = true
            store.challengeSolved(challenge.id)
            CogHaptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { solvedNow = false }
            }
        }
    }
}

// MARK: - The pegboard panel (canvas + palette + controls)

struct BenchBoardPanel: View {
    @EnvironmentObject var store: CogStore
    @Binding var board: BenchBoard
    let showOutputs: Bool
    let onChange: () -> Void

    @State private var tool: BenchGearSize? = .medium   // nil = eraser
    @State private var speed: CGFloat = 0.55            // slider 0...1 → 0.3...2 turns/s feel
    @State private var reversedMotor = false
    @State private var wasJammed = false
    @State private var jamFlash = false
    private let startDate = Date()

    private var solved: (gears: [BenchGear], jammed: Bool) { board.solved() }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottom) {
                boardCanvas
                    .aspectRatio(CGFloat(board.cols + 1) / CGFloat(board.rows + 1), contentMode: .fit)
                if let hint = rejectHint {
                    Text(hint)
                        .font(CogTheme.body(12, weight: .semibold))
                        .foregroundColor(CogTheme.card)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(CogTheme.ink.opacity(0.82)))
                        .padding(.bottom, 12)
                        .transition(.opacity)
                }
            }
            palette
            controls
        }
        .animation(.easeInOut(duration: 0.2), value: rejectHint)
    }

    // MARK: Canvas

    private var boardCanvas: some View {
        let result = solved
        return GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 40.0)) { tl in
                Canvas { ctx, size in
                    drawBoard(&ctx, size: size, gears: result.gears,
                              jammed: result.jammed, at: tl.date)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        handleTap(value.location, canvasSize: geo.size)
                    }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [MechMetal.wood.light, MechMetal.wood.base],
                                     startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(jamFlash ? CogTheme.seal : CogTheme.ink.opacity(0.25),
                        lineWidth: jamFlash ? 3 : 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onChange(of: result.jammed) { jam in
            if jam && !wasJammed {
                store.jamHappened()
                CogHaptics.warning()
                withAnimation(.easeIn(duration: 0.15)) { jamFlash = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation { jamFlash = false }
                }
            }
            wasJammed = jam
        }
    }

    private func geometry(_ size: CGSize) -> (h: CGFloat, ox: CGFloat, oy: CGFloat) {
        let h = min(size.width / CGFloat(board.cols + 1), size.height / CGFloat(board.rows + 1))
        let ox = (size.width - h * CGFloat(board.cols - 1)) / 2
        let oy = (size.height - h * CGFloat(board.rows - 1)) / 2
        return (h, ox, oy)
    }

    private func holeCenter(_ col: Int, _ row: Int, _ size: CGSize) -> CGPoint {
        let g = geometry(size)
        return CGPoint(x: g.ox + CGFloat(col) * g.h, y: g.oy + CGFloat(row) * g.h)
    }

    private func drawBoard(_ ctx: inout GraphicsContext, size: CGSize,
                           gears: [BenchGear], jammed: Bool, at date: Date) {
        let g = geometry(size)
        let h = g.h

        // Pegboard holes.
        for c in 0..<board.cols {
            for r in 0..<board.rows {
                let pt = holeCenter(c, r, size)
                let hole = Path(ellipseIn: CGRect(x: pt.x - h * 0.07, y: pt.y - h * 0.07,
                                                  width: h * 0.14, height: h * 0.14))
                ctx.fill(hole, with: .color(MechMetal.wood.dark.opacity(0.55)))
            }
        }

        // Output dials underneath their holes.
        if showOutputs {
            for out in board.outputs {
                let pt = holeCenter(out.col, out.row, size)
                let ring = Path(ellipseIn: CGRect(x: pt.x - h * 0.62, y: pt.y - h * 0.62,
                                                  width: h * 1.24, height: h * 1.24))
                ctx.stroke(ring, with: .color(MechMetal.ruby.base),
                           style: StrokeStyle(lineWidth: max(2, h * 0.09),
                                              dash: [h * 0.18, h * 0.14]))
                let w = board.omegaAt(col: out.col, row: out.row)
                let label = w == nil ? "—" : String(format: "×%.2f", abs(w!))
                let text = Text(label).font(CogTheme.mono(11)).foregroundColor(CogTheme.card)
                let resolved = ctx.resolve(text)
                let m = resolved.measure(in: CGSize(width: 100, height: 30))
                let plate = CGRect(x: pt.x - m.width / 2 - 4, y: pt.y + h * 0.68,
                                   width: m.width + 8, height: m.height + 4)
                ctx.fill(Path(roundedRect: plate, cornerRadius: 4),
                         with: .color(MechMetal.ruby.dark.opacity(0.9)))
                ctx.draw(resolved, at: CGPoint(x: pt.x, y: plate.midY), anchor: .center)
            }
        }

        // Gears.
        let elapsed = date.timeIntervalSince(startDate)
        let rate = Double(0.3 + speed * 1.7) * (reversedMotor ? -1 : 1)
        let painter = MechScenePainter(ctx, size, MechRenderOptions())
        for gear in gears {
            let pt = holeCenter(gear.col, gear.row, size)
            let outer = CGFloat(gear.size.radius) * h * 0.97
            var angle = gear.omega * rate * elapsed * 2.2
            if gear.jammed && jammed {
                angle += sin(elapsed * 46) * 0.045     // shudder
            }
            var c = ctx
            painter.drawGear(&c, center: pt, teeth: gear.size.teeth, outer: outer,
                             rotation: angle,
                             metal: gear.isMotor ? .gold : gear.size.metal,
                             hubScale: 0.16,
                             holes: gear.size == .small ? 0 : (gear.size == .grand ? 6 : 4))
            if gear.isMotor {
                // Motor badge ring.
                let ring = Path(ellipseIn: CGRect(x: pt.x - outer * 0.34, y: pt.y - outer * 0.34,
                                                  width: outer * 0.68, height: outer * 0.68))
                c.stroke(ring, with: .color(CogTheme.seal), lineWidth: max(2, h * 0.08))
            }
        }

        // Jam banner.
        if jammed {
            let text = Text("Jammed! Two paths disagree — remove a gear.")
                .font(CogTheme.body(12, weight: .bold)).foregroundColor(CogTheme.card)
            let resolved = ctx.resolve(text)
            let m = resolved.measure(in: CGSize(width: size.width - 40, height: 60))
            let plate = CGRect(x: (size.width - m.width) / 2 - 10, y: 12,
                               width: m.width + 20, height: m.height + 10)
            ctx.fill(Path(roundedRect: plate, cornerRadius: 9), with: .color(CogTheme.seal.opacity(0.92)))
            ctx.draw(resolved, at: CGPoint(x: size.width / 2, y: plate.midY), anchor: .center)
        }
    }

    private func handleTap(_ location: CGPoint, canvasSize size: CGSize) {
        // Nearest hole within half a spacing.
        var best: (col: Int, row: Int, d: CGFloat)? = nil
        for c in 0..<board.cols {
            for r in 0..<board.rows {
                let pt = holeCenter(c, r, size)
                let d = hypot(pt.x - location.x, pt.y - location.y)
                if d < geometry(size).h * 0.55, best == nil || d < best!.d {
                    best = (c, r, d)
                }
            }
        }
        guard let hit = best else { return }
        if board.placed.contains(where: { $0.col == hit.col && $0.row == hit.row }) {
            board.remove(col: hit.col, row: hit.row)
            CogHaptics.tick()
            onChange()
        } else if let size = tool {
            if board.canPlace(col: hit.col, row: hit.row, size: size) {
                board.place(col: hit.col, row: hit.row, size: size)
                CogHaptics.tick()
                onChange()
            } else {
                CogHaptics.warning()
                rejectHint = board.fits(col: hit.col, row: hit.row, size: size)
                    ? "No room — that hole is taken or too close."
                    : "A \(size.label) wheel needs more space from the edge."
                let shown = rejectHint
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    if rejectHint == shown { rejectHint = nil }
                }
            }
        }
    }

    @State private var rejectHint: String? = nil

    // MARK: Palette & controls

    private var palette: some View {
        HStack(spacing: 8) {
            ForEach(BenchGearSize.allCases, id: \.self) { size in
                paletteButton(size)
            }
            Button {
                tool = nil
                CogHaptics.tick()
            } label: {
                VStack(spacing: 3) {
                    CrossGlyph()
                        .stroke(tool == nil ? CogTheme.card : CogTheme.inkSoft,
                                style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
                        .frame(width: 16, height: 16)
                        .frame(height: 26)
                    Text("Remove")
                        .font(CogTheme.body(10, weight: .semibold))
                        .foregroundColor(tool == nil ? CogTheme.card : CogTheme.inkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tool == nil ? CogTheme.seal : CogTheme.card)
                    .shadow(color: CogTheme.shadow, radius: 3, y: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func paletteButton(_ size: BenchGearSize) -> some View {
        let active = tool == size
        let dim: CGFloat = [BenchGearSize.small: 18, .medium: 22, .large: 26, .grand: 30][size] ?? 22
        return Button {
            tool = size
            CogHaptics.tick()
        } label: {
            VStack(spacing: 3) {
                GearGlyph(teeth: size.teeth == 8 ? 8 : (size.teeth == 12 ? 9 : (size.teeth == 16 ? 10 : 12)))
                    .fill(active ? CogTheme.card : size.metal.base, style: FillStyle(eoFill: true))
                    .frame(width: dim, height: dim)
                    .frame(height: 26)
                Text(size.label)
                    .font(CogTheme.body(10, weight: .semibold))
                    .foregroundColor(active ? CogTheme.card : CogTheme.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(active ? CogTheme.teal : CogTheme.card)
                .shadow(color: CogTheme.shadow, radius: 3, y: 1))
        }
        .buttonStyle(.plain)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                reversedMotor.toggle()
                CogHaptics.tick()
            } label: {
                ChevronGlyph(pointRight: !reversedMotor)
                    .stroke(CogTheme.ink, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                    .frame(width: 14, height: 14)
                    .frame(width: 40, height: 34)
                    .background(Capsule().fill(CogTheme.paperDeep))
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Text("Speed")
                    .font(CogTheme.body(12, weight: .semibold))
                    .foregroundColor(CogTheme.inkSoft)
                CogSlider(value: $speed, tint: CogTheme.brass)
            }

            Button {
                board.clear()
                CogHaptics.thud()
                onChange()
            } label: {
                Text("Clear")
                    .font(CogTheme.body(13, weight: .bold))
                    .foregroundColor(CogTheme.seal)
                    .frame(height: 34)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(CogTheme.sealSoft))
            }
            .buttonStyle(.plain)
        }
    }
}
