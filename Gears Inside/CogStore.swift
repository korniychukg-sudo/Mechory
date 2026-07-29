import SwiftUI

// MARK: - Persisted progress state

struct CogProgressState: Codable {
    var onboardingSeen: Bool = false
    var openedMechIDs: Set<String> = []
    var stagesDone: [String: Set<Int>] = [:]
    var understoodIDs: Set<String> = []
    var explodeCount: Int = 0
    var crankCycles: Int = 0
    var partTaps: Int = 0
    var quizRounds: Int = 0
    var quizPerfects: Int = 0
    var quizCorrectTotal: Int = 0
    var quizBest: Int = 0
    var guidesRead: Set<String> = []
    var visitDays: Set<String> = []
    var dailyOpenDays: Set<String> = []
    var lastOpenedMechID: String? = nil
    var earnedBadgeIDs: Set<String> = []

    init() {}

    // Tolerant decoding so future fields never break old saves.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        onboardingSeen = (try? c.decodeIfPresent(Bool.self, forKey: .onboardingSeen)) ?? false
        openedMechIDs = (try? c.decodeIfPresent(Set<String>.self, forKey: .openedMechIDs)) ?? []
        stagesDone = (try? c.decodeIfPresent([String: Set<Int>].self, forKey: .stagesDone)) ?? [:]
        understoodIDs = (try? c.decodeIfPresent(Set<String>.self, forKey: .understoodIDs)) ?? []
        explodeCount = (try? c.decodeIfPresent(Int.self, forKey: .explodeCount)) ?? 0
        crankCycles = (try? c.decodeIfPresent(Int.self, forKey: .crankCycles)) ?? 0
        partTaps = (try? c.decodeIfPresent(Int.self, forKey: .partTaps)) ?? 0
        quizRounds = (try? c.decodeIfPresent(Int.self, forKey: .quizRounds)) ?? 0
        quizPerfects = (try? c.decodeIfPresent(Int.self, forKey: .quizPerfects)) ?? 0
        quizCorrectTotal = (try? c.decodeIfPresent(Int.self, forKey: .quizCorrectTotal)) ?? 0
        quizBest = (try? c.decodeIfPresent(Int.self, forKey: .quizBest)) ?? 0
        guidesRead = (try? c.decodeIfPresent(Set<String>.self, forKey: .guidesRead)) ?? []
        visitDays = (try? c.decodeIfPresent(Set<String>.self, forKey: .visitDays)) ?? []
        dailyOpenDays = (try? c.decodeIfPresent(Set<String>.self, forKey: .dailyOpenDays)) ?? []
        lastOpenedMechID = try? c.decodeIfPresent(String.self, forKey: .lastOpenedMechID)
        earnedBadgeIDs = (try? c.decodeIfPresent(Set<String>.self, forKey: .earnedBadgeIDs)) ?? []
    }

    var stagesDoneCount: Int {
        stagesDone.values.reduce(0) { $0 + $1.count }
    }

    func wingDone(_ wing: MechWing) -> Bool {
        let ids = MechLibrary.all.filter { $0.wing == wing }.map { $0.id }
        return !ids.isEmpty && ids.allSatisfy { understoodIDs.contains($0) }
    }

    var xp: Int {
        var total = 0
        total += openedMechIDs.count * 10
        total += stagesDoneCount * 5
        total += understoodIDs.count * 25
        total += quizCorrectTotal * 1
        total += quizPerfects * 15
        total += guidesRead.count * 10
        total += visitDays.count * 5
        return total
    }

    var streak: Int {
        var run = 0
        var day = Date()
        let cal = Calendar.current
        // Today counts if visited; otherwise start from yesterday.
        if !visitDays.contains(CogStore.dayKey(day)) {
            guard let y = cal.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = y
        }
        while visitDays.contains(CogStore.dayKey(day)) {
            run += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return run
    }
}

// MARK: - Store

final class CogStore: ObservableObject {
    @Published private(set) var state = CogProgressState()
    /// Badges earned since the last time the UI consumed them (for toasts).
    @Published var freshBadges: [CogBadge] = []

    private static let saveKey = "cog.progress.v1"

    init() {
        load()
        #if DEBUG
        if ProcessInfo.processInfo.environment["COG_SEED"] == "rich" {
            seedForScreenshots()
        }
        #endif
        registerVisitToday()
    }

