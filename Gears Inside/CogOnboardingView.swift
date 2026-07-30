import SwiftUI

struct CogOnboardingView: View {
    let onDone: () -> Void
    @State private var page = 0

    private struct Slide {
        let art: String
        let title: String
        let text: String
    }

    private let slides: [Slide] = [
        Slide(art: "onboard_1",
              title: "Every machine has a secret",
              text: "Zippers, locks, clocks and engines all hide beautiful little mechanisms. Gears Inside opens them up — drawn live, layer by layer."),
        Slide(art: "onboard_2",
              title: "Crank it with your finger",
              text: "Drag to turn each mechanism at your own pace, pull it apart with the Apart slider, and tap any part to learn its job."),
        Slide(art: "onboard_3",
              title: "Master all sixteen",
              text: "Walk the numbered steps, earn ranks and awards, keep your streak alive — and take on the workshop quiz."),
    ]

    var body: some View {
        ZStack {
            CogTheme.paper.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { idx, slide in
                        VStack(spacing: 22) {
                            Spacer(minLength: 10)
                            CogArtImage(name: slide.art, corner: 26)
                                .aspectRatio(0.86, contentMode: .fit)
                                .frame(maxWidth: 420, maxHeight: 470)
                                .clipped()
                                .padding(.horizontal, 30)
                            VStack(spacing: 10) {
                                Text(slide.title)
                                    .font(CogTheme.title(25))
                                    .foregroundColor(CogTheme.ink)
                                    .multilineTextAlignment(.center)
                                Text(slide.text)
                                    .font(CogTheme.body(14.5))
                                    .foregroundColor(CogTheme.inkSoft)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                    .padding(.horizontal, 34)
                                    .frame(maxWidth: 480)
                            }
                            Spacer(minLength: 10)
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                HStack(spacing: 7) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? CogTheme.brass : CogTheme.paperDeep)
                            .frame(width: i == page ? 22 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: page)
                    }
                }
                .padding(.bottom, 18)

                Button {
                    if page < slides.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onDone()
                    }
                } label: {
                    Text(page < slides.count - 1 ? "Continue" : "Open the workshop")
                        .font(CogTheme.body(16, weight: .bold))
                        .foregroundColor(CogTheme.card)
                        .frame(maxWidth: 420)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(CogTheme.brass))
                        .padding(.horizontal, 30)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                Button {
                    onDone()
                } label: {
                    Text("Skip")
                        .font(CogTheme.body(13, weight: .semibold))
                        .foregroundColor(CogTheme.inkSoft)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
            }
        }
    }
}
