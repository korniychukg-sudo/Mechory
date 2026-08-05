import SwiftUI

struct QuizView: View {
    @EnvironmentObject var store: CogStore

    @State private var round: [CogQuizQuestion] = []
    @State private var index = 0
    @State private var picked: Int? = nil
    @State private var correctCount = 0
    @State private var finished = false
    @State private var recorded = false

    private let roundSize = 10

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if finished {
                    results
                } else if round.indices.contains(index) {
                    questionCard(round[index])
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .cogColumn(660)
        }
        .background(CogTheme.paper.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Workshop Quiz")
                    .font(CogTheme.title(17))
                    .foregroundColor(CogTheme.ink)
            }
        }
        .onAppear {
            if round.isEmpty { startRound() }
        }
    }

    private func startRound() {
        round = Array(CogQuizContent.all.shuffled().prefix(roundSize))
        index = 0
        picked = nil
        correctCount = 0
        finished = false
        recorded = false
    }

    // MARK: Question

    private func questionCard(_ q: CogQuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 5) {
                ForEach(0..<roundSize, id: \.self) { i in
                    Capsule()
                        .fill(i < index ? CogTheme.brass :
                                (i == index ? CogTheme.teal : CogTheme.paperDeep))
                        .frame(height: 5)
                }
            }

            Text("Question \(index + 1) of \(roundSize)")
                .font(CogTheme.mono(12))
                .foregroundColor(CogTheme.inkSoft)

            Text(q.prompt)
                .font(CogTheme.title(19))
                .foregroundColor(CogTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 9) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                    optionButton(q, i: i, text: option)
                }
            }

            if let chose = picked {
                VStack(alignment: .leading, spacing: 8) {
                    Text(chose == q.correct ? "Correct!" : "Not quite.")
                        .font(CogTheme.body(14, weight: .bold))
                        .foregroundColor(chose == q.correct ? CogTheme.leaf : CogTheme.seal)
                    Text(q.explanation)
                        .font(CogTheme.body(13.5))
                        .foregroundColor(CogTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        advance()
                    } label: {
                        Text(index + 1 == roundSize ? "See results" : "Next question")
                            .font(CogTheme.body(15, weight: .bold))
                            .foregroundColor(CogTheme.card)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Capsule().fill(CogTheme.brass))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .cogCard(padding: 14)
            }
        }
    }

    private func optionButton(_ q: CogQuizQuestion, i: Int, text: String) -> some View {
        let answered = picked != nil
        let isCorrect = i == q.correct
        let isPicked = picked == i
        var bg: Color = CogTheme.card
        var fg: Color = CogTheme.ink
        if answered {
            if isCorrect { bg = CogTheme.leaf; fg = CogTheme.card }
            else if isPicked { bg = CogTheme.seal; fg = CogTheme.card }
            else { fg = CogTheme.inkSoft }
        }
        return Button {
            guard picked == nil else { return }
            picked = i
            if isCorrect {
                correctCount += 1
                CogHaptics.success()
            } else {
                CogHaptics.warning()
            }
        } label: {
            HStack {
                Text(text)
                    .font(CogTheme.body(14, weight: .semibold))
                    .foregroundColor(fg)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                if answered && isCorrect {
                    CheckGlyph()
                        .stroke(CogTheme.card, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                        .frame(width: 13, height: 13)
                }
                if answered && isPicked && !isCorrect {
                    CrossGlyph()
                        .stroke(CogTheme.card, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(bg)
                .shadow(color: CogTheme.shadow, radius: 3, y: 1))
        }
        .buttonStyle(.plain)
    }

    private func advance() {
        picked = nil
        if index + 1 == roundSize {
            finished = true
            if !recorded {
                recorded = true
                store.quizFinished(correct: correctCount, outOf: roundSize)
            }
        } else {
            index += 1
        }
    }

    // MARK: Results

    private var results: some View {
        VStack(spacing: 16) {
            ZStack {
                if correctCount == roundSize {
                    CogConfettiView(seed: 77)
                }
                VStack(spacing: 10) {
                    Text(correctCount == roundSize ? "Flawless!" :
                            (correctCount >= 7 ? "Sharp work!" :
                                (correctCount >= 4 ? "Getting there." : "The bench awaits.")))
                        .font(CogTheme.title(24))
                        .foregroundColor(CogTheme.ink)
                    Text("\(correctCount)/\(roundSize)")
                        .font(CogTheme.title(46))
                        .foregroundColor(CogTheme.brass)
                    Text("Personal best: \(store.state.quizBest)/10 · Rounds played: \(store.state.quizRounds)")
                        .font(CogTheme.body(13))
                        .foregroundColor(CogTheme.inkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CogTheme.card)
                .shadow(color: CogTheme.shadow, radius: 6, y: 2))

            Button {
                startRound()
            } label: {
                Text("Another round")
                    .font(CogTheme.body(15, weight: .bold))
                    .foregroundColor(CogTheme.card)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(CogTheme.teal))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 10)
    }
}
