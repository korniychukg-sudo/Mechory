import SwiftUI

struct CogRootView: View {
    @EnvironmentObject var store: CogStore
    @State private var selectedTab = 0
    @State private var badgeToast: CogBadge? = nil

    #if DEBUG
    private var debugMech: MechanismSpec? {
        guard let id = ProcessInfo.processInfo.environment["COG_MECH"] else { return nil }
        return MechLibrary.byID(id)
    }
    #endif

    var body: some View {
        #if DEBUG
        if let mech = debugMech {
            NavigationView { MechanismView(spec: mech).environmentObject(store) }
                .navigationViewStyle(StackNavigationViewStyle())
        } else {
            mainBody
        }
        #else
        mainBody
        #endif
    }

    private var mainBody: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { WorkshopView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { LibraryView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { LearnView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 3:
                        NavigationView { CogProgressView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { CogMoreView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }

            if let badge = badgeToast {
                badgeToastView(badge)
                    .padding(.bottom, 86)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(store.$freshBadges) { fresh in
            guard badgeToast == nil, let first = fresh.first else { return }
            presentBadge(first)
        }
        .onAppear {
            #if DEBUG
            if let tab = ProcessInfo.processInfo.environment["COG_TAB"],
               let idx = Int(tab), (0...4).contains(idx) {
                selectedTab = idx
            }
            #endif
        }
    }

    private func presentBadge(_ badge: CogBadge) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            badgeToast = badge
        }
        CogHaptics.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                badgeToast = nil
            }
            store.freshBadges.removeAll { $0.id == badge.id }
            if let next = store.freshBadges.first {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    presentBadge(next)
                }
            }
        }
    }

    private func badgeToastView(_ badge: CogBadge) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(CogTheme.gold.opacity(0.25)).frame(width: 44, height: 44)
                MedalGlyph().fill(CogTheme.brass).frame(width: 26, height: 26)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Award earned!")
                    .font(CogTheme.body(11, weight: .bold))
                    .foregroundColor(CogTheme.brass)
                Text(badge.name)
                    .font(CogTheme.body(15, weight: .bold))
                    .foregroundColor(CogTheme.ink)
                Text(badge.detail)
                    .font(CogTheme.body(11.5))
                    .foregroundColor(CogTheme.inkSoft)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(CogTheme.card)
            .shadow(color: CogTheme.shadow, radius: 10, y: 4))
        .padding(.horizontal, 24)
        .frame(maxWidth: 480)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Workshop", kind: .workshop)
            tabButton(index: 1, label: "Library", kind: .library)
            tabButton(index: 2, label: "Learn", kind: .learn)
            tabButton(index: 3, label: "Progress", kind: .progress)
            tabButton(index: 4, label: "More", kind: .more)
        }
        .padding(.top, 9)
        .padding(.bottom, 5)
        .background(
            CogTheme.card
                .shadow(color: CogTheme.shadow, radius: 8, y: -2)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(index: Int, label: String, kind: CogTabIcon.Kind) -> some View {
        let active = selectedTab == index
        return Button {
            if selectedTab != index {
                selectedTab = index
                CogHaptics.tick()
            }
        } label: {
            VStack(spacing: 4) {
                CogTabIcon(kind: kind, active: active)
                Text(label)
                    .font(CogTheme.body(10, weight: active ? .bold : .medium))
                    .foregroundColor(active ? CogTheme.brass : CogTheme.inkSoft.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(active ? CogTheme.brass.opacity(0.12) : Color.clear)
                    .padding(.horizontal, 8)
            )
        }
        .buttonStyle(.plain)
    }
}
