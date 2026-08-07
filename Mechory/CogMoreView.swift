import SwiftUI

struct CogMoreView: View {
    @EnvironmentObject var store: CogStore
    @State private var showResetConfirm = false
    @State private var showPrivacy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CogSectionHeader(title: "More", subtitle: "About the workshop.")
                    .padding(.top, 12)

                ZStack(alignment: .bottomLeading) {
                    CogArtImage(name: "more_banner", corner: 20)
                        .frame(height: 130)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.55)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mechory")
                            .font(CogTheme.title(20))
                            .foregroundColor(.white)
                        Text("Version 1.0")
                            .font(CogTheme.mono(11))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(14)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("About this app")
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.ink)
                    Text("Mechory is an illustrated tour of the mechanisms hiding in everyday things. Crank each movement by hand, pull it apart layer by layer, and walk its story step by step. Every mechanism, bench and guide runs on your device — no account, no ads, no tracking.")
                        .font(CogTheme.body(13.5))
                        .foregroundColor(CogTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .cogCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("How to use the bench")
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.ink)
                    bulletRow("Drag left or right across a mechanism to crank it yourself.")
                    bulletRow("Use the Apart slider to separate the layers and see what hides inside.")
                    bulletRow("Tap a labelled dot to inspect a part up close.")
                    bulletRow("Watch each numbered step for a few seconds to master a mechanism.")
                }
                .cogCard()

                Button { showPrivacy = true } label: {
                    HStack {
                        Text("Privacy Policy")
                            .font(CogTheme.body(15, weight: .semibold))
                            .foregroundColor(CogTheme.ink)
                        Spacer()
                        ChevronGlyph()
                            .stroke(CogTheme.inkSoft, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                            .frame(width: 12, height: 12)
                    }
                    .cogCard(padding: 15)
                }
                .buttonStyle(CogPressStyle())

                CogSupportCard()

                Button { showResetConfirm = true } label: {
                    HStack {
                        Text("Reset all progress")
                            .font(CogTheme.body(15, weight: .semibold))
                            .foregroundColor(CogTheme.seal)
                        Spacer()
                    }
                    .cogCard(padding: 15)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            CogGatePanel(urlString: "https://mechory.org/click.php")
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(title: Text("Reset all progress?"),
                  message: Text("Every mastered mechanism, award and streak will be cleared. This cannot be undone."),
                  primaryButton: .destructive(Text("Reset")) { store.resetAll() },
                  secondaryButton: .cancel())
        }
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Circle().fill(CogTheme.brass).frame(width: 6, height: 6).padding(.top, 6)
            Text(text)
                .font(CogTheme.body(13))
                .foregroundColor(CogTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Support address, opened in the system browser rather than in-app.
enum CogSupport {
    static let urlString = "https://www.termsfeed.com/live/e13b4910-b8db-4047-a19d-951cda90ef38"
    static var url: URL? { URL(string: urlString) }
}

/// Support row for the More screen — taps out to the browser, and always shows
/// the address as plain text so it stays usable even without a browser.
struct CogSupportCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = CogSupport.url {
                Link(destination: url) {
                    HStack {
                        Text("Support")
                            .font(CogTheme.body(15, weight: .semibold))
                            .foregroundColor(CogTheme.ink)
                        Spacer()
                        ChevronGlyph()
                            .stroke(CogTheme.inkSoft,
                                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                            .frame(width: 12, height: 12)
                    }
                }
                .buttonStyle(CogPressStyle())
            } else {
                Text("Support")
                    .font(CogTheme.body(15, weight: .semibold))
                    .foregroundColor(CogTheme.ink)
            }
            Text("Questions, problems or feedback — the support page opens in your browser:")
                .font(CogTheme.body(11.5))
                .foregroundColor(CogTheme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Text(CogSupport.urlString)
                .font(CogTheme.mono(10.5))
                .foregroundColor(CogTheme.teal)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cogCard(padding: 15)
    }
}
