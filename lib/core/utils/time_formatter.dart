class TimeFormatter {
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$daysд');
    if (hours > 0) parts.add('$hoursч');
    if (minutes > 0 || parts.isEmpty) parts.add('$minutesм');

    return parts.join(' ');
  }
}

