import SwiftUI

struct CogLaunchScreen: View {
    @State private var spin = false

    var body: some View {
        ZStack {
            CogTheme.blueprint.ignoresSafeArea()
            VStack(spacing: 26) {
                ZStack {
                    GearGlyph(teeth: 10)
                        .fill(CogTheme.brass, style: FillStyle(eoFill: true))
                        .frame(width: 96, height: 96)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: spin)
                    GearGlyph(teeth: 8)
                        .fill(CogTheme.copperLight, style: FillStyle(eoFill: true))
                        .frame(width: 52, height: 52)
                        .offset(x: 62, y: 44)
                        .rotationEffect(.degrees(spin ? -360 : 0), anchor: .center)
                        .animation(.linear(duration: 4.4).repeatForever(autoreverses: false), value: spin)
                }
                .frame(width: 160, height: 150)

                VStack(spacing: 8) {
                    Text("Gears Inside")
                        .font(CogTheme.title(34))
                        .foregroundColor(CogTheme.card)
                    Text("See how everything works")
                        .font(CogTheme.body(15))
                        .foregroundColor(CogTheme.gridLine)
                }
            }
        }
        .onAppear { spin = true }
    }
}
