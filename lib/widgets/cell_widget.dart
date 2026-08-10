import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_state.dart';

class CellWidget extends StatefulWidget {
  final Player player;
  final bool isWinningCell;
  final void Function() onTap;
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
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Scale from 0.6 instead of 0.0 for physical realism
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
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
          ? BorderSide(color: Colors.white.withOpacity(0.04), width: 1.5)
          : BorderSide.none,
      bottom: (widget.index < 6)
          ? BorderSide(color: Colors.white.withOpacity(0.04), width: 1.5)
          : BorderSide.none,
    );

    final Color highlightColor = widget.player == Player.x
        ? const Color(0xFF00F2FE)
        : const Color(0xFFFF007A);

    return GestureDetector(
      onTap: canTap ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isWinningCell
              ? highlightColor.withOpacity(0.15)
              : Colors.transparent,
          border: border,
          boxShadow: widget.isWinningCell ? [
            BoxShadow(
              color: highlightColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canTap ? widget.onTap : null,
                splashColor: const Color(0xFF00F2FE).withOpacity(0.1),
                highlightColor: const Color(0xFFFF007A).withOpacity(0.05),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox.expand(
                      child: _buildSymbol(),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final strokeWidth = size.width * 0.08;
    final padding = size.width * 0.25;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth * 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(padding, padding);
    final p2 = Offset(size.width - padding, size.height - padding);
    final p3 = Offset(size.width - padding, padding);
    final p4 = Offset(padding, size.height - padding);

    canvas.drawLine(p1, p2, glowPaint);
    canvas.drawLine(p3, p4, glowPaint);
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
    final strokeWidth = size.width * 0.08;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth * 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final mainPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, mainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
