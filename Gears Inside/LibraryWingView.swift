import SwiftUI

// MARK: - Library tab: all wings and mechanisms

struct LibraryView: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                CogSectionHeader(title: "Mechanism Library",
                                 subtitle: "Sixteen movements, drawn to be cranked, split apart and understood.")
                    .padding(.top, 12)
                ForEach(MechWing.allCases) { wing in
                    wingSection(wing)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func wingSection(_ wing: MechWing) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(wing.tint).frame(width: 4, height: 18)
                Text(wing.title)
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
                Spacer()
                let specs = MechLibrary.wing(wing)
                let done = specs.filter { store.isUnderstood($0.id) }.count
                Text("\(done)/\(specs.count)")
                    .font(CogTheme.mono(12))
                    .foregroundColor(CogTheme.inkSoft)
            }
            VStack(spacing: 10) {
                ForEach(MechLibrary.wing(wing)) { spec in
                    MechRow(spec: spec)
                        .environmentObject(store)
                }
            }
        }
    }
}

// MARK: - Wing detail (from the Workshop shelf)

struct WingDetailView: View {
    @EnvironmentObject var store: CogStore
    let wing: MechWing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ZStack(alignment: .bottomLeading) {
                    CogArtImage(name: wing.artName, corner: 20)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.6)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(wing.title)
                            .font(CogTheme.title(24))
                            .foregroundColor(.white)
                        Text(wing.blurb)
                            .font(CogTheme.body(13))
                            .foregroundColor(.white.opacity(0.88))
                    }
                    .padding(14)
                }
                .padding(.top, 6)

                VStack(spacing: 10) {
                    ForEach(MechLibrary.wing(wing)) { spec in
                        MechRow(spec: spec)
                            .environmentObject(store)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(wing.title)
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
    }
}

// MARK: - Shared mechanism row

struct MechRow: View {
    @EnvironmentObject var store: CogStore
    let spec: MechanismSpec

    var body: some View {
        NavigationLink {
            MechanismView(spec: spec)
                .environmentObject(store)
        } label: {
            HStack(spacing: 12) {
                CogArtImage(name: spec.posterName, corner: 12)
                    .frame(width: 86, height: 64)
                    .clipped()
                VStack(alignment: .leading, spacing: 4) {
                    Text(spec.name)
                        .font(CogTheme.body(15, weight: .bold))
                        .foregroundColor(CogTheme.ink)
                    Text(spec.tagline)
                        .font(CogTheme.body(12))
                        .foregroundColor(CogTheme.inkSoft)
                        .lineLimit(2)
                    progressDots
                }
                Spacer(minLength: 0)
                if store.isUnderstood(spec.id) {
                    ZStack {
                        Circle().fill(CogTheme.leaf.opacity(0.15)).frame(width: 28, height: 28)
                        CheckGlyph()
                            .stroke(CogTheme.leaf, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                            .frame(width: 13, height: 13)
                    }
                } else {
                    ChevronGlyph()
                        .stroke(CogTheme.inkSoft.opacity(0.7),
                                style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 12, height: 12)
                }
            }
            .cogCard(padding: 12, corner: 16)
        }
        .buttonStyle(.plain)
    }

    private var progressDots: some View {
        let done = store.stageSet(for: spec.id)
        return HStack(spacing: 4) {
            ForEach(spec.stages) { stage in
                Circle()
                    .fill(done.contains(stage.id) ? spec.wing.tint : CogTheme.paperDeep)
                    .frame(width: 7, height: 7)
            }
        }
    }
}
