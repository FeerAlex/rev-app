import 'reputation_level.dart';
import 'app_settings.dart';
import 'factions_list.dart';

/// Константы опыта, требуемого для достижения уровней отношения
class ReputationExp {
  ReputationExp._();

  /// Получить требуемый опыт для уровня с учетом особых значений для некоторых фракций
  static int getExpForLevel(ReputationLevel level, String factionName) {
    final template = FactionsList.getTemplateByName(factionName);
    final expIndex = (template?.hasSpecialExp ?? false) ? 1 : 0; // Преобразование bool в int

    switch (level) {
      case ReputationLevel.indifference:
        return FactionsSettings.reputationExp.indifference[expIndex];
      case ReputationLevel.friendliness:
        return FactionsSettings.reputationExp.friendliness[expIndex];
      case ReputationLevel.respect:
        return FactionsSettings.reputationExp.respect[expIndex];
      case ReputationLevel.honor:
        return FactionsSettings.reputationExp.honor[expIndex];
      case ReputationLevel.adoration:
        return FactionsSettings.reputationExp.adoration[expIndex];
      case ReputationLevel.deification:
        return FactionsSettings.reputationExp.deification[expIndex];
      case ReputationLevel.maximum:
        // Максимальный уровень - это достижение Обожествления
        return FactionsSettings.reputationExp.deification[expIndex];
    }
  }

  /// Получить общий опыт, необходимый для достижения уровня (сумма всех предыдущих уровней)
  static int getTotalExpForLevel(ReputationLevel level, String factionName) {
    int total = 0;
    
    // Суммируем опыт всех уровней до целевого
    for (final lvl in ReputationLevel.values) {
      if (lvl == level) break;
      total += getExpForLevel(lvl, factionName);
    }
    
    return total;
  }
}

