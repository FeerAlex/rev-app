import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import '../../domain/usecases/reset_daily_flags.dart';

class DailyResetHelper {
  static const String _lastResetKey = 'last_daily_reset';

  static Future<void> checkAndReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_lastResetKey);
    
    final moscow = tz.getLocation('Europe/Moscow');
    final now = tz.TZDateTime.now(moscow);
    final today = tz.TZDateTime(moscow, now.year, now.month, now.day);
    
    DateTime? lastReset;
    if (lastResetString != null) {
      try {
        lastReset = DateTime.parse(lastResetString);
        // Преобразуем в московское время для корректного сравнения
        lastReset = tz.TZDateTime.from(lastReset, moscow);
        lastReset = tz.TZDateTime(moscow, lastReset.year, lastReset.month, lastReset.day);
      } catch (e) {
        // Если не удалось распарсить, считаем что сброс не был
        lastReset = null;
      }
    }
    
    // Если последний сброс был не сегодня, сбрасываем
    if (lastReset == null || 
        lastReset.year != today.year ||
        lastReset.month != today.month ||
        lastReset.day != today.day) {
      final serviceLocator = ServiceLocator();
      final resetDailyFlags = ResetDailyFlags(serviceLocator.factionRepository);
      await resetDailyFlags();
      
      // Сохраняем дату сброса
      await prefs.setString(_lastResetKey, today.toIso8601String());
    }
  }
}

