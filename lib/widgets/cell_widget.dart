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
      duration: const Duration(milliseconds: 450),
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

    final Border border = Border(
      right: (widget.index % 3 != 2)
          ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
          : BorderSide.none,
      bottom: (widget.index < 6)
          ? BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5)
          : BorderSide.none,
    );

    final Color backgroundColor = widget.isWinningCell
        ? (widget.player == Player.x
            ? const Color(0xFF00F2FE).withOpacity(0.22)
            : const Color(0xFFFF007A).withOpacity(0.22))
        : const Color(0xFF151928);

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
            splashColor: const Color(0xFF00F2FE).withOpacity(0.15),
            highlightColor: const Color(0xFFFF007A).withOpacity(0.1),
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
          painter: _XNeonPainter(),
        );
      case Player.o:
        return const CustomPaint(
          painter: _ONeonPainter(),
        );
      case Player.none:
        return const SizedBox.shrink();
    }
  }
}

class _XNeonPainter extends CustomPainter {
  const _XNeonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF00F2FE);
    final strokeWidth = size.width * 0.09;
    final padding = size.width * 0.22;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth * 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(padding, padding);
    final p2 = Offset(size.width - padding, size.height - padding);
    final p3 = Offset(size.width - padding, padding);
    final p4 = Offset(padding, size.height - padding);

    // Draw glow pass
    canvas.drawLine(p1, p2, glowPaint);
    canvas.drawLine(p3, p4, glowPaint);

    // Draw crisp neon stroke pass
    canvas.drawLine(p1, p2, mainPaint);
    canvas.drawLine(p3, p4, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ONeonPainter extends CustomPainter {
  const _ONeonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFFF007A);
    final strokeWidth = size.width * 0.09;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.28;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth * 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw glow pass
    canvas.drawCircle(center, radius, glowPaint);

    // Draw crisp neon stroke pass
    canvas.drawCircle(center, radius, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
