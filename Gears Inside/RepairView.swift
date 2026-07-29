import SwiftUI

// MARK: - Repair Corner list

struct RepairListView: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2).fill(CogTheme.seal).frame(width: 4)
                    Text("Real fixes for real things — every one powered by a mechanism you can study on the bench.")
                        .font(CogTheme.body(13.5))
                        .foregroundColor(CogTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .cogCard(padding: 13)
                .padding(.top, 6)

                VStack(spacing: 10) {
                    ForEach(Array(CogRepairContent.all.enumerated()), id: \.element.id) { idx, guide in
                        NavigationLink {
                            RepairDetailView(guide: guide)
                                .environmentObject(store)
                        } label: {
                            repairRow(guide)
                        }
                        .buttonStyle(CogPressStyle())
                        .cogAppear(idx)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Repair Corner")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
    }

    private func repairRow(_ guide: CogRepairGuide) -> some View {
        let read = store.state.repairsRead.contains(guide.id)
        return HStack(spacing: 12) {
            CogArtImage(name: guide.artName, corner: 12)
                .frame(width: 76, height: 58)
                .clipped()
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(CogTheme.body(14.5, weight: .bold))
                    .foregroundColor(CogTheme.ink)
                Text(guide.symptom)
                    .font(CogTheme.body(11.5))
                    .foregroundColor(CogTheme.inkSoft)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            if read {
                ZStack {
                    Circle().fill(CogTheme.leaf.opacity(0.15)).frame(width: 26, height: 26)
                    CheckGlyph()
                        .stroke(CogTheme.leaf, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 12, height: 12)
                }
            } else {
                ChevronGlyph()
                    .stroke(CogTheme.inkSoft.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                    .frame(width: 12, height: 12)
            }
        }
        .cogCard(padding: 11, corner: 16)
    }
}

// MARK: - Repair detail

struct RepairDetailView: View {
    @EnvironmentObject var store: CogStore
    let guide: CogRepairGuide

    private var mech: MechanismSpec? {
        MechLibrary.byID(guide.mechID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ZStack(alignment: .bottomLeading) {
                    CogArtImage(name: guide.artName, corner: 20)
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.6)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    Text(guide.title)
                        .font(CogTheme.title(21))
                        .foregroundColor(.white)
                        .padding(14)
                }
                .padding(.top, 6)

                // Symptom.
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2).fill(CogTheme.seal).frame(width: 4)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("The symptom")
                            .font(CogTheme.body(11, weight: .bold))
                            .foregroundColor(CogTheme.seal)
                        Text(guide.symptom)
                            .font(CogTheme.body(14, weight: .semibold))
                            .foregroundColor(CogTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .cogCard(padding: 13)

                // Why + mechanism link.
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it happens")
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.ink)
                    Text(guide.why)
                        .font(CogTheme.body(13.5))
                        .foregroundColor(CogTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                    if let mech = mech {
                        NavigationLink {
                            MechanismView(spec: mech)
                                .environmentObject(store)
                        } label: {
                            HStack(spacing: 8) {
                                GearGlyph(teeth: 8)
                                    .fill(mech.wing.tint, style: FillStyle(eoFill: true))
                                    .frame(width: 16, height: 16)
                                Text("See the mechanism: \(mech.name)")
                                    .font(CogTheme.body(12.5, weight: .bold))
                                    .foregroundColor(mech.wing.tint)
                                ChevronGlyph()
                                    .stroke(mech.wing.tint, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                    .frame(width: 9, height: 9)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(mech.wing.tint.opacity(0.12)))
                        }
                        .buttonStyle(CogPressStyle())
                    }
                }
                .cogCard()

                // Steps.
                VStack(alignment: .leading, spacing: 10) {
                    Text("The fix")
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.ink)
                    ForEach(Array(guide.steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(idx + 1)")
                                .font(CogTheme.mono(12))
                                .foregroundColor(CogTheme.card)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(CogTheme.teal))
                            Text(step)
                                .font(CogTheme.body(13.5))
                                .foregroundColor(CogTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .cogCard()

                // Prevention.
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keep it from coming back")
                        .font(CogTheme.title(17))
                        .foregroundColor(CogTheme.ink)
                    ForEach(Array(guide.prevention.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: 9) {
                            Circle().fill(CogTheme.leaf).frame(width: 6, height: 6).padding(.top, 6)
                            Text(tip)
                                .font(CogTheme.body(13))
                                .foregroundColor(CogTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .cogCard()

                // Pro note.
                HStack(alignment: .top, spacing: 10) {
                    StarGlyph().fill(CogTheme.gold).frame(width: 16, height: 16).padding(.top, 2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Call a pro when…")
                            .font(CogTheme.body(11, weight: .bold))
                            .foregroundColor(CogTheme.brass)
                        Text(guide.proNote)
                            .font(CogTheme.body(13))
                            .foregroundColor(CogTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .cogCard(padding: 13)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
            .cogColumn(720)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(guide.title)
                    .font(CogTheme.title(16))
                    .foregroundColor(CogTheme.ink)
                    .lineLimit(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                store.repairRead(guide.id)
            }
        }
    }
}
