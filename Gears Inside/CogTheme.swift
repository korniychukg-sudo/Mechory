import SwiftUI

/// Workshop-manual palette: warm paper, blueprint navy, brass and copper metals.
enum CogTheme {
    static let paper = Color(red: 0.965, green: 0.937, blue: 0.886)      // warm cream page
    static let paperDeep = Color(red: 0.929, green: 0.890, blue: 0.816)  // darker cream
    static let card = Color(red: 0.988, green: 0.973, blue: 0.937)       // raised card
    static let ink = Color(red: 0.098, green: 0.145, blue: 0.243)        // deep navy ink
    static let inkSoft = Color(red: 0.098, green: 0.145, blue: 0.243).opacity(0.62)
    static let blueprint = Color(red: 0.114, green: 0.180, blue: 0.298)  // stage backdrop
    static let blueprintHi = Color(red: 0.165, green: 0.255, blue: 0.408)
    static let gridLine = Color(red: 0.427, green: 0.553, blue: 0.698)
    static let brass = Color(red: 0.788, green: 0.588, blue: 0.235)
    static let brassLight = Color(red: 0.914, green: 0.757, blue: 0.443)
    static let brassDark = Color(red: 0.596, green: 0.427, blue: 0.145)
    static let copper = Color(red: 0.698, green: 0.416, blue: 0.271)
    static let copperLight = Color(red: 0.851, green: 0.573, blue: 0.404)
    static let steel = Color(red: 0.557, green: 0.608, blue: 0.667)
    static let steelLight = Color(red: 0.761, green: 0.796, blue: 0.835)
    static let steelDark = Color(red: 0.373, green: 0.420, blue: 0.478)
    static let teal = Color(red: 0.180, green: 0.431, blue: 0.494)
    static let tealLight = Color(red: 0.365, green: 0.612, blue: 0.671)
    static let gold = Color(red: 0.941, green: 0.765, blue: 0.306)
    static let seal = Color(red: 0.710, green: 0.325, blue: 0.235)       // wax-seal red
    static let sealSoft = Color(red: 0.710, green: 0.325, blue: 0.235).opacity(0.14)
    static let leaf = Color(red: 0.373, green: 0.541, blue: 0.396)       // success green

    static let shadow = Color(red: 0.098, green: 0.145, blue: 0.243).opacity(0.16)

    // Typography — serif titles give the old-manual feel.
    static func title(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

/// Content column cap so iPad layouts stay composed.
struct CogColumn: ViewModifier {
    var max: CGFloat = 700
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: max)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func cogColumn(_ max: CGFloat = 700) -> some View { modifier(CogColumn(max: max)) }

    func cogCard(padding: CGFloat = 16, corner: CGFloat = 18) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(CogTheme.card)
                    .shadow(color: CogTheme.shadow, radius: 7, x: 0, y: 3)
            )
    }
}

/// Section heading used across list screens.
struct CogSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(CogTheme.title(21))
                .foregroundColor(CogTheme.ink)
            if let s = subtitle {
                Text(s)
                    .font(CogTheme.body(13))
                    .foregroundColor(CogTheme.inkSoft)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Small stamped tag ("chip") used for statuses and counts.
struct CogTag: View {
    let text: String
    var color: Color = CogTheme.teal
    var filled: Bool = false
    var body: some View {
        Text(text)
            .font(CogTheme.body(11, weight: .bold))
            .foregroundColor(filled ? CogTheme.card : color)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(filled ? color : color.opacity(0.13))
            )
    }
}

/// Bundled generated artwork loader with graceful fallback.
enum CogArt {
    static func uiImage(_ name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Art") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

struct CogArtImage: View {
    let name: String
    var corner: CGFloat = 0

    var body: some View {
        Group {
            if let img = CogArt.uiImage(name) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [CogTheme.blueprintHi, CogTheme.blueprint],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}

/// Staggered entrance: soft fade + rise, delayed by position.
struct CogAppear: ViewModifier {
    let index: Int
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(Double(index) * 0.07)) {
                    shown = true
                }
            }
    }
}

/// Pressed-scale feedback for cards.
struct CogPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    func cogAppear(_ index: Int) -> some View { modifier(CogAppear(index: index)) }
}

/// Custom drag slider — no system components anywhere in the app.
struct CogSlider: View {
    @Binding var value: CGFloat        // 0...1
    var tint: Color = CogTheme.copper

    var body: some View {
        GeometryReader { geo in
            let knob: CGFloat = 22
            let track = max(geo.size.width - knob, 1)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(CogTheme.paperDeep)
                    .frame(height: 6)
                Capsule()
                    .fill(tint)
                    .frame(width: knob / 2 + value * track, height: 6)
                Circle()
                    .fill(CogTheme.card)
                    .overlay(Circle().stroke(tint, lineWidth: 2))
                    .shadow(color: CogTheme.shadow, radius: 2, y: 1)
                    .frame(width: knob, height: knob)
                    .offset(x: value * track)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let raw = (g.location.x - knob / 2) / track
                        value = min(max(raw, 0), 1)
                    }
            )
        }
        .frame(height: 30)
    }
}

/// Light haptic helpers used by the mechanism stage and quiz.
enum CogHaptics {
    static func tick() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
    }
    static func thud() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
