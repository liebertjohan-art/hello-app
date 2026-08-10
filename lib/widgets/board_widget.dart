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
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
