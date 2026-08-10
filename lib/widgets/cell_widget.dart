import 'package:flutter/material.dart';
import '../models/game_state.dart';

class CellWidget extends StatefulWidget {
  final Player player;
  final bool isWinningCell;
  final VoidCallback onTap;
  final bool enabled;
  final int index;

  const CellWidget({
    super.key,
    required this.player,
    required this.isWinningCell,
    required this.onTap,
    required this.enabled,
    required this.index,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    if (widget.player != Player.none) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player == Player.none && widget.player != Player.none) {
      _controller.forward(from: 0);
    } else if (widget.player == Player.none &&
        oldWidget.player != Player.none) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canTap = widget.enabled && widget.player == Player.none;
    final theme = Theme.of(context);

    final Border border = Border(
      right: (widget.index % 3 != 2)
          ? BorderSide(color: theme.dividerColor.withOpacity(0.3), width: 1.5)
          : BorderSide.none,
      bottom: (widget.index < 6)
          ? BorderSide(color: theme.dividerColor.withOpacity(0.3), width: 1.5)
          : BorderSide.none,
    );

    final Color backgroundColor = widget.isWinningCell
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.colorScheme.surface;

    return GestureDetector(
      onTap: canTap ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canTap ? widget.onTap : null,
            splashColor: theme.colorScheme.primary.withOpacity(0.1),
            highlightColor: theme.colorScheme.primary.withOpacity(0.05),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox.expand(
                  child: _buildSymbol(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    switch (widget.player) {
      case Player.x:
        return const CustomPaint(
          painter: _XPainter(
            color: Colors.deepPurple,
            strokeWidth: 6.0,
          ),
        );
      case Player.o:
        return const CustomPaint(
          painter: _OPainter(
            color: Colors.teal,
            strokeWidth: 6.0,
          ),
        );
      case Player.none:
        return const SizedBox.shrink();
    }
  }
}

class _XPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _XPainter({
    required this.color,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final padding = size.width * 0.20;

    canvas.drawLine(
      Offset(padding, padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(padding, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _XPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

class _OPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _OPainter({
    required this.color,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _OPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
