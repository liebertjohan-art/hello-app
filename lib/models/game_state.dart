import 'package:flutter/foundation.dart';

enum Player { x, o, none }

enum GameMode { twoPlayer, vsAI }

enum GameResult { xWins, oWins, draw, ongoing }

class GameState extends ChangeNotifier {
  List<Player> board = List<Player>.filled(9, Player.none);
  Player currentPlayer = Player.x;
  GameResult result = GameResult.ongoing;
  Map<Player, int> scores = {Player.x: 0, Player.o: 0};
  int draws = 0;
  List<int> winningCells = [];

  static const List<List<int>> winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],            // diagonals
  ];

  bool makeMove(int index) {
    if (index < 0 || index >= board.length) return false;
    if (board[index] != Player.none || result != GameResult.ongoing) {
      return false;
    }

    board[index] = currentPlayer;
    _checkResult();
    currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
    notifyListeners();
    return true;
  }

  void _checkResult() {
    for (final line in winLines) {
      final a = line[0];
      final b = line[1];
      final c = line[2];

      if (board[a] != Player.none &&
          board[a] == board[b] &&
          board[b] == board[c]) {
        winningCells = List<int>.from(line);
        if (board[a] == Player.x) {
          result = GameResult.xWins;
          scores[Player.x] = (scores[Player.x] ?? 0) + 1;
        } else if (board[a] == Player.o) {
          result = GameResult.oWins;
          scores[Player.o] = (scores[Player.o] ?? 0) + 1;
        }
        return;
      }
    }

    if (!board.contains(Player.none)) {
      result = GameResult.draw;
      draws++;
    }
  }

  void reset() {
    board = List<Player>.filled(9, Player.none);
    result = GameResult.ongoing;
    winningCells = [];
    currentPlayer = Player.x;
    notifyListeners();
  }

  void resetScores() {
    scores = {Player.x: 0, Player.o: 0};
    draws = 0;
    reset();
  }

  List<int> get availableMoves {
    final moves = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        moves.add(i);
      }
    }
    return moves;
  }
}
