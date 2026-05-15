import Foundation
import SwiftUI

enum CellState: Equatable {
    case hidden
    case revealed
    case flagged
}

struct Cell: Equatable {
    var isMine: Bool = false
    var adjacentMines: Int = 0
    var state: CellState = .hidden
    var explodedHere: Bool = false
}

enum Difficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case expert = "Expert"

    var id: String { rawValue }

    var rows: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 16
        }
    }

    var cols: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 30
        }
    }

    var mines: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 40
        case .expert: return 99
        }
    }
}

enum GameStatus {
    case ready
    case playing
    case won
    case lost
}

final class GameModel: ObservableObject {
    @Published private(set) var grid: [[Cell]] = []
    @Published private(set) var difficulty: Difficulty = .beginner
    @Published private(set) var status: GameStatus = .ready
    @Published private(set) var flagCount: Int = 0
    @Published private(set) var elapsedSeconds: Int = 0

    private var minesPlaced = false
    private var timer: Timer?

    var rows: Int { difficulty.rows }
    var cols: Int { difficulty.cols }
    var mineCount: Int { difficulty.mines }
    var remainingMines: Int { max(0, mineCount - flagCount) }

    init() {
        newGame()
    }

    deinit {
        timer?.invalidate()
    }

    func setDifficulty(_ d: Difficulty) {
        difficulty = d
        newGame()
    }

    func newGame() {
        stopTimer()
        elapsedSeconds = 0
        flagCount = 0
        status = .ready
        minesPlaced = false
        grid = Array(
            repeating: Array(repeating: Cell(), count: cols),
            count: rows
        )
    }

    func reveal(row: Int, col: Int) {
        guard status == .ready || status == .playing else { return }
        guard inBounds(row, col) else { return }
        guard grid[row][col].state == .hidden else { return }

        if !minesPlaced {
            placeMines(excluding: (row, col))
            minesPlaced = true
            status = .playing
            startTimer()
        }

        if grid[row][col].isMine {
            grid[row][col].state = .revealed
            grid[row][col].explodedHere = true
            status = .lost
            stopTimer()
            revealAllMines()
            return
        }

        floodReveal(row: row, col: col)
        checkWin()
    }

    func toggleFlag(row: Int, col: Int) {
        guard status == .playing || status == .ready else { return }
        guard inBounds(row, col) else { return }
        switch grid[row][col].state {
        case .hidden:
            grid[row][col].state = .flagged
            flagCount += 1
        case .flagged:
            grid[row][col].state = .hidden
            flagCount -= 1
        case .revealed:
            break
        }
    }

    func chord(row: Int, col: Int) {
        guard status == .playing else { return }
        guard inBounds(row, col) else { return }
        let cell = grid[row][col]
        guard cell.state == .revealed, cell.adjacentMines > 0 else { return }

        var flags = 0
        var hidden: [(Int, Int)] = []
        forEachNeighbor(row: row, col: col) { r, c in
            switch grid[r][c].state {
            case .flagged: flags += 1
            case .hidden: hidden.append((r, c))
            case .revealed: break
            }
        }
        guard flags == cell.adjacentMines else { return }
        for (r, c) in hidden {
            reveal(row: r, col: c)
            if status == .lost { return }
        }
    }

    private func inBounds(_ r: Int, _ c: Int) -> Bool {
        r >= 0 && r < rows && c >= 0 && c < cols
    }

    private func placeMines(excluding safe: (Int, Int)) {
        var positions: [(Int, Int)] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if abs(r - safe.0) <= 1 && abs(c - safe.1) <= 1 { continue }
                positions.append((r, c))
            }
        }
        positions.shuffle()
        for i in 0..<min(mineCount, positions.count) {
            let (r, c) = positions[i]
            grid[r][c].isMine = true
        }
        for r in 0..<rows {
            for c in 0..<cols {
                grid[r][c].adjacentMines = countAdjacentMines(row: r, col: c)
            }
        }
    }

    private func countAdjacentMines(row: Int, col: Int) -> Int {
        var count = 0
        forEachNeighbor(row: row, col: col) { r, c in
            if grid[r][c].isMine { count += 1 }
        }
        return count
    }

    private func forEachNeighbor(row: Int, col: Int, _ body: (Int, Int) -> Void) {
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let r = row + dr
                let c = col + dc
                if inBounds(r, c) { body(r, c) }
            }
        }
    }

    private func floodReveal(row: Int, col: Int) {
        var stack: [(Int, Int)] = [(row, col)]
        while let (r, c) = stack.popLast() {
            guard inBounds(r, c) else { continue }
            guard grid[r][c].state == .hidden else { continue }
            guard !grid[r][c].isMine else { continue }
            grid[r][c].state = .revealed
            if grid[r][c].adjacentMines == 0 {
                forEachNeighbor(row: r, col: c) { nr, nc in
                    if grid[nr][nc].state == .hidden && !grid[nr][nc].isMine {
                        stack.append((nr, nc))
                    }
                }
            }
        }
    }

    private func revealAllMines() {
        for r in 0..<rows {
            for c in 0..<cols where grid[r][c].isMine {
                grid[r][c].state = .revealed
            }
        }
    }

    private func checkWin() {
        for r in 0..<rows {
            for c in 0..<cols {
                if !grid[r][c].isMine && grid[r][c].state != .revealed {
                    return
                }
            }
        }
        status = .won
        stopTimer()
        for r in 0..<rows {
            for c in 0..<cols where grid[r][c].isMine && grid[r][c].state == .hidden {
                grid[r][c].state = .flagged
            }
        }
        flagCount = mineCount
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self, self.status == .playing else { return }
                if self.elapsedSeconds < 999 {
                    self.elapsedSeconds += 1
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
