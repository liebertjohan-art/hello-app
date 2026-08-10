import 'package:flutter/material.dart';

class HeartFooterWidget extends StatefulWidget {
  const HeartFooterWidget({super.key});

  @override
  State<HeartFooterWidget> createState() => _HeartFooterWidgetState();
}

class _HeartFooterWidgetState extends State<HeartFooterWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _heartScale = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onTapHeart() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Color(0xFFFF007A), size: 18),
            SizedBox(width: 8),
            Text(
              'Crafted with passion by akashiverse 🚀',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF191E30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapHeart,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF151928).withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Made with ',
              style: TextStyle(
                color: Color(0xFF8E9AAF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            ScaleTransition(
              scale: _heartScale,
              child: const Text(
                '❤️',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const Text(
              ' by ',
              style: TextStyle(
                color: Color(0xFF8E9AAF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00F2FE), Color(0xFFFF007A)],
              ).createShader(bounds),
              child: const Text(
                'akashiverse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
