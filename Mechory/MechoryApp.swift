import SwiftUI

@main
struct MechoryApp: App {
    @StateObject private var store = CogStore()

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["COG_SELFTEST"] == "1" {
            benchSolverSelfTest()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !store.state.onboardingSeen {
                    CogOnboardingView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            store.markOnboardingSeen()
                        }
                    }
                } else {
                    CogRootView()
                        .environmentObject(store)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
