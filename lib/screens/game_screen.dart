import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';
import '../ai/minimax.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/heart_footer_widget.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/history_sheet_widget.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final GameState? gameState;

  const GameScreen({
    super.key,
    required this.mode,
    this.gameState,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _gameState;
  late final MinimaxAI _ai;
  bool _isAIThinking = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState ?? GameState();
    _ai = MinimaxAI();
    _gameState.reset();
  }

  void _handleTap(int index) async {
    if (_gameState.result != GameResult.ongoing || _isAIThinking) {
      return;
    }

    final bool moved = _gameState.makeMove(index, mode: widget.mode);
    if (!moved) return;

    _checkGameEndState();

    if (widget.mode == GameMode.vsAI &&
        _gameState.result == GameResult.ongoing &&
        _gameState.currentPlayer == Player.o) {
      setState(() {
        _isAIThinking = true;
      });

      await Future.delayed(const Duration(milliseconds: 450));

      if (!mounted) return;

      final aiMove = _ai.getMove(_gameState.board, _gameState.aiDifficulty);
      if (aiMove != -1) {
        _gameState.makeMove(aiMove, mode: widget.mode);
      }

      setState(() {
        _isAIThinking = false;
      });

      _checkGameEndState();
    }
  }

  void _checkGameEndState() {
    if (_gameState.result == GameResult.xWins || _gameState.result == GameResult.oWins) {
      setState(() {
        _showConfetti = true;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _isAIThinking = false;
      _showConfetti = false;
      _gameState.reset();
    });
  }

  void _newGame() {
    setState(() {
      _isAIThinking = false;
      _showConfetti = false;
      _gameState.resetScores();
    });
  }

  String _getStatusText() {
    switch (_gameState.result) {
      case GameResult.xWins:
        return widget.mode == GameMode.vsAI ? '🎉 You Win!' : '🎉 Player X Wins!';
      case GameResult.oWins:
        return widget.mode == GameMode.vsAI ? '🤖 AI Bot Wins!' : '🎉 Player O Wins!';
      case GameResult.draw:
        return "🤝 It's a Draw!";
      case GameResult.ongoing:
        if (_isAIThinking) {
          return '🤖 AI is thinking...';
        }
        return _gameState.currentPlayer == Player.x
            ? (widget.mode == GameMode.vsAI ? "Your Turn (X)" : "Player X's Turn")
            : (widget.mode == GameMode.vsAI ? "AI's Turn (O)" : "Player O's Turn");
    }
  }

  Color _getStatusColor() {
    switch (_gameState.result) {
      case GameResult.xWins:
        return const Color(0xFF00F2FE);
      case GameResult.oWins:
        return const Color(0xFFFF007A);
      case GameResult.draw:
        return const Color(0xFFFFD700);
      case GameResult.ongoing:
        return _gameState.currentPlayer == Player.x
            ? const Color(0xFF00F2FE)
            : const Color(0xFFFF007A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor();
    final isGameOver = _gameState.result != GameResult.ongoing;
    final modeName = widget.mode == GameMode.vsAI ? 'vs AI Bot' : '2 Players';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              modeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (widget.mode == GameMode.vsAI) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gameState.aiDifficulty.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _gameState.aiDifficulty.color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _gameState.aiDifficulty.label,
                  style: TextStyle(
                    color: _gameState.aiDifficulty.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFFFFD700)),
            tooltip: 'Game History',
            onPressed: () {
              HistorySheetWidget.show(context, _gameState);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151928),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.12),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        statusText,
                        key: ValueKey<String>(statusText),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // 2. Board Widget
                  ListenableBuilder(
                    listenable: _gameState,
                    builder: (context, _) {
                      return BoardWidget(
                        board: _gameState.board,
                        winningCells: _gameState.winningCells,
                        onTap: _handleTap,
                        enabled: !isGameOver && !_isAIThinking,
                      );
                    },
                  ),
                  const Spacer(),

                  // 3. ScoreBoard
                  ListenableBuilder(
                    listenable: _gameState,
                    builder: (context, _) {
                      return ScoreBoard(
                        scores: _gameState.scores,
                        draws: _gameState.draws,
                        playerXLabel: widget.mode == GameMode.vsAI ? 'You (X)' : 'Player X',
                        playerOLabel: widget.mode == GameMode.vsAI ? 'AI (O)' : 'Player O',
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF151928),
                          ),
                          onPressed: _resetGame,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reset Round', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00F2FE),
                            foregroundColor: const Color(0xFF0B0E17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _newGame,
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('New Game', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Signature Footer
                  const HeartFooterWidget(),
                ],
              ),
            ),
          ),

          // Confetti explosion layer on victory
          Positioned.fill(
            child: ConfettiWidget(animate: _showConfetti),
          ),
        ],
      ),
    );
  }
}
