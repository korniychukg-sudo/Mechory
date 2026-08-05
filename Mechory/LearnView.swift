import SwiftUI

// MARK: - Field guides list (pushed from the Library's Reading Nook)

struct GuidesListView: View {
    @EnvironmentObject var store: CogStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Long reads from the workshop shelf.")
                        .font(CogTheme.body(13))
                        .foregroundColor(CogTheme.inkSoft)
                    Spacer()
                    Text("\(store.state.guidesRead.count)/\(CogLearnContent.guides.count) read")
                        .font(CogTheme.mono(12))
                        .foregroundColor(CogTheme.inkSoft)
                }
                .padding(.top, 8)

                VStack(spacing: 10) {
                    ForEach(Array(CogLearnContent.guides.enumerated()), id: \.element.id) { idx, guide in
                        NavigationLink {
                            GuideDetailView(guide: guide).environmentObject(store)
                        } label: {
                            guideRow(guide)
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
                Text("Field Guides")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
    }

    private func guideRow(_ guide: CogGuide) -> some View {
        HStack(spacing: 12) {
            CogArtImage(name: guide.artName, corner: 12)
                .frame(width: 80, height: 58)
                .clipped()
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(CogTheme.body(15, weight: .bold))
                    .foregroundColor(CogTheme.ink)
                Text(guide.subtitle)
                    .font(CogTheme.body(12))
                    .foregroundColor(CogTheme.inkSoft)
                    .lineLimit(2)
                Text("\(guide.minutes) min read")
                    .font(CogTheme.mono(10.5))
                    .foregroundColor(CogTheme.teal)
            }
            Spacer(minLength: 0)
            if store.state.guidesRead.contains(guide.id) {
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
        .cogCard(padding: 12, corner: 16)
    }
}

// MARK: - Glossary (pushed from the Library's Reading Nook)

struct GlossaryView: View {
    @State private var search = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Search terms", text: $search)
                    .font(CogTheme.body(14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(CogTheme.card)
                        .shadow(color: CogTheme.shadow, radius: 3, y: 1))
                    .disableAutocorrection(true)
                    .padding(.top, 8)

                let filtered = CogLearnContent.glossary.filter {
                    search.isEmpty
                        || $0.term.localizedCaseInsensitiveContains(search)
                        || $0.definition.localizedCaseInsensitiveContains(search)
                }
                if filtered.isEmpty {
                    Text("No matching terms - try another word.")
                        .font(CogTheme.body(13))
                        .foregroundColor(CogTheme.inkSoft)
                        .padding(.vertical, 8)
                }
                VStack(spacing: 8) {
                    ForEach(filtered) { term in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(term.term)
                                .font(CogTheme.body(14, weight: .bold))
                                .foregroundColor(CogTheme.ink)
                            Text(term.definition)
                                .font(CogTheme.body(12.5))
                                .foregroundColor(CogTheme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cogCard(padding: 12, corner: 14)
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
                Text("Workshop Dictionary")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
    }
}

// MARK: - Guide detail

struct GuideDetailView: View {
    @EnvironmentObject var store: CogStore
    let guide: CogGuide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomLeading) {
                    CogArtImage(name: guide.artName, corner: 20)
                        .frame(height: 170)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(colors: [Color.clear, CogTheme.ink.opacity(0.6)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(guide.title)
                            .font(CogTheme.title(22))
                            .foregroundColor(.white)
                        Text(guide.subtitle)
                            .font(CogTheme.body(13))
                            .foregroundColor(.white.opacity(0.88))
                    }
                    .padding(14)
                }
                .padding(.top, 6)

                ForEach(Array(guide.sections.enumerated()), id: \.offset) { idx, section in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("\(idx + 1)")
                                .font(CogTheme.mono(12))
                                .foregroundColor(CogTheme.card)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(CogTheme.brass))
                            Text(section.heading)
                                .font(CogTheme.title(17))
                                .foregroundColor(CogTheme.ink)
                        }
                        Text(section.text)
                            .font(CogTheme.body(14))
                            .foregroundColor(CogTheme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                    }
                    .cogCard()
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
                Text(guide.title)
                    .font(CogTheme.title(16))
                    .foregroundColor(CogTheme.ink)
                    .lineLimit(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                store.guideRead(guide.id)
            }
        }
    }
}
