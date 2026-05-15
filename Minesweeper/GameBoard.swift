import SwiftUI

struct GameBoard: View {
    @ObservedObject var game: GameModel

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 1
            let totalSpacingW = spacing * CGFloat(game.cols + 1)
            let totalSpacingH = spacing * CGFloat(game.rows + 1)
            let widthSize = (proxy.size.width - totalSpacingW) / CGFloat(game.cols)
            let heightSize = (proxy.size.height - totalSpacingH) / CGFloat(game.rows)
            let cellSize = max(14, min(widthSize, heightSize))

            VStack(spacing: spacing) {
                ForEach(0..<game.rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<game.cols, id: \.self) { col in
                            CellView(
                                cell: game.grid[row][col],
                                size: cellSize,
                                gameOver: game.status == .lost
                            )
                            .onTapGesture {
                                handleTap(row: row, col: col)
                            }
                            .onLongPressGesture(minimumDuration: 0.25) {
                                handleLongPress(row: row, col: col)
                            }
                        }
                    }
                }
            }
            .padding(spacing)
            .background(Color(white: 0.55))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func handleTap(row: Int, col: Int) {
        let cell = game.grid[row][col]
        if cell.state == .revealed && cell.adjacentMines > 0 {
            game.chord(row: row, col: col)
        } else {
            game.reveal(row: row, col: col)
        }
        haptic(.light)
    }

    private func handleLongPress(row: Int, col: Int) {
        game.toggleFlag(row: row, col: col)
        haptic(.medium)
    }

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
