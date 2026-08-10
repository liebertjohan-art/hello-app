import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/ai_difficulty.dart';
import '../ai/minimax.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/history_sheet_widget.dart';
import '../widgets/tactile_button.dart';

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

  void _nextRound() {
    setState(() {
      _isAIThinking = false;
      _showConfetti = false;
      _gameState.reset();
    });
  }

  void _resetScores() {
    setState(() {
      _isAIThinking = false;
      _showConfetti = false;
      _gameState.resetScores();
    });
  }

  String _getStatusText() {
    switch (_gameState.result) {
      case GameResult.xWins:
        return widget.mode == GameMode.vsAI ? 'YOU WON THE MATCH' : 'PLAYER X SECURED VICTORY';
      case GameResult.oWins:
        return widget.mode == GameMode.vsAI ? 'AI OVERRIDE SUCCESSFUL' : 'PLAYER O SECURED VICTORY';
      case GameResult.draw:
        return 'STALEMATE DETECTED';
      case GameResult.ongoing:
        if (_isAIThinking) {
          return 'NEURAL NET CALCULATING...';
        }
        return _gameState.currentPlayer == Player.x
            ? (widget.mode == GameMode.vsAI ? "AWAITING YOUR INPUT" : "AWAITING PLAYER X")
            : (widget.mode == GameMode.vsAI ? "AWAITING AI INPUT" : "AWAITING PLAYER O");
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

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  _buildCustomTopBar(),
                  const SizedBox(height: 32),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5), 
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey<String>(statusText),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isAIThinking && _gameState.result == GameResult.ongoing)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: 12, 
                              height: 12, 
                              child: CircularProgressIndicator(
                                strokeWidth: 2, 
                                color: statusColor,
                              ),
                            ),
                          ),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  
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
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TactileButton(
                          onTap: _resetScores,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A0C10),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restart_alt_rounded, size: 16, color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'RESET SCORES',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TactileButton(
                          onTap: _nextRound,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F2FE).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F2FE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fast_forward_rounded, size: 16, color: Color(0xFF00F2FE)),
                                  SizedBox(width: 8),
                                  Text(
                                    'NEXT ROUND',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: Color(0xFF00F2FE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          Positioned.fill(
            child: ConfettiWidget(animate: _showConfetti),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TactileButton(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mode == GameMode.vsAI ? 'NEURAL NET' : 'LOCAL PVP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                if (widget.mode == GameMode.vsAI)
                  Text(
                    'THREAT: ${_gameState.aiDifficulty.label.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: _gameState.aiDifficulty.color,
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    'TWO-PLAYER DIRECT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF8E9AAF),
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
        TactileButton(
          onTap: () => HistorySheetWidget.show(context, _gameState),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white70, size: 18),
          ),
        ),
      ],
    );
  }
}
