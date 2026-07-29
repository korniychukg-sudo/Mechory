import SwiftUI

struct WorkshopView: View {
    @EnvironmentObject var store: CogStore
    @EnvironmentObject var router: CogTabRouter

    private var continueSpec: MechanismSpec? {
        if let last = store.state.lastOpenedMechID,
           let spec = MechLibrary.byID(last),
           !store.isUnderstood(last) {
            return spec
        }
        return MechLibrary.all.first { !store.isUnderstood($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroBanner.cogAppear(0)
                statsStrip.cogAppear(1)
                goalsCard.cogAppear(2)
                dailyCard.cogAppear(3)
                if let next = continueSpec, next.id != store.mechanismOfTheDay.id {
                    continueCard(next).cogAppear(4)
                }
                quickRow.cogAppear(5)
                wingsShelf.cogAppear(6)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var heroBanner: some View {
        ZStack(alignment: .topLeading) {
            BenchSceneView(daily: store.mechanismOfTheDay)
                .frame(height: 230)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 2) {
                Text("Gears Inside")
                    .font(CogTheme.title(26))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
                Text("Every machine has a secret. Open it.")
                    .font(CogTheme.body(12.5))
                    .foregroundColor(.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.45), radius: 2, y: 1)
            }
            .padding(14)
        }
        .padding(.top, 8)
    }

    // MARK: Daily goals

    private var goalsCard: some View {
        let goals = store.todayGoals
        let perfect = goals.count >= 3
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today at the bench")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
                Spacer()
                if perfect {
                    CogTag(text: "Perfect day  +10 XP", color: CogTheme.gold, filled: true)
                } else {
                    Text("\(goals.count)/3")
                        .font(CogTheme.mono(13))
                        .foregroundColor(CogTheme.inkSoft)
                }
            }
            goalRow(done: goals.contains("daily"),
                    text: "Open the Mechanism of the Day")
            goalRow(done: goals.contains("bench"),
                    text: "Solve a Test Bench challenge")
            goalRow(done: goals.contains("quiz"),
                    text: "Finish a quiz round")
        }
        .cogCard()
    }

    private func goalRow(done: Bool, text: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(done ? CogTheme.leaf.opacity(0.16) : CogTheme.paperDeep)
                    .frame(width: 24, height: 24)
                if done {
                    CheckGlyph()
                        .stroke(CogTheme.leaf, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                        .frame(width: 11, height: 11)
                }
            }
            Text(text)
                .font(CogTheme.body(13.5, weight: done ? .semibold : .regular))
                .foregroundColor(done ? CogTheme.ink : CogTheme.inkSoft)
            Spacer(minLength: 0)
        }
    }

    // MARK: Quick cards

    private var quickRow: some View {
        HStack(spacing: 12) {
            NavigationLink {
                RepairListView().environmentObject(store)
            } label: {
                quickCard(title: "Repair Corner",
                          line: "Fix real things — zippers, hinges, chains.",
                          tint: CogTheme.seal) {
                    AnyView(WrenchGlyph().fill(CogTheme.seal).frame(width: 22, height: 22))
                }
            }
            .buttonStyle(CogPressStyle())

            Button {
                router.tab = 2
                CogHaptics.tick()
            } label: {
                quickCard(title: "Test Bench",
                          line: "Rig gears, chase ratios, beat challenges.",
                          tint: CogTheme.teal) {
                    AnyView(GearGlyph(teeth: 8)
                        .fill(CogTheme.teal, style: FillStyle(eoFill: true))
                        .frame(width: 22, height: 22))
                }
            }
            .buttonStyle(CogPressStyle())
        }
    }

    private func quickCard(title: String, line: String, tint: Color,
                           icon: @escaping () -> AnyView) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Circle().fill(tint.opacity(0.14)).frame(width: 38, height: 38)
                icon()
            }
            Text(title)
                .font(CogTheme.body(14, weight: .bold))
                .foregroundColor(CogTheme.ink)
            Text(line)
                .font(CogTheme.body(11.5))
                .foregroundColor(CogTheme.inkSoft)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cogCard(padding: 13, corner: 16)
    }

    private var statsStrip: some View {
        let rank = CogRanks.rank(for: store.state.xp)
        return HStack(spacing: 10) {
            statTile(value: "\(store.state.understoodIDs.count)/\(MechLibrary.all.count)",
                     label: "mastered", tint: CogTheme.teal)
            statTile(value: "\(store.state.streak)", label: "day streak", tint: CogTheme.seal)
            statTile(value: "\(store.state.xp)", label: rank.rank.name, tint: CogTheme.brass)
        }
    }

    private func statTile(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(CogTheme.title(19))
                .foregroundColor(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(CogTheme.body(11, weight: .semibold))
                .foregroundColor(CogTheme.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(CogTheme.card)
            .shadow(color: CogTheme.shadow, radius: 5, y: 2))
    }

    private var dailyCard: some View {
        let daily = store.mechanismOfTheDay
        return VStack(alignment: .leading, spacing: 10) {
            CogSectionHeader(title: "Mechanism of the Day",
                             subtitle: "A fresh movement on the bench every morning.")
            NavigationLink {
                MechanismView(spec: daily, isDaily: true)
                    .environmentObject(store)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    CogArtImage(name: daily.posterName, corner: 20)
                        .frame(height: 195)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.62)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            CogTag(text: daily.wing.title, color: daily.wing.tint, filled: true)
                            if store.isUnderstood(daily.id) {
                                CogTag(text: "Understood", color: CogTheme.leaf, filled: true)
                            }
                        }
                        Text(daily.name)
                            .font(CogTheme.title(23))
                            .foregroundColor(.white)
                        Text(daily.tagline)
                            .font(CogTheme.body(13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(14)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func continueCard(_ spec: MechanismSpec) -> some View {
        NavigationLink {
            MechanismView(spec: spec)
                .environmentObject(store)
        } label: {
            HStack(spacing: 12) {
                CogArtImage(name: spec.posterName, corner: 12)
                    .frame(width: 74, height: 56)
                    .clipped()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Back to the bench")
                        .font(CogTheme.body(11, weight: .bold))
                        .foregroundColor(spec.wing.tint)
                    Text(spec.name)
                        .font(CogTheme.body(15, weight: .bold))
                        .foregroundColor(CogTheme.ink)
                    Text("\(store.stageSet(for: spec.id).count)/\(spec.stages.count) steps done")
                        .font(CogTheme.body(12))
                        .foregroundColor(CogTheme.inkSoft)
                }
                Spacer(minLength: 0)
                ChevronGlyph()
                    .stroke(CogTheme.inkSoft, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                    .frame(width: 13, height: 13)
            }
            .cogCard(padding: 12)
        }
        .buttonStyle(.plain)
    }

    private var wingsShelf: some View {
        VStack(alignment: .leading, spacing: 10) {
            CogSectionHeader(title: "The Four Wings",
                             subtitle: "Sixteen mechanisms, from zippers to steam.")
            VStack(spacing: 12) {
                ForEach(MechWing.allCases) { wing in
                    NavigationLink {
                        WingDetailView(wing: wing)
                            .environmentObject(store)
                    } label: {
                        wingCard(wing)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func wingCard(_ wing: MechWing) -> some View {
        let specs = MechLibrary.wing(wing)
        let done = specs.filter { store.isUnderstood($0.id) }.count
        return ZStack(alignment: .bottomLeading) {
            CogArtImage(name: wing.artName, corner: 18)
                .frame(height: 108)
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.6)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(wing.title)
                        .font(CogTheme.title(18))
                        .foregroundColor(.white)
                    Text(wing.blurb)
                        .font(CogTheme.body(11.5))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Text("\(done)/\(specs.count)")
                    .font(CogTheme.mono(13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(wing.tint.opacity(0.85)))
            }
            .padding(12)
        }
    }
}
