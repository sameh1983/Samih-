import SwiftUI

struct CellView: View {
    let cell: Cell
    let size: CGFloat
    let gameOver: Bool

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var background: some View {
        switch cell.state {
        case .hidden, .flagged:
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.92), Color(white: 0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(white: 0.55), lineWidth: 0.5)
                )
        case .revealed:
            let bg: Color = cell.explodedHere ? .red : Color(white: 0.85)
            RoundedRectangle(cornerRadius: 2)
                .fill(bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(white: 0.65), lineWidth: 0.5)
                )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch cell.state {
        case .hidden:
            EmptyView()
        case .flagged:
            if gameOver && !cell.isMine {
                Image(systemName: "xmark")
                    .font(.system(size: size * 0.55, weight: .bold))
                    .foregroundColor(.red)
            } else {
                Image(systemName: "flag.fill")
                    .font(.system(size: size * 0.55))
                    .foregroundColor(.red)
            }
        case .revealed:
            if cell.isMine {
                Image(systemName: "burst.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.black)
            } else if cell.adjacentMines > 0 {
                Text("\(cell.adjacentMines)")
                    .font(.system(size: size * 0.65, weight: .heavy, design: .rounded))
                    .foregroundColor(numberColor(cell.adjacentMines))
            }
        }
    }

    private func numberColor(_ n: Int) -> Color {
        switch n {
        case 1: return Color(red: 0.0, green: 0.0, blue: 0.9)
        case 2: return Color(red: 0.0, green: 0.55, blue: 0.0)
        case 3: return Color(red: 0.85, green: 0.0, blue: 0.0)
        case 4: return Color(red: 0.0, green: 0.0, blue: 0.5)
        case 5: return Color(red: 0.5, green: 0.0, blue: 0.0)
        case 6: return Color(red: 0.0, green: 0.5, blue: 0.5)
        case 7: return .black
        case 8: return Color(white: 0.4)
        default: return .black
        }
    }
}
