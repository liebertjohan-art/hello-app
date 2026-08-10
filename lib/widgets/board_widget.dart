import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final List<Player> board;
  final List<int> winningCells;
  final void Function(int) onTap;
  final bool enabled;

  const BoardWidget({
    super.key,
    required this.board,
    required this.winningCells,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151928),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFFF007A).withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return CellWidget(
              player: board[index],
              isWinningCell: winningCells.contains(index),
              onTap: () => onTap(index),
              enabled: enabled,
              index: index,
            );
          },
        ),
      ),
    );
  }
}
