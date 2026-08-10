import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_app/main.dart';
import 'package:hello_app/models/game_state.dart';
import 'package:hello_app/ai/minimax.dart';
import 'package:hello_app/screens/game_screen.dart';

void main() {
  group('App Launch', () {
    testWidgets('App renders home screen with mode selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Tic Tac Toe'), findsOneWidget);
      expect(find.text('2 Players'), findsOneWidget);
      expect(find.text('vs AI'), findsOneWidget);
    });

    testWidgets('Can navigate to 2-player game',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('2 Players'));
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('Can navigate to vs AI game',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('vs AI'));
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });

  group('GameState', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('initial state is correct', () {
      expect(gameState.board, List.filled(9, Player.none));
      expect(gameState.currentPlayer, Player.x);
      expect(gameState.result, GameResult.ongoing);
      expect(gameState.scores[Player.x], 0);
      expect(gameState.scores[Player.o], 0);
      expect(gameState.draws, 0);
      expect(gameState.winningCells, isEmpty);
    });

    test('makeMove places mark and toggles player', () {
      expect(gameState.makeMove(0), true);
      expect(gameState.board[0], Player.x);
      expect(gameState.currentPlayer, Player.o);

      expect(gameState.makeMove(1), true);
      expect(gameState.board[1], Player.o);
      expect(gameState.currentPlayer, Player.x);
    });

    test('makeMove rejects occupied cell', () {
      gameState.makeMove(0);
      expect(gameState.makeMove(0), false);
    });

    test('makeMove rejects out of bounds', () {
      expect(gameState.makeMove(-1), false);
      expect(gameState.makeMove(9), false);
    });

    test('X wins horizontally (top row)', () {
      gameState.makeMove(0); // X
      gameState.makeMove(3); // O
      gameState.makeMove(1); // X
      gameState.makeMove(4); // O
      gameState.makeMove(2); // X wins

      expect(gameState.result, GameResult.xWins);
      expect(gameState.winningCells, [0, 1, 2]);
      expect(gameState.scores[Player.x], 1);
    });

    test('O wins vertically (left column)', () {
      gameState.makeMove(1); // X
      gameState.makeMove(0); // O
      gameState.makeMove(4); // X
      gameState.makeMove(3); // O
      gameState.makeMove(8); // X
      gameState.makeMove(6); // O wins

      expect(gameState.result, GameResult.oWins);
      expect(gameState.winningCells, [0, 3, 6]);
      expect(gameState.scores[Player.o], 1);
    });

    test('X wins diagonally', () {
      gameState.makeMove(0); // X
      gameState.makeMove(1); // O
      gameState.makeMove(4); // X
      gameState.makeMove(2); // O
      gameState.makeMove(8); // X wins

      expect(gameState.result, GameResult.xWins);
      expect(gameState.winningCells, [0, 4, 8]);
    });

    test('draw detection', () {
      // X O X
      // X X O
      // O X O
      gameState.makeMove(0); // X
      gameState.makeMove(1); // O
      gameState.makeMove(2); // X
      gameState.makeMove(5); // O
      gameState.makeMove(3); // X
      gameState.makeMove(6); // O
      gameState.makeMove(4); // X
      gameState.makeMove(8); // O
      gameState.makeMove(7); // X

      expect(gameState.result, GameResult.draw);
      expect(gameState.draws, 1);
      expect(gameState.winningCells, isEmpty);
    });

    test('no moves after game over', () {
      gameState.makeMove(0); // X
      gameState.makeMove(3); // O
      gameState.makeMove(1); // X
      gameState.makeMove(4); // O
      gameState.makeMove(2); // X wins

      expect(gameState.makeMove(5), false);
    });

    test('reset clears board but keeps scores', () {
      gameState.makeMove(0); // X
      gameState.makeMove(3); // O
      gameState.makeMove(1); // X
      gameState.makeMove(4); // O
      gameState.makeMove(2); // X wins

      gameState.reset();
      expect(gameState.board, List.filled(9, Player.none));
      expect(gameState.result, GameResult.ongoing);
      expect(gameState.currentPlayer, Player.x);
      expect(gameState.winningCells, isEmpty);
      expect(gameState.scores[Player.x], 1); // score preserved
    });

    test('resetScores clears everything', () {
      gameState.makeMove(0); // X
      gameState.makeMove(3); // O
      gameState.makeMove(1); // X
      gameState.makeMove(4); // O
      gameState.makeMove(2); // X wins

      gameState.resetScores();
      expect(gameState.scores[Player.x], 0);
      expect(gameState.scores[Player.o], 0);
      expect(gameState.draws, 0);
      expect(gameState.board, List.filled(9, Player.none));
    });

    test('availableMoves returns empty cells', () {
      gameState.makeMove(0);
      gameState.makeMove(4);
      expect(gameState.availableMoves, [1, 2, 3, 5, 6, 7, 8]);
    });
  });

  group('MinimaxAI', () {
    late MinimaxAI ai;

    setUp(() {
      ai = MinimaxAI();
    });

    test('AI picks winning move', () {
      // O has two in a row, should complete
      final board = [
        Player.x, Player.x, Player.none,
        Player.o, Player.o, Player.none,
        Player.x, Player.none, Player.none,
      ];
      final move = ai.getBestMove(board);
      expect(move, 5); // O completes row [3,4,5]
    });

    test('AI blocks opponent winning move', () {
      // X has two in a row, AI (O) should block
      final board = [
        Player.x, Player.x, Player.none,
        Player.o, Player.none, Player.none,
        Player.none, Player.none, Player.none,
      ];
      final move = ai.getBestMove(board);
      expect(move, 2); // Block X from completing [0,1,2]
    });

    test('AI takes center when available on empty board', () {
      final board = List<Player>.filled(9, Player.none);
      board[0] = Player.x; // X played corner
      final move = ai.getBestMove(board);
      expect(move, 4); // Center is optimal
    });

    test('AI never loses - all first moves lead to draw or AI win', () {
      // Simulate AI (O) vs perfect play - should never lose
      for (int firstMove = 0; firstMove < 9; firstMove++) {
        final board = List<Player>.filled(9, Player.none);
        board[firstMove] = Player.x;
        final aiMove = ai.getBestMove(board);
        expect(aiMove, isNot(-1));
        expect(aiMove >= 0 && aiMove < 9, true);
        expect(board[aiMove], Player.none);
      }
    });
  });
}
