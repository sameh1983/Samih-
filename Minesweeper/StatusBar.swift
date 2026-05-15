import SwiftUI

struct StatusBar: View {
    @ObservedObject var game: GameModel

    var body: some View {
        HStack {
            digitDisplay(game.remainingMines)
            Spacer()
            Button(action: { game.newGame() }) {
                Text(faceEmoji)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.92), Color(white: 0.78)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(white: 0.55), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            Spacer()
            digitDisplay(game.elapsedSeconds)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.75))
        )
    }

    private var faceEmoji: String {
        switch game.status {
        case .ready, .playing: return "🙂"
        case .won: return "😎"
        case .lost: return "😵"
        }
    }

    private func digitDisplay(_ value: Int) -> some View {
        let clamped = max(-99, min(999, value))
        let text: String
        if clamped < 0 {
            text = "-\(String(format: "%02d", abs(clamped)))"
        } else {
            text = String(format: "%03d", clamped)
        }
        return Text(text)
            .font(.system(size: 30, weight: .heavy, design: .monospaced))
            .foregroundColor(.red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black)
            .cornerRadius(4)
    }
}
