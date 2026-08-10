import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ScoreBoard extends StatelessWidget {
  final Map<Player, int> scores;
  final int draws;
  final String playerXLabel;
  final String playerOLabel;

  const ScoreBoard({
    super.key,
    required this.scores,
    required this.draws,
    required this.playerXLabel,
    required this.playerOLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreColumn(
              context,
              label: playerXLabel,
              score: scores[Player.x] ?? 0,
              color: Colors.deepPurple,
            ),
            _buildScoreColumn(
              context,
              label: 'Draws',
              score: draws,
              color: Colors.grey,
            ),
            _buildScoreColumn(
              context,
              label: playerOLabel,
              score: scores[Player.o] ?? 0,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreColumn(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$score',
            key: ValueKey<int>(score),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
