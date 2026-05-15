import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()
    @State private var showingResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                StatusBar(game: game)
                GameBoard(game: game)
                    .aspectRatio(
                        CGFloat(game.cols) / CGFloat(game.rows),
                        contentMode: .fit
                    )
                    .padding(.horizontal, 4)
                Spacer(minLength: 0)
                Text("Tap to reveal · Long-press to flag · Tap a number to chord")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color(white: 0.95).ignoresSafeArea())
            .navigationTitle("Minesweeper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { game.newGame() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(Difficulty.allCases) { d in
                            Button {
                                game.setDifficulty(d)
                            } label: {
                                HStack {
                                    Text(d.rawValue)
                                    if game.difficulty == d {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Difficulty", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .onChange(of: game.status) { _, newValue in
                if newValue == .won || newValue == .lost {
                    showingResult = true
                }
            }
            .alert(
                game.status == .won ? "You Win! 🎉" : "Boom! 💥",
                isPresented: $showingResult
            ) {
                Button("New Game") { game.newGame() }
                Button("Dismiss", role: .cancel) {}
            } message: {
                Text(resultMessage)
            }
        }
    }

    private var resultMessage: String {
        switch game.status {
        case .won:
            return "Cleared \(game.difficulty.rawValue) in \(game.elapsedSeconds)s."
        case .lost:
            return "You hit a mine. Tap New Game to try again."
        default:
            return ""
        }
    }
}

#Preview {
    ContentView()
}
