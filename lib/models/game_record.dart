import 'game_state.dart';
import 'ai_difficulty.dart';

class GameRecord {
  final String id;
  final DateTime dateTime;
  final GameMode mode;
  final AIDifficulty? difficulty;
  final GameResult result;
  final String winnerLabel;
  final int movesCount;

  GameRecord({
    required this.id,
    required this.dateTime,
    required this.mode,
    this.difficulty,
    required this.result,
    required this.winnerLabel,
    required this.movesCount,
  });

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthName(dateTime.month);
    return '$day $month';
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
