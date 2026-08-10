import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_record.dart';
import '../models/ai_difficulty.dart';
import 'tactile_button.dart';

class HistorySheetWidget extends StatefulWidget {
  final GameState gameState;

  const HistorySheetWidget({
    super.key,
    required this.gameState,
  });

  static void show(BuildContext context, GameState gameState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => HistorySheetWidget(gameState: gameState),
    );
  }

  @override
  State<HistorySheetWidget> createState() => _HistorySheetWidgetState();
}

class _HistorySheetWidgetState extends State<HistorySheetWidget> {
  int _selectedFilterIndex = 0;

  List<GameRecord> get _filteredHistory {
    final history = widget.gameState.gameHistory;
    if (_selectedFilterIndex == 1) {
      return history.where((r) => r.mode == GameMode.vsAI).toList();
    } else if (_selectedFilterIndex == 2) {
      return history.where((r) => r.mode == GameMode.twoPlayer).toList();
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    final history = _filteredHistory;
    final total = widget.gameState.totalGames;
    final xWins = widget.gameState.xWinCount;
    final oWins = widget.gameState.oWinCount;
    final draws = widget.gameState.drawCount;

    final double winRate = total > 0 ? ((xWins / total) * 100) : 0;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF050505).withOpacity(0.75),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'COMBAT LOG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (widget.gameState.gameHistory.isNotEmpty)
                        TactileButton(
                          onTap: () => _confirmClear(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF007A).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFF007A).withOpacity(0.3)),
                            ),
                            child: const Text(
                              'PURGE',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFFFF007A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 70,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _buildStatPill('TOTAL MATCHES', '$total', Colors.white),
                      const SizedBox(width: 12),
                      _buildStatPill('X VICTORIES', '$xWins', const Color(0xFF00F2FE)),
                      const SizedBox(width: 12),
                      _buildStatPill('O VICTORIES', '$oWins', const Color(0xFFFF007A)),
                      const SizedBox(width: 12),
                      _buildStatPill('STALEMATES', '$draws', const Color(0xFFFFD700)),
                      const SizedBox(width: 12),
                      _buildStatPill('WIN RATE', '${winRate.toStringAsFixed(0)}%', const Color(0xFF00E676)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      _buildFilterChip(0, 'GLOBAL'),
                      const SizedBox(width: 8),
                      _buildFilterChip(1, 'NEURAL NET'),
                      const SizedBox(width: 8),
                      _buildFilterChip(2, 'LOCAL PVP'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.data_array_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'NO LOGS DETECTED',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 12,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(context, history[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              color: Colors.white.withOpacity(0.5),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return TactileButton(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, GameRecord record) {
    Color resultColor;
    String resultText;

    if (record.result == GameResult.xWins) {
      resultColor = const Color(0xFF00F2FE);
      resultText = 'X VICTORY';
    } else if (record.result == GameResult.oWins) {
      resultColor = const Color(0xFFFF007A);
      resultText = 'O VICTORY';
    } else {
      resultColor = const Color(0xFFFFD700);
      resultText = 'STALEMATE';
    }

    final modeBadgeText = record.mode == GameMode.vsAI ? 'NEURAL NET' : 'LOCAL PVP';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: resultColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: resultColor.withOpacity(0.5),
                  blurRadius: 8,
                )
              ]
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resultText,
                      style: TextStyle(
                        color: resultColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${record.formattedDate} // ${record.formattedTime}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        modeBadgeText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white70,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (record.difficulty != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: record.difficulty!.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.difficulty!.label.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: record.difficulty!.color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${record.movesCount} MOVES',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0A0C10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          'PURGE LOGS?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'This action is irreversible. All combat data will be permanently deleted.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TactileButton(
            onTap: () {
              widget.gameState.clearHistory();
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF007A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CONFIRM PURGE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
