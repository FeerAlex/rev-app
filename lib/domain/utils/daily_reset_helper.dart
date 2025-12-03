import '../repositories/faction_repository.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/date_time_provider.dart';

class DailyResetHelper {
  static Future<void> checkAndReset(
    FactionRepository factionRepository,
    AppSettingsRepository appSettingsRepository,
    DateTimeProvider dateTimeProvider,
  ) async {
    final lastReset = await appSettingsRepository.getLastResetDate();
    
    final today = dateTimeProvider.getTodayInMoscow();
    
    DateTime? lastResetDate;
    if (lastReset != null) {
      // Преобразуем в московское время для корректного сравнения
      lastResetDate = dateTimeProvider.getStartOfDayInMoscow(lastReset);
    }
    
    // Если последний сброс был не сегодня, сбрасываем
    if (lastResetDate == null || 
        lastResetDate.year != today.year ||
        lastResetDate.month != today.month ||
        lastResetDate.day != today.day) {
      await factionRepository.resetDailyFlags();
      
      // Сохраняем дату сброса
      await appSettingsRepository.saveLastResetDate(dateTimeProvider.toUtc(today));
    }
  }
}

