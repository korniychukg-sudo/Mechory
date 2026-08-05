import SwiftUI

/// The Model Hall: every mastered mechanism becomes a live miniature model
/// mounted on the collection wall; progress records hang below.
struct ModelHallView: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CogSectionHeader(title: "Model Hall",
                                 subtitle: "Master a mechanism and its working model joins your wall.")
                    .padding(.top, 12)
                    .cogAppear(0)
                wall.cogAppear(1)
                CogRankCard().cogAppear(2)
                CogStatsGrid().cogAppear(3)
                CogVisitCalendar().cogAppear(4)
                CogBadgeGrid().cogAppear(5)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: Wall

    private var wall: some View {
        VStack(spacing: 12) {
            if store.state.understoodIDs.isEmpty {
                HStack(spacing: 10) {
                    StarGlyph().fill(CogTheme.gold).frame(width: 18, height: 18)
                    Text("The wall awaits its first model — master any mechanism to mount it here.")
                        .font(CogTheme.body(13))
                        .foregroundColor(CogTheme.card)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CogTheme.ink.opacity(0.35)))
            }
            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(MechLibrary.all.enumerated()), id: \.element.id) { idx, spec in
                    HallPlate(spec: spec, index: idx,
                              mastered: store.isUnderstood(spec.id))
                        .environmentObject(store)
                }
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.32, green: 0.25, blue: 0.19),
                                                  Color(red: 0.24, green: 0.18, blue: 0.13)],
                                         startPoint: .top, endPoint: .bottom))
                // Pegboard holes pattern.
                Canvas { ctx, size in
                    let step: CGFloat = 26
                    var y: CGFloat = 14
                    while y < size.height {
                        var x: CGFloat = 14
                        while x < size.width {
                            ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3.4, height: 3.4)),
                                     with: .color(Color.black.opacity(0.25)))
                            x += step
                        }
                        y += step
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(CogTheme.ink.opacity(0.3), lineWidth: 1.5)
        )
    }
}

/// One mounting plate: a live mini-model when mastered, a waiting hook when not.
struct HallPlate: View {
    @EnvironmentObject var store: CogStore
    let spec: MechanismSpec
    let index: Int
    let mastered: Bool

    var body: some View {
        NavigationLink {
            MechanismView(spec: spec)
                .environmentObject(store)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(mastered
                              ? LinearGradient(colors: [CogTheme.blueprintHi, CogTheme.blueprint],
                                               startPoint: .top, endPoint: .bottom)
                              : LinearGradient(colors: [Color.black.opacity(0.22), Color.black.opacity(0.3)],
                                               startPoint: .top, endPoint: .bottom))
                    if mastered {
                        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
                            Canvas { ctx, size in
                                let t = tl.date.timeIntervalSinceReferenceDate
                                var phase = (t / spec.cycleSeconds + Double(index) * 0.13)
                                    .truncatingRemainder(dividingBy: 1)
                                if phase < 0 { phase += 1 }
                                var c = ctx
                                spec.draw(&c, size, phase, MechRenderOptions(hideCallouts: true))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        VStack(spacing: 6) {
                            // Empty hook.
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 2)
                                .frame(width: 10, height: 10)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 3, height: 14)
                            Text("?")
                                .font(CogTheme.title(22))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                    }
                    if !mastered {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(style: StrokeStyle(lineWidth: 1.4, dash: [5, 4]))
                            .foregroundColor(Color.white.opacity(0.25))
                    }
                }
                .aspectRatio(1.05, contentMode: .fit)

                // Engraved brass plate.
                Text(mastered ? spec.name.uppercased() : "· · ·")
                    .font(.system(size: 8.5, weight: .bold, design: .serif))
                    .foregroundColor(mastered
                                     ? Color(red: 0.28, green: 0.19, blue: 0.06)
                                     : Color(red: 0.28, green: 0.19, blue: 0.06).opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(LinearGradient(
                                colors: mastered
                                    ? [MechMetal.brass.light, MechMetal.brass.dark]
                                    : [MechMetal.brass.light.opacity(0.4), MechMetal.brass.dark.opacity(0.4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing)))
            }
        }
        .buttonStyle(CogPressStyle())
    }
}
