import 'dart:ui';
import 'package:flutter/material.dart';

class CreditsSheetWidget extends StatelessWidget {
  const CreditsSheetWidget({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const CreditsSheetWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF050505).withOpacity(0.75),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.1),
                    blurRadius: 40,
                  )
                ]
              ),
              child: const Icon(
                Icons.code_rounded,
                size: 48,
                color: Color(0xFF00F2FE),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MADE WITH LOVE BY AKASH',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'CYBERTAE // SYS.VER.2.0\nENGINEERED FOR EXCELLENCE',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                letterSpacing: 3.0,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
