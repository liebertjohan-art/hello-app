import 'dart:math';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';

class MinimaxAI {
  final Player aiPlayer = Player.o;
  final Player humanPlayer = Player.x;
  final Random _random = Random();

  int getMove(List<Player> board, AIDifficulty difficulty) {
    final available = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        available.add(i);
      }
    }

    if (available.isEmpty) return -1;

    switch (difficulty) {
      case AIDifficulty.easy:
        // 70% chance random move, 30% best move
        if (_random.nextDouble() < 0.7) {
          return available[_random.nextInt(available.length)];
        }
        return getBestMove(board);

      case AIDifficulty.medium:
        // 40% chance random move, 60% best move
        if (_random.nextDouble() < 0.4) {
          return available[_random.nextInt(available.length)];
        }
        return getBestMove(board);

      case AIDifficulty.hard:
        // 100% best move
        return getBestMove(board);
    }
  }

  int getBestMove(List<Player> board) {
    final availableMoves = <int>[];
    if (board[4] == Player.none) {
      availableMoves.add(4);
    }
    for (int i = 0; i < board.length; i++) {
      if (i != 4 && board[i] == Player.none) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) {
      return -1;
    }

    int bestMove = availableMoves.first;
    int bestScore = -1000;
    int alpha = -1000;
    int beta = 1000;

    for (final move in availableMoves) {
      board[move] = aiPlayer;
      final score = _minimax(board, false, 0, alpha, beta);
      board[move] = Player.none;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
      if (bestScore > alpha) {
        alpha = bestScore;
      }
    }

    return bestMove;
  }

  int _minimax(
      List<Player> board, bool isMaximizing, int depth, int alpha, int beta) {
    final winner = _checkWinner(board);
    if (winner == aiPlayer) {
      return 10 - depth;
    }
    if (winner == humanPlayer) {
      return depth - 10;
    }
    if (_isBoardFull(board)) {
      return 0;
    }

    if (isMaximizing) {
      int maxScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == Player.none) {
          board[i] = aiPlayer;
          final score = _minimax(board, false, depth + 1, alpha, beta);
          board[i] = Player.none;
          if (score > maxScore) {
            maxScore = score;
          }
          if (maxScore > alpha) {
            alpha = maxScore;
          }
          if (beta <= alpha) {
            break;
          }
        }
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == Player.none) {
          board[i] = humanPlayer;
          final score = _minimax(board, true, depth + 1, alpha, beta);
          board[i] = Player.none;
          if (score < minScore) {
            minScore = score;
          }
          if (minScore < beta) {
            beta = minScore;
          }
          if (beta <= alpha) {
            break;
          }
        }
      }
      return minScore;
    }
  }

  Player? _checkWinner(List<Player> board) {
    const winLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final line in winLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];

      if (a != Player.none && a == b && a == c) {
        return a;
      }
    }

    return null;
  }

  bool _isBoardFull(List<Player> board) {
    return !board.contains(Player.none);
  }
}
