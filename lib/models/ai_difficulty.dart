import 'package:flutter/material.dart';

enum AIDifficulty {
  easy,
  medium,
  hard,
}

extension AIDifficultyExtension on AIDifficulty {
  String get label {
    switch (this) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.medium:
        return 'Medium';
      case AIDifficulty.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case AIDifficulty.easy:
        return 'Casual & playful moves';
      case AIDifficulty.medium:
        return 'Balanced tactical bot';
      case AIDifficulty.hard:
        return 'Unbeatable Master AI';
    }
  }

  IconData get icon {
    switch (this) {
      case AIDifficulty.easy:
        return Icons.bolt_outlined;
      case AIDifficulty.medium:
        return Icons.local_fire_department_outlined;
      case AIDifficulty.hard:
        return Icons.psychology_outlined;
    }
  }

  Color get color {
    switch (this) {
      case AIDifficulty.easy:
        return const Color(0xFF00F2FE); // Cyan
      case AIDifficulty.medium:
        return const Color(0xFFFFD700); // Gold
      case AIDifficulty.hard:
        return const Color(0xFFFF007A); // Hot Pink
    }
  }
}
