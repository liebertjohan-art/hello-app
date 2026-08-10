import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_record.dart';
import '../models/ai_difficulty.dart';

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
      backgroundColor: const Color(0xFF151928),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => HistorySheetWidget(gameState: gameState),
    );
  }

  @override
  State<HistorySheetWidget> createState() => _HistorySheetWidgetState();
}

class _HistorySheetWidgetState extends State<HistorySheetWidget> {
  int _selectedFilterIndex = 0; // 0: All, 1: vs AI, 2: 2 Players

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
    final theme = Theme.of(context);
    final history = _filteredHistory;
    final total = widget.gameState.totalGames;
    final xWins = widget.gameState.xWinCount;
    final oWins = widget.gameState.oWinCount;
    final draws = widget.gameState.drawCount;

    final double winRate = total > 0 ? ((xWins / total) * 100) : 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Sheet Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Clear Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F2FE).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Color(0xFF00F2FE),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Game History',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (widget.gameState.gameHistory.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFF8E9AAF)),
                      tooltip: 'Clear History',
                      onPressed: () => _confirmClear(context),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats summary card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E17),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill('Matches', '$total', Colors.white),
                    _buildStatPill('X Wins', '$xWins', const Color(0xFF00F2FE)),
                    _buildStatPill('O Wins', '$oWins', const Color(0xFFFF007A)),
                    _buildStatPill('Draws', '$draws', const Color(0xFFFFD700)),
                    _buildStatPill('Win Rate', '${winRate.toStringAsFixed(0)}%', const Color(0xFF7000FF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Tabs Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildFilterChip(0, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, 'vs AI'),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, '2 Players'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // History List or Empty state
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_esports_outlined,
                            size: 56,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matches recorded yet!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Play a match to see your game history here.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final record = history[index];
                        return _buildRecordCard(context, record);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9AAF),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00F2FE).withOpacity(0.2)
              : const Color(0xFF0B0E17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00F2FE)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00F2FE) : const Color(0xFF8E9AAF),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, GameRecord record) {
    Color resultColor;
    String resultText;
    IconData resultIcon;

    if (record.result == GameResult.xWins) {
      resultColor = const Color(0xFF00F2FE);
      resultText = '${record.winnerLabel} Won';
      resultIcon = Icons.emoji_events_rounded;
    } else if (record.result == GameResult.oWins) {
      resultColor = const Color(0xFFFF007A);
      resultText = '${record.winnerLabel} Won';
      resultIcon = Icons.emoji_events_rounded;
    } else {
      resultColor = const Color(0xFFFFD700);
      resultText = 'Draw';
      resultIcon = Icons.handshake_outlined;
    }

    final modeBadgeText = record.mode == GameMode.vsAI ? 'vs AI' : '2 Players';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resultColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(resultIcon, color: resultColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      resultText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        modeBadgeText,
                        style: const TextStyle(
                          color: Color(0xFF8E9AAF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (record.difficulty != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.difficulty!.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.difficulty!.label,
                          style: TextStyle(
                            color: record.difficulty!.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.movesCount} moves • ${record.formattedDate} at ${record.formattedTime}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
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
        backgroundColor: const Color(0xFF151928),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all saved match records and statistics.',
          style: TextStyle(color: Color(0xFF8E9AAF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E9AAF))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF007A),
            ),
            onPressed: () {
              widget.gameState.clearHistory();
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
