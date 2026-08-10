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
          color: const Color(0xFF0A0C10),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 40,
              spreadRadius: 10,
              offset: const Offset(0, 20),
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
