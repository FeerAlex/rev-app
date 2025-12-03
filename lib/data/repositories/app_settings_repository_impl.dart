import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  @override
  int getDecorationUpgradeCostRespect() {
    return AppSettings.factions.decorationUpgradeCostRespect;
  }

  @override
  int getDecorationUpgradeCostHonor() {
    return AppSettings.factions.decorationUpgradeCostHonor;
  }

  @override
  int getDecorationUpgradeCostAdoration() {
    return AppSettings.factions.decorationUpgradeCostAdoration;
  }

  @override
  int getDecorationPriceRespect() {
    return AppSettings.factions.decorationPriceRespect;
  }

  @override
  int getDecorationPriceHonor() {
    return AppSettings.factions.decorationPriceHonor;
  }

  @override
  int getDecorationPriceAdoration() {
    return AppSettings.factions.decorationPriceAdoration;
  }

  @override
  int getCertificatePrice() {
    return AppSettings.factions.certificatePrice;
  }

  @override
  int getExpForLevel(String factionName, int levelIndex, bool hasSpecialExp) {
    final expIndex = hasSpecialExp ? 1 : 0;
    final expValues = AppSettings.factions.reputationExp;

    switch (levelIndex) {
      case 0: // indifference
        return expValues.indifference[expIndex];
      case 1: // friendliness
        return expValues.friendliness[expIndex];
      case 2: // respect
        return expValues.respect[expIndex];
      case 3: // honor
        return expValues.honor[expIndex];
      case 4: // adoration
        return expValues.adoration[expIndex];
      case 5: // deification
        return expValues.deification[expIndex];
      default:
        return expValues.deification[expIndex];
    }
  }

  @override
  int getTotalExpForLevel(String factionName, int levelIndex, bool hasSpecialExp) {
    int total = 0;
    for (int i = 0; i < levelIndex; i++) {
      total += getExpForLevel(factionName, i, hasSpecialExp);
    }
    return total;
  }

  static const String _lastResetKey = 'last_daily_reset';

  @override
  Future<DateTime?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_lastResetKey);
    if (lastResetString == null) {
      return null;
    }
    try {
      return DateTime.parse(lastResetString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetKey, date.toIso8601String());
  }
}

