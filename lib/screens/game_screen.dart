import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../ai/minimax.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({
    super.key,
    required this.mode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _gameState;
  late final MinimaxAI _ai;
  bool _isAIThinking = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _ai = MinimaxAI();
  }

  void _handleTap(int index) async {
    if (_gameState.result != GameResult.ongoing || _isAIThinking) {
      return;
    }

    setState(() {
      _gameState.makeMove(index);
    });

    if (widget.mode == GameMode.vsAI &&
        _gameState.result == GameResult.ongoing) {
      setState(() {
        _isAIThinking = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final bestMove = _ai.getBestMove(_gameState.board);
      setState(() {
        _gameState.makeMove(bestMove);
        _isAIThinking = false;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _isAIThinking = false;
      _gameState.reset();
    });
  }

  void _newGame() {
    setState(() {
      _isAIThinking = false;
      _gameState.resetScores();
    });
  }

  String _getStatusText() {
    switch (_gameState.result) {
      case GameResult.xWins:
        return 'X Wins!';
      case GameResult.oWins:
        return 'O Wins!';
      case GameResult.draw:
        return "It's a Draw!";
      case GameResult.ongoing:
        return _gameState.currentPlayer == Player.x ? "X's Turn" : "O's Turn";
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (_gameState.result) {
      case GameResult.xWins:
        return Colors.deepPurple;
      case GameResult.oWins:
        return Colors.teal;
      case GameResult.draw:
        return Colors.grey;
      case GameResult.ongoing:
        return _gameState.currentPlayer == Player.x
            ? Colors.deepPurple
            : Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor(context);
    final isGameOver = _gameState.result != GameResult.ongoing;
    final modeName = widget.mode == GameMode.vsAI ? 'vs AI' : '2 Players';

    return Scaffold(
      appBar: AppBar(
        title: Text(modeName),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Status banner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  statusText,
                  key: ValueKey<String>(statusText),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              // 2. BoardWidget
              BoardWidget(
                board: _gameState.board,
                winningCells: _gameState.winningCells,
                onTap: _handleTap,
                enabled: !isGameOver && !_isAIThinking,
              ),

              // 3. ScoreBoard
              ScoreBoard(
                scores: _gameState.scores,
                draws: _gameState.draws,
                playerXLabel:
                    widget.mode == GameMode.vsAI ? 'You' : 'Player X',
                playerOLabel: widget.mode == GameMode.vsAI ? 'AI' : 'Player O',
              ),

              // 4. Action buttons row
              if (isGameOver)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _resetGame,
                      child: const Text('Reset Round'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _newGame,
                      child: const Text('New Game'),
                    ),
                  ],
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
