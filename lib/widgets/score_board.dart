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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151928),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreTile(
            context,
            label: playerXLabel,
            score: scores[Player.x] ?? 0,
            color: const Color(0xFF00F2FE),
            icon: Icons.close_rounded,
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildScoreTile(
            context,
            label: 'Draws',
            score: draws,
            color: const Color(0xFFFFD700),
            icon: Icons.remove_rounded,
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildScoreTile(
            context,
            label: playerOLabel,
            score: scores[Player.o] ?? 0,
            color: const Color(0xFFFF007A),
            icon: Icons.radio_button_unchecked_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTile(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Text(
            '$score',
            key: ValueKey<int>(score),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
