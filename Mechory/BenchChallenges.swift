import Foundation

// MARK: - Goals

enum BenchGoal {
    case spin(output: Int)                                     // any steady motion
    case reversed(output: Int)                                 // opposite to motor
    case forward(output: Int)                                  // same direction as motor
    case ratio(output: Int, target: Double, tol: Double, signed: Bool)
    case both(outputs: [Int])
    case opposite(a: Int, b: Int)
}

// MARK: - Challenge

struct BenchChallenge: Identifiable {
    let id: String
    let title: String
    let brief: String
    let hint: String
    let motorCol: Int
    let motorRow: Int
    let motorSize: BenchGearSize
    let outputs: [(col: Int, row: Int)]
    let goal: BenchGoal
    /// A worked solution — used by the DEBUG self-test to guarantee every
    /// challenge stays solvable on the real board.
    let solution: [BenchPlacement]

    func makeBoard() -> BenchBoard {
        var b = BenchBoard()
        b.motorCol = motorCol
        b.motorRow = motorRow
        b.motorSize = motorSize
        b.outputs = outputs
        return b
    }

    private func outputOmega(_ board: BenchBoard, _ idx: Int) -> Double? {
        guard outputs.indices.contains(idx) else { return nil }
        let hole = outputs[idx]
        return board.omegaAt(col: hole.col, row: hole.row)
    }

    func isMet(_ board: BenchBoard) -> Bool {
        switch goal {
        case .spin(let o):
            return outputOmega(board, o) != nil
        case .reversed(let o):
            guard let w = outputOmega(board, o) else { return false }
            return w < 0
        case .forward(let o):
            guard let w = outputOmega(board, o) else { return false }
            return w > 0
        case .ratio(let o, let target, let tol, let signed):
            guard let w = outputOmega(board, o) else { return false }
            return signed ? abs(w - target) <= tol : abs(abs(w) - abs(target)) <= tol
        case .both(let list):
            return list.allSatisfy { outputOmega(board, $0) != nil }
        case .opposite(let a, let b):
            guard let wa = outputOmega(board, a), let wb = outputOmega(board, b) else { return false }
            return wa * wb < 0
        }
    }

    // Every challenge below ships with a verified solution (see the self-test).
    static let all: [BenchChallenge] = [
        BenchChallenge(id: "c01", title: "First Contact",
            brief: "Get the marked shaft spinning - any speed will do.",
            hint: "Two 12t wheels mesh when they sit three holes apart.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(4, 1)], goal: .spin(output: 0),
            solution: [BenchPlacement(col: 4, row: 1, size: "medium")]),

        BenchChallenge(id: "c02", title: "Turn It Around",
            brief: "Make the output spin the opposite way to the motor.",
            hint: "Any single meshed gear turns against its driver.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(1, 4)], goal: .reversed(output: 0),
            solution: [BenchPlacement(col: 1, row: 4, size: "medium")]),

        BenchChallenge(id: "c03", title: "Same Again",
            brief: "Make the output spin the SAME way as the motor.",
            hint: "You'll need a middle gear - an idler - to flip the flip.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(4, 4)], goal: .forward(output: 0),
            solution: [BenchPlacement(col: 4, row: 1, size: "medium"),
                       BenchPlacement(col: 4, row: 4, size: "medium")]),

        BenchChallenge(id: "c04", title: "Half Speed",
            brief: "Slow the output to exactly half the motor's speed.",
            hint: "8 teeth driving 16 teeth: count the ratio.",
            motorCol: 1, motorRow: 1, motorSize: .small,
            outputs: [(4, 1)], goal: .ratio(output: 0, target: 0.5, tol: 0.02, signed: false),
            solution: [BenchPlacement(col: 4, row: 1, size: "large")]),

        BenchChallenge(id: "c05", title: "Double Time",
            brief: "Make the output spin exactly twice as fast.",
            hint: "Big drives small - 16 teeth into 8.",
            motorCol: 1, motorRow: 1, motorSize: .large,
            outputs: [(4, 1)], goal: .ratio(output: 0, target: 2.0, tol: 0.05, signed: false),
            solution: [BenchPlacement(col: 4, row: 1, size: "small")]),

        BenchChallenge(id: "c06", title: "One Third",
            brief: "Gear the output down to a third of the motor's speed.",
            hint: "The 24t grand wheel is heavy - it needs room in the middle.",
            motorCol: 2, motorRow: 1, motorSize: .small,
            outputs: [(2, 5)], goal: .ratio(output: 0, target: 1.0 / 3.0, tol: 0.02, signed: false),
            solution: [BenchPlacement(col: 2, row: 5, size: "grand")]),

        BenchChallenge(id: "c07", title: "Triple Spin",
            brief: "Make the output whirl three times faster than the motor.",
            hint: "Reverse of One Third: now the grand wheel does the driving.",
            motorCol: 2, motorRow: 2, motorSize: .grand,
            outputs: [(2, 6)], goal: .ratio(output: 0, target: 3.0, tol: 0.05, signed: false),
            solution: [BenchPlacement(col: 2, row: 6, size: "small")]),

        BenchChallenge(id: "c08", title: "Across the Board",
            brief: "Carry the motor's power all the way to the far output.",
            hint: "March 12t gears three holes at a time - down, then across.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(4, 7)], goal: .spin(output: 0),
            solution: [BenchPlacement(col: 1, row: 4, size: "medium"),
                       BenchPlacement(col: 1, row: 7, size: "medium"),
                       BenchPlacement(col: 4, row: 7, size: "medium")]),

        BenchChallenge(id: "c09", title: "Both at Once",
            brief: "Drive both marked shafts from the single motor.",
            hint: "The motor can mesh two gears at the same time.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(4, 1), (1, 4)], goal: .both(outputs: [0, 1]),
            solution: [BenchPlacement(col: 4, row: 1, size: "medium"),
                       BenchPlacement(col: 1, row: 4, size: "medium")]),

        BenchChallenge(id: "c10", title: "Mirror Pair",
            brief: "Make the two outputs spin in opposite directions.",
            hint: "Chain one output off the other - neighbours always disagree.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(4, 1), (4, 4)], goal: .opposite(a: 0, b: 1),
            solution: [BenchPlacement(col: 4, row: 1, size: "medium"),
                       BenchPlacement(col: 4, row: 4, size: "medium")]),

        BenchChallenge(id: "c11", title: "Three Quarters",
            brief: "Tune the output to exactly 3/4 of the motor's speed.",
            hint: "12 teeth into 16 - the mesh sits a knight's move away.",
            motorCol: 1, motorRow: 1, motorSize: .medium,
            outputs: [(3, 4)], goal: .ratio(output: 0, target: 0.75, tol: 0.02, signed: false),
            solution: [BenchPlacement(col: 3, row: 4, size: "large")]),

        BenchChallenge(id: "c12", title: "Grand Cascade",
            brief: "Reach a third of the speed AND the same direction as the motor.",
            hint: "A small idler first, then let the grand wheel finish the job.",
            motorCol: 1, motorRow: 1, motorSize: .small,
            outputs: [(3, 5)], goal: .ratio(output: 0, target: 1.0 / 3.0, tol: 0.02, signed: true),
            solution: [BenchPlacement(col: 3, row: 1, size: "small"),
                       BenchPlacement(col: 3, row: 5, size: "grand")]),
    ]
}
