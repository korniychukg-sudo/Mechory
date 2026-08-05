import SwiftUI

// Reusable progress components composed by the Model Hall.

struct CogRankCard: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        let xp = store.state.xp
        let current = CogRanks.rank(for: xp)
        let next = CogRanks.next(after: xp)
        let base = current.rank.threshold
        let span = (next?.threshold ?? max(xp, base + 1)) - base
        let frac = span > 0 ? CGFloat(xp - base) / CGFloat(span) : 1

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(CogTheme.paperDeep, lineWidth: 9)
                Circle()
                    .trim(from: 0, to: max(0.02, min(frac, 1)))
                    .stroke(CogTheme.brass, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(xp)")
                        .font(CogTheme.title(21))
                        .foregroundColor(CogTheme.ink)
                    Text("XP")
                        .font(CogTheme.mono(10))
                        .foregroundColor(CogTheme.inkSoft)
                }
            }
            .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: 5) {
                Text("Rank \(current.index + 1) of \(CogRanks.all.count)")
                    .font(CogTheme.mono(11))
                    .foregroundColor(CogTheme.teal)
                Text(current.rank.name)
                    .font(CogTheme.title(20))
                    .foregroundColor(CogTheme.ink)
                if let next = next {
                    Text("\(next.threshold - xp) XP to \(next.name)")
                        .font(CogTheme.body(12.5))
                        .foregroundColor(CogTheme.inkSoft)
                } else {
                    Text("The workshop bows to you.")
                        .font(CogTheme.body(12.5))
                        .foregroundColor(CogTheme.inkSoft)
                }
            }
            Spacer(minLength: 0)
        }
        .cogCard()
    }
}

struct CogStatsGrid: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        let s = store.state
        let cells: [(String, String)] = [
            ("\(s.understoodIDs.count)/\(MechLibrary.all.count)", "mechanisms mastered"),
            ("\(s.challengesDone.count)/\(BenchChallenge.all.count)", "bench challenges"),
            ("\(s.streak)", "day streak"),
            ("\(s.quizBest)/10", "best quiz"),
            ("\(s.crankCycles)", "hand-cranked cycles"),
            ("\(s.repairsRead.count)/10", "fixes learned"),
        ]
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                VStack(spacing: 3) {
                    Text(cell.0)
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.copper)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(cell.1)
                        .font(CogTheme.body(10.5, weight: .semibold))
                        .foregroundColor(CogTheme.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CogTheme.card)
                    .shadow(color: CogTheme.shadow, radius: 4, y: 1))
            }
        }
    }
}

struct CogVisitCalendar: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysSinceMonday = (weekday + 5) % 7
        let thisMonday = cal.date(byAdding: .day, value: -daysSinceMonday, to: today) ?? today
        let weeks: [[Date]] = (0..<5).reversed().map { w in
            let monday = cal.date(byAdding: .day, value: -7 * w, to: thisMonday) ?? today
            return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
        }

        return VStack(alignment: .leading, spacing: 10) {
            Text("Workshop visits — last 5 weeks")
                .font(CogTheme.title(16))
                .foregroundColor(CogTheme.ink)
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, day in
                        Text(day)
                            .font(CogTheme.mono(10))
                            .foregroundColor(CogTheme.inkSoft)
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 6) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                            let key = CogStore.dayKey(day)
                            let visited = store.state.visitDays.contains(key)
                            let perfect = store.state.perfectDays.contains(key)
                            let isFuture = day > today
                            let isToday = cal.isDate(day, inSameDayAs: today)
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(perfect ? CogTheme.gold :
                                        (visited ? CogTheme.brass :
                                            (isFuture ? Color.clear : CogTheme.paperDeep)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .stroke(isToday ? CogTheme.teal : Color.clear, lineWidth: 1.6))
                                .frame(height: 20)
                        }
                    }
                }
                HStack(spacing: 12) {
                    legendDot(CogTheme.brass, "visited")
                    legendDot(CogTheme.gold, "perfect day")
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .cogCard()
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(label)
                .font(CogTheme.body(10.5))
                .foregroundColor(CogTheme.inkSoft)
        }
    }
}

struct CogBadgeGrid: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Awards")
                    .font(CogTheme.title(18))
                    .foregroundColor(CogTheme.ink)
                Spacer()
                Text("\(store.state.earnedBadgeIDs.count)/\(CogBadges.all.count)")
                    .font(CogTheme.mono(12))
                    .foregroundColor(CogTheme.inkSoft)
            }
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(CogBadges.all) { badge in
                    badgeCell(badge, earned: store.state.earnedBadgeIDs.contains(badge.id))
                }
            }
        }
    }

    private func badgeCell(_ badge: CogBadge, earned: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(earned ? CogTheme.gold.opacity(0.2) : CogTheme.paperDeep)
                    .frame(width: 42, height: 42)
                MedalGlyph()
                    .fill(earned ? CogTheme.brass : CogTheme.inkSoft.opacity(0.35))
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(CogTheme.body(12.5, weight: .bold))
                    .foregroundColor(earned ? CogTheme.ink : CogTheme.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(badge.detail)
                    .font(CogTheme.body(10.5))
                    .foregroundColor(CogTheme.inkSoft.opacity(earned ? 1 : 0.75))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(earned ? CogTheme.card : CogTheme.card.opacity(0.6))
            .shadow(color: CogTheme.shadow.opacity(earned ? 1 : 0.4), radius: 4, y: 1))
    }
}
