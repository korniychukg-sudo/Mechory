import SwiftUI

// MARK: - Gear sizes

enum BenchGearSize: String, CaseIterable, Codable {
    case small, medium, large, grand

    var teeth: Int {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .grand: return 24
        }
    }

    /// Pitch radius in pegboard hole units. Mesh happens when the distance
    /// between centres equals the sum of two radii (within tolerance).
    var radius: Double {
        switch self {
        case .small: return 1.0
        case .medium: return 1.5
        case .large: return 2.0
        case .grand: return 3.0
        }
    }

    var metal: MechMetal {
        switch self {
        case .small: return .copper
        case .medium: return .brass
        case .large: return .steel
        case .grand: return .gold
        }
    }

    var label: String {
        switch self {
        case .small: return "8t"
        case .medium: return "12t"
        case .large: return "16t"
        case .grand: return "24t"
        }
    }
}

// MARK: - A mounted gear

struct BenchGear: Identifiable, Equatable {
    let id: String
    let col: Int
    let row: Int
    let size: BenchGearSize
    var omega: Double = 0          // signed turns/sec relative to motor speed 1
    var jammed: Bool = false
    var isMotor: Bool = false
}

// MARK: - The board + solver

struct BenchBoard {
    var cols: Int = 7
    var rows: Int = 9
    var motorCol: Int = 1
    var motorRow: Int = 1
    var motorSize: BenchGearSize = .medium
    /// Special marked holes challenges care about.
    var outputs: [(col: Int, row: Int)] = []
    /// User-placed gears (excludes the motor).
    var placed: [BenchPlacement] = []

    static let meshTolerance = 0.18
    static let jamTolerance = 0.01

    func isFree(col: Int, row: Int) -> Bool {
        guard col >= 0, col < cols, row >= 0, row < rows else { return false }
        if col == motorCol && row == motorRow { return false }
        return !placed.contains { $0.col == col && $0.row == row }
    }

    /// A new gear may touch (mesh) but never overlap an existing one.
    func canPlace(col: Int, row: Int, size: BenchGearSize) -> Bool {
        guard isFree(col: col, row: row) else { return false }
        for g in allGears {
            let d = hypot(Double(g.col - col), Double(g.row - row))
            if d < g.size.radius + size.radius - Self.meshTolerance {
                return false
            }
        }
        return true
    }

    mutating func place(col: Int, row: Int, size: BenchGearSize) {
        guard canPlace(col: col, row: row, size: size) else { return }
        placed.append(BenchPlacement(col: col, row: row, size: size.rawValue))
    }

    mutating func remove(col: Int, row: Int) {
        placed.removeAll { $0.col == col && $0.row == row }
    }

    mutating func clear() {
        placed.removeAll()
    }

