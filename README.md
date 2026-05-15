# Minesweeper for iOS

A SwiftUI clone of the classic Windows Minesweeper, built for iPhone and iPad.

## Features

- Three difficulties: Beginner (9×9, 10 mines), Intermediate (16×16, 40 mines), Expert (16×30, 99 mines)
- Classic 7-segment-style mine counter and timer
- Smiley reset button that reacts to game state
- Tap to reveal, long-press to flag, tap a revealed number to "chord" (auto-reveal neighbors when the right number of flags are placed)
- First click is always safe — the opening always reveals at zero region around the tapped cell
- Haptic feedback on tap and flag
- Works in portrait and landscape on iPhone and iPad

## Build & Run

Requirements: Xcode 15 or later, iOS 17 deployment target.

1. Open `Minesweeper.xcodeproj` in Xcode.
2. Select the **Minesweeper** scheme and an iPhone or iPad simulator (or your device).
3. Press ⌘R to build and run.

## How to play

- **Tap** an empty square to reveal it.
- **Long-press** a square to plant or remove a flag.
- **Tap a number** that has the matching count of flags around it to reveal the rest of its neighbors at once.
- Clear every non-mine square to win.

## Project layout

```
Minesweeper/
  MinesweeperApp.swift   App entry point
  ContentView.swift      Root navigation, difficulty menu, win/lose alert
  GameModel.swift        Game state, mine placement, flood reveal, chording
  GameBoard.swift        Grid layout and gesture handling
  CellView.swift         Single cell rendering (numbers, flags, mines)
  StatusBar.swift        Mine counter, smiley reset, timer
  Assets.xcassets/       App icon and accent color
```
