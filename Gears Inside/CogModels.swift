import SwiftUI

// MARK: - Wings (mechanism families)

enum MechWing: String, CaseIterable, Identifiable, Codable {
    case house, gears, linkages, machines

    var id: String { rawValue }

    var title: String {
        switch self {
        case .house: return "Around the House"
        case .gears: return "Gear Works"
        case .linkages: return "Cranks & Linkages"
        case .machines: return "Great Machines"
        }
    }

    var blurb: String {
        switch self {
        case .house: return "Everyday objects hiding clever little machines."
        case .gears: return "How teeth, ratios and rotation really work."
        case .linkages: return "Turning spins into strokes, sweeps and clicks."
        case .machines: return "The celebrated movements that changed history."
        }
    }

    var artName: String {
        switch self {
        case .house: return "wing_house"
        case .gears: return "wing_gears"
        case .linkages: return "wing_linkages"
        case .machines: return "wing_machines"
        }
    }

    var tint: Color {
        switch self {
        case .house: return CogTheme.copper
        case .gears: return CogTheme.brass
        case .linkages: return CogTheme.teal
        case .machines: return CogTheme.seal
        }
    }
}

// MARK: - Mechanism specification

struct MechRenderOptions {
    var explode: CGFloat = 0
    var highlight: Set<String> = []

    func alpha(for partID: String) -> CGFloat {
        guard !highlight.isEmpty else { return 1 }
        return highlight.contains(partID) ? 1 : 0.22
    }
}

struct MechPartSpec: Identifiable {
    let id: String
    let name: String
    let role: String
    /// Label anchor in 100x100 scene coordinates.
    let anchor: CGPoint
    /// Direction the part drifts to at full explode, in scene units.
    let explode: CGVector
}

struct MechStageSpec: Identifiable {
    let id: Int
    let title: String
    let caption: String
    let highlight: [String]
    /// Segment of the master phase this stage loops over.
    let phase: ClosedRange<Double>
}

struct MechanismSpec: Identifiable {
    let id: String
    let name: String
    let wing: MechWing
    let tagline: String
    let era: String
    let history: String
    let facts: [String]
    let spotIt: [String]
    let parts: [MechPartSpec]
    let stages: [MechStageSpec]
    /// Seconds for one full animation cycle at normal speed.
    let cycleSeconds: Double
    let draw: (inout GraphicsContext, CGSize, Double, MechRenderOptions) -> Void

    var posterName: String { "poster_\(id)" }

    func part(_ id: String) -> MechPartSpec? {
        parts.first { $0.id == id }
    }
}

// MARK: - Learn content

struct CogGuideSection {
    let heading: String
    let text: String
}

struct CogGuide: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let artName: String
    let minutes: Int
    let sections: [CogGuideSection]
}

struct CogGlossaryTerm: Identifiable {
    let id: String
    let term: String
    let definition: String
}

struct CogQuizQuestion: Identifiable {
    let id: String
    let prompt: String
    let options: [String]
    let correct: Int
    let explanation: String
}

// MARK: - Ranks & badges

struct CogRank {
    let name: String
    let threshold: Int
}

enum CogRanks {
    static let all: [CogRank] = [
        CogRank(name: "Curious Visitor", threshold: 0),
        CogRank(name: "Workshop Helper", threshold: 40),
        CogRank(name: "Apprentice Tinkerer", threshold: 100),
        CogRank(name: "Gear Cadet", threshold: 180),
        CogRank(name: "Linkage Journeyman", threshold: 280),
        CogRank(name: "Clockwork Adept", threshold: 400),
        CogRank(name: "Machine Wright", threshold: 550),
        CogRank(name: "Grand Mechanist", threshold: 750),
    ]

    static func rank(for xp: Int) -> (index: Int, rank: CogRank) {
        var idx = 0
        for (i, r) in all.enumerated() where xp >= r.threshold { idx = i }
        return (idx, all[idx])
    }

    static func next(after xp: Int) -> CogRank? {
        all.first { $0.threshold > xp }
    }
}

struct CogBadge: Identifiable {
    let id: String
    let name: String
    let detail: String
    let check: (CogProgressState) -> Bool
}

enum CogBadges {
    static let all: [CogBadge] = [
        CogBadge(id: "first-mech", name: "First Peek Inside", detail: "Fully understand your first mechanism.") { $0.understoodIDs.count >= 1 },
        CogBadge(id: "wing-house", name: "House Explorer", detail: "Understand every Around the House mechanism.") { $0.wingDone(.house) },
        CogBadge(id: "wing-gears", name: "Gear Master", detail: "Understand every Gear Works mechanism.") { $0.wingDone(.gears) },
        CogBadge(id: "wing-linkages", name: "Linkage Guru", detail: "Understand every Cranks & Linkages mechanism.") { $0.wingDone(.linkages) },
        CogBadge(id: "wing-machines", name: "Machine Tamer", detail: "Understand every Great Machines mechanism.") { $0.wingDone(.machines) },
        CogBadge(id: "all-mechs", name: "Grand Collection", detail: "Understand all 16 mechanisms in the library.") { $0.understoodIDs.count >= MechLibrary.all.count },
        CogBadge(id: "streak-3", name: "Regular Visitor", detail: "Visit the workshop 3 days in a row.") { $0.streak >= 3 },
        CogBadge(id: "streak-7", name: "Weekly Wrench", detail: "Visit the workshop 7 days in a row.") { $0.streak >= 7 },
        CogBadge(id: "streak-14", name: "Fortnight Fixer", detail: "Visit the workshop 14 days in a row.") { $0.streak >= 14 },
        CogBadge(id: "quiz-first", name: "Quiz Starter", detail: "Finish your first quiz round.") { $0.quizRounds >= 1 },
        CogBadge(id: "quiz-perfect", name: "Flawless Ten", detail: "Score a perfect 10 in one quiz round.") { $0.quizPerfects >= 1 },
        CogBadge(id: "quiz-5", name: "Quiz Regular", detail: "Finish 5 quiz rounds.") { $0.quizRounds >= 5 },
        CogBadge(id: "quiz-25", name: "Sharp Eye", detail: "Answer 25 quiz questions correctly in total.") { $0.quizCorrectTotal >= 25 },
        CogBadge(id: "guide-first", name: "Manual Reader", detail: "Read your first field guide.") { $0.guidesRead.count >= 1 },
        CogBadge(id: "guide-all", name: "Shop Bookworm", detail: "Read all 8 field guides.") { $0.guidesRead.count >= 8 },
        CogBadge(id: "explode-10", name: "Exploded View", detail: "Pull mechanisms apart 10 times.") { $0.explodeCount >= 10 },
        CogBadge(id: "crank-50", name: "Crank Turner", detail: "Hand-crank 50 full cycles.") { $0.crankCycles >= 50 },
        CogBadge(id: "stages-32", name: "Half the Secrets", detail: "Complete 32 walkthrough steps.") { $0.stagesDoneCount >= 32 },
        CogBadge(id: "daily-5", name: "Day by Day", detail: "Open the Mechanism of the Day on 5 days.") { $0.dailyOpenDays.count >= 5 },
        CogBadge(id: "parts-40", name: "Parts Spotter", detail: "Inspect 40 labelled parts up close.") { $0.partTaps >= 40 },
    ]
}