    /// Drop any stored placement that no longer fits the grid or overlaps.
    mutating func sanitize() {
        var seen = Set<String>()
        placed = placed.filter { p in
            guard p.col >= 0, p.col < cols, p.row >= 0, p.row < rows else { return false }
            guard !(p.col == motorCol && p.row == motorRow) else { return false }
            guard BenchGearSize(rawValue: p.size) != nil else { return false }
            let key = "\(p.col):\(p.row)"
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    /// All gears including the motor, before solving.
    var allGears: [BenchGear] {
        var gears = [BenchGear(id: "motor", col: motorCol, row: motorRow,
                               size: motorSize, isMotor: true)]
        for p in placed {
            guard let size = BenchGearSize(rawValue: p.size) else { continue }
            gears.append(BenchGear(id: "g\(p.col):\(p.row)", col: p.col, row: p.row, size: size))
        }
        return gears
    }

    static func meshes(_ a: BenchGear, _ b: BenchGear) -> Bool {
        let d = hypot(Double(a.col - b.col), Double(a.row - b.row))
        return abs(d - (a.size.radius + b.size.radius)) <= meshTolerance
    }

    /// BFS from the motor: assign each connected gear its signed speed.
    /// A gear reachable with two inconsistent speeds jams the whole train.
    func solved() -> (gears: [BenchGear], jammed: Bool) {
        var gears = allGears
        guard let motorIdx = gears.firstIndex(where: { $0.isMotor }) else {
            return (gears, false)
        }
        // Adjacency by mesh test.
        var adj: [Int: [Int]] = [:]
        for i in gears.indices {
            for j in gears.indices where j > i {
                if Self.meshes(gears[i], gears[j]) {
                    adj[i, default: []].append(j)
                    adj[j, default: []].append(i)
                }
            }
        }
        var omega: [Int: Double] = [motorIdx: 1.0]
        var queue = [motorIdx]
        var jam = false
        while !queue.isEmpty {
            let cur = queue.removeFirst()
            let w = omega[cur] ?? 0
            for next in adj[cur] ?? [] {
                let expected = -w * Double(gears[cur].size.teeth) / Double(gears[next].size.teeth)
                if let existing = omega[next] {
                    if abs(existing - expected) > Self.jamTolerance * max(abs(existing), 1) {
                        jam = true
                    }
                } else {
                    omega[next] = expected
                    queue.append(next)
                }
            }
        }
        for i in gears.indices {
            if jam {
                // The whole connected train freezes.
                gears[i].omega = 0
                gears[i].jammed = omega[i] != nil
            } else {
                gears[i].omega = omega[i] ?? 0
            }
        }
        return (gears, jam)
    }

    /// Signed speed (relative to the motor) of the gear sitting exactly on a
    /// given hole, nil when the hole is empty or the train is jammed.
    func omegaAt(col: Int, row: Int) -> Double? {
        let result = solved()
        guard !result.jammed else { return nil }
        guard let gear = result.gears.first(where: { $0.col == col && $0.row == row }),
              gear.omega != 0 else { return nil }
        return gear.omega
    }

    /// Count of user-placed gears (motor excluded).
    var placedCount: Int { placed.count }
}

// MARK: - DEBUG self test

#if DEBUG
func benchSolverSelfTest() {
    // 8t drives 16t two holes away (r 1.0 + 2.0 = 3.0): half speed, reversed.
    var b = BenchBoard(cols: 9, rows: 4, motorCol: 1, motorRow: 1, motorSize: .small)
    b.place(col: 4, row: 1, size: .large)
    var r = b.solved()
    assert(!r.jammed, "8t+16t should mesh cleanly")
    let g = r.gears.first { $0.col == 4 }!
    assert(abs(g.omega - (-0.5)) < 0.001, "16t driven by 8t must run at -0.5, got \(g.omega)")

    // 24t motor drives 8t (r 3.0 + 1.0 = 4.0): triple speed, reversed.
    var b2 = BenchBoard(cols: 9, rows: 4, motorCol: 1, motorRow: 1, motorSize: .grand)
    b2.place(col: 5, row: 1, size: .small)
    r = b2.solved()
    assert(!r.jammed)
    let s = r.gears.first { $0.col == 5 }!
    assert(abs(s.omega - (-3.0)) < 0.001, "8t driven by 24t must run at -3.0, got \(s.omega)")

    // Idler chain 8t -> 8t -> 8t: same speed as motor, same direction at the end.
    var b3 = BenchBoard(cols: 9, rows: 4, motorCol: 1, motorRow: 1, motorSize: .small)
    b3.place(col: 3, row: 1, size: .small)
    b3.place(col: 5, row: 1, size: .small)
    r = b3.solved()
    assert(!r.jammed)
    let end = r.gears.first { $0.col == 5 }!
    assert(abs(end.omega - 1.0) < 0.001, "two idlers restore +1.0, got \(end.omega)")

    // Even loop with equal teeth: square of four 12t gears (side 3 = r1.5+r1.5)
    // is consistent — the corner hears +1 via both paths, no jam.
    var b5 = BenchBoard(cols: 12, rows: 12, motorCol: 2, motorRow: 2, motorSize: .medium)
    b5.place(col: 5, row: 2, size: .medium)   // right
    b5.place(col: 2, row: 5, size: .medium)   // down
    b5.place(col: 5, row: 5, size: .medium)   // corner: meshes both neighbours
    let r5 = b5.solved()
    // Loop of even length with equal teeth is consistent (no jam): corner gets
    // +1 via both paths.
    assert(!r5.jammed, "even 12t square must stay consistent")
    let corner = r5.gears.first { $0.col == 5 && $0.row == 5 }!
    assert(abs(corner.omega - 1.0) < 0.001, "corner of 12t square runs +1, got \(corner.omega)")

    // Odd cycle must jam: triangle small–small–large. Sides: motor s(2,2) to
    // s(4,2) is d2 (1+1); each small to l(3,5) is d≈3.16, within tolerance of
    // s+l = 3. The large hears -0.5 via the motor but +0.5 via the second
    // small → conflict.
    var b7 = BenchBoard(cols: 14, rows: 14, motorCol: 2, motorRow: 2, motorSize: .small)
    b7.place(col: 4, row: 2, size: .small)
    b7.place(col: 3, row: 5, size: .large)
    assert(b7.placed.count == 2, "triangle gears must pass canPlace")
    let r7 = b7.solved()
    assert(r7.jammed, "odd cycle must jam")
    print("BENCH SELFTEST OK")
}
#endif