    #if DEBUG
    // Screenshot-only demo state; enabled via SIMCTL_CHILD_COG_SEED=rich.
    private func seedForScreenshots() {
        var s = CogProgressState()
        s.onboardingSeen = true
        for id in ["zipper", "pinlock", "geartrain", "crankslider", "escapement"] {
            s.openedMechIDs.insert(id)
            if let spec = MechLibrary.byID(id) {
                s.stagesDone[id] = Set(spec.stages.map { $0.id })
                s.understoodIDs.insert(id)
            }
        }
        s.openedMechIDs.insert("fourstroke")
        s.stagesDone["fourstroke"] = [1, 2]
        s.lastOpenedMechID = "fourstroke"
        s.explodeCount = 12
        s.crankCycles = 34
        s.partTaps = 21
        s.quizRounds = 3
        s.quizCorrectTotal = 22
        s.quizBest = 9
        s.guidesRead = ["gears", "ratio", "clock"]
        let cal = Calendar.current
        for d in 0..<5 {
            if let day = cal.date(byAdding: .day, value: -d, to: Date()) {
                s.visitDays.insert(Self.dayKey(day))
            }
        }
        s.dailyOpenDays = ["2026-07-25", "2026-07-26", "2026-07-27"]
        state = s
        for badge in CogBadges.all where badge.check(state) {
            state.earnedBadgeIDs.insert(badge.id)
        }
    }
    #endif

    static func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.saveKey) else { return }
        if let decoded = try? JSONDecoder().decode(CogProgressState.self, from: data) {
            state = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.saveKey)
        }
    }

    private func mutate(_ change: (inout CogProgressState) -> Void) {
        change(&state)
        refreshBadges()
        save()
    }

    private func refreshBadges() {
        for badge in CogBadges.all where badge.check(state) {
            if !state.earnedBadgeIDs.contains(badge.id) {
                state.earnedBadgeIDs.insert(badge.id)
                freshBadges.append(badge)
            }
        }
    }

    // MARK: Events

    func registerVisitToday() {
        let key = Self.dayKey(Date())
        if !state.visitDays.contains(key) {
            mutate { $0.visitDays.insert(key) }
        }
    }

    func markOnboardingSeen() {
        mutate { $0.onboardingSeen = true }
    }

    func mechOpened(_ id: String, isDaily: Bool) {
        mutate {
            $0.openedMechIDs.insert(id)
            $0.lastOpenedMechID = id
            if isDaily { $0.dailyOpenDays.insert(Self.dayKey(Date())) }
        }
    }

    /// Returns true when this stage completion finished the whole mechanism.
    @discardableResult
    func stageDone(mech: String, stage: Int) -> Bool {
        let before = state.understoodIDs.contains(mech)
        mutate {
            var set = $0.stagesDone[mech] ?? []
            set.insert(stage)
            $0.stagesDone[mech] = set
            if let spec = MechLibrary.byID(mech),
               set.count >= spec.stages.count {
                $0.understoodIDs.insert(mech)
            }
        }
        return !before && state.understoodIDs.contains(mech)
    }

    func explodeUsed() {
        mutate { $0.explodeCount += 1 }
    }

    func crankCycled(_ turns: Int = 1) {
        mutate { $0.crankCycles += turns }
    }

    func partInspected() {
        mutate { $0.partTaps += 1 }
    }

    func quizFinished(correct: Int, outOf total: Int) {
        mutate {
            $0.quizRounds += 1
            $0.quizCorrectTotal += correct
            $0.quizBest = max($0.quizBest, correct)
            if correct == total { $0.quizPerfects += 1 }
        }
    }

    func guideRead(_ id: String) {
        if !state.guidesRead.contains(id) {
            mutate { $0.guidesRead.insert(id) }
        }
    }

    func resetAll() {
        mutate { s in
            let seen = s.onboardingSeen
            s = CogProgressState()
            s.onboardingSeen = seen
        }
        freshBadges = []
    }

    // MARK: Derived helpers

    var mechanismOfTheDay: MechanismSpec {
        let all = MechLibrary.all
        let days = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return all[days % all.count]
    }

    func stageSet(for mech: String) -> Set<Int> {
        state.stagesDone[mech] ?? []
    }

    func isUnderstood(_ mech: String) -> Bool {
        state.understoodIDs.contains(mech)
    }
}
