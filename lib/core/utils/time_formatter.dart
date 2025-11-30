class TimeFormatter {
  static String formatDuration(Duration duration) {
    // Округляем дни вверх: если есть остаток времени, добавляем 1 день
    final days = duration.inDays + (duration > Duration(days: duration.inDays) ? 1 : 0);

    return '$daysд';
  }
}
