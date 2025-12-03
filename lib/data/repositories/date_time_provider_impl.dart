import 'package:timezone/timezone.dart' as tz;
import '../../domain/repositories/date_time_provider.dart';

/// Реализация DateTimeProvider с использованием библиотеки timezone
class DateTimeProviderImpl implements DateTimeProvider {
  static const String _moscowTimeZone = 'Europe/Moscow';

  @override
  DateTime getNowInMoscow() {
    final moscow = tz.getLocation(_moscowTimeZone);
    return tz.TZDateTime.now(moscow);
  }

  @override
  DateTime getTodayInMoscow() {
    final moscow = tz.getLocation(_moscowTimeZone);
    final now = tz.TZDateTime.now(moscow);
    return tz.TZDateTime(moscow, now.year, now.month, now.day);
  }

  @override
  DateTime getStartOfDayInMoscow(DateTime dateTime) {
    final moscow = tz.getLocation(_moscowTimeZone);
    final moscowDateTime = tz.TZDateTime.from(dateTime, moscow);
    return tz.TZDateTime(moscow, moscowDateTime.year, moscowDateTime.month, moscowDateTime.day);
  }

  @override
  DateTime toUtc(DateTime dateTime) {
    return dateTime.toUtc();
  }
}

