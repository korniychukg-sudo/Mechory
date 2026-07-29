import SwiftUI

/// Celebration burst: falling brass cogs, sparks and paper strips.
struct CogConfettiView: View {
    let seed: Int
    @State private var progress: CGFloat = 0

    private struct Particle {
        let x: CGFloat
        let delay: CGFloat
        let speed: CGFloat
        let size: CGFloat
        let spin: Double
        let color: Color
        let kind: Int
    }

    private var particles: [Particle] {
        var items: [Particle] = []
        var state = UInt64(truncatingIfNeeded: seed &* 2654435761 &+ 12345)
        func nextUnit() -> CGFloat {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat((state >> 33) % 10_000) / 10_000
        }
        let colors: [Color] = [CogTheme.brass, CogTheme.gold, CogTheme.teal,
                               CogTheme.copper, CogTheme.seal, CogTheme.brassLight]
        for i in 0..<52 {
            items.append(Particle(
                x: nextUnit(),
                delay: nextUnit() * 0.35,
                speed: 0.75 + nextUnit() * 0.6,
                size: 6 + nextUnit() * 8,
                spin: Double(nextUnit()) * 720 - 360,
                color: colors[i % colors.count],
                kind: i % 3))
        }
        return items
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(particles.enumerated()), id: \.offset) { _, part in
                    let local = max(0, min(1, (progress - part.delay) / max(part.speed, 0.01)))
                    Group {
                        switch part.kind {
                        case 0:
                            GearGlyph(teeth: 6)
                                .fill(part.color, style: FillStyle(eoFill: true))
                        case 1:
                            RoundedRectangle(cornerRadius: 2)
                                .fill(part.color)
                        default:
                            StarGlyph().fill(part.color)
                        }
                    }
                    .frame(width: part.size, height: part.size * (part.kind == 1 ? 1.7 : 1))
                    .rotationEffect(.degrees(part.spin * Double(local)))
                    .position(x: part.x * geo.size.width,
                              y: -20 + local * (geo.size.height + 60))
                    .opacity(local < 0.86 ? 1 : Double(1 - (local - 0.86) / 0.14))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeIn(duration: 2.4)) { progress = 1.4 }
        }
    }
}
