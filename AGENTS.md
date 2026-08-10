# AGENTS.md

## Project Overview
- Flutter Tic Tac Toe game (2-player + vs AI modes)
- Package name: `com.example.hello_app`
- Dart SDK: ^3.12.2

## CRITICAL RULES
1. **NEVER run `flutter` commands locally** — no `flutter run`, `flutter build`, `flutter test`, `flutter analyze`, `flutter pub get`, etc. This is a proot/Termux environment on a phone — running Flutter locally will crash the device.
2. **NEVER run `dart` commands locally** — no `dart analyze`, `dart test`, etc.
3. **Build process is 100% cloud-based** via GitHub Actions CI/CD.
4. **Only `adb` is available locally** for installing APKs on the device.
5. **Only `git` and `gh` CLI are available** for pushing code and managing releases.

## Build & Deploy Workflow
1. Write/edit code in `lib/` directory
2. `git add . && git commit -m "message" && git push origin main`
3. GitHub Actions auto-triggers build (`.github/workflows/build-release.yml`)
4. Watch build: `gh run watch <run_id> --exit-status`
5. Download APK: `gh release download --dir downloads/ --clobber --pattern '*.apk'`
6. Install: `adb install -r downloads/app-release.apk`

## Project Structure
```
lib/
├── main.dart              # App entry, theme, routing
├── ai/minimax.dart        # Unbeatable AI (minimax + alpha-beta)
├── models/game_state.dart # Game logic, board, win detection
├── screens/
│   ├── home_screen.dart   # Mode selection
│   └── game_screen.dart   # Gameplay
└── widgets/
    ├── board_widget.dart   # 3x3 grid
    ├── cell_widget.dart    # Animated X/O cells
    └── score_board.dart    # Score display
```

## Code Verification
- Since we can't run flutter/dart locally, verify code by:
  - Reading the code carefully for syntax errors
  - Checking cross-file imports and type consistency
  - Ensuring enum values match across files
  - Push and let CI catch any build errors

## Dependencies
- Only `flutter` SDK and `cupertino_icons` — no third-party packages
- No additional dependencies needed
