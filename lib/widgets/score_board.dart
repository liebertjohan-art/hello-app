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
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _buildBentoScore(
            context,
            label: playerXLabel,
            score: scores[Player.x] ?? 0,
            color: const Color(0xFF00F2FE),
            icon: Icons.close_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: _buildBentoScore(
            context,
            label: 'DRAWS',
            score: draws,
            color: const Color(0xFFFFD700),
            icon: Icons.remove_rounded,
            isSlim: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _buildBentoScore(
            context,
            label: playerOLabel,
            score: scores[Player.o] ?? 0,
            color: const Color(0xFFFF007A),
            icon: Icons.radio_button_unchecked_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoScore(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required IconData icon,
    bool isSlim = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isSlim ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSlim ? 6 : 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return ClipRect(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5), 
                    end: Offset.zero
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Text(
              '$score',
              key: ValueKey<int>(score),
              style: TextStyle(
                fontSize: isSlim ? 24 : 32,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
