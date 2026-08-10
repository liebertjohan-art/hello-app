import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final bool animate;

  const ConfettiWidget({
    super.key,
    required this.animate,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
        setState(() {});
      });

    if (widget.animate) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const colors = [
      Color(0xFF00F2FE), // Cyan
      Color(0xFFFF007A), // Hot Pink
      Color(0xFFFFD700), // Gold
      Color(0xFF7000FF), // Violet
      Color(0xFF00FF88), // Spring Green
    ];

    for (int i = 0; i < 50; i++) {
      _particles.add(
        _ConfettiParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.4,
          y: 0.4 + (_random.nextDouble() - 0.5) * 0.2,
          vx: (_random.nextDouble() - 0.5) * 1.2,
          vy: -(_random.nextDouble() * 1.5 + 0.8),
          size: _random.nextDouble() * 8 + 6,
          color: colors[_random.nextInt(colors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          shape: _random.nextBool() ? _ParticleShape.circle : _ParticleShape.square,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating && _controller.value == 1.0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
        ),
      ),
    );
  }
}

enum _ParticleShape { circle, square }

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  _ParticleShape shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final gravity = 2.5 * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final currentX = size.width * (p.x + p.vx * progress);
      final currentY = size.height * (p.y + p.vy * progress + 0.5 * gravity * progress);
      final currentRotation = p.rotation + p.rotationSpeed * progress;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      if (p.shape == _ParticleShape.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
