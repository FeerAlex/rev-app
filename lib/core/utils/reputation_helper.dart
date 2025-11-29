import '../constants/reputation_level.dart';
import '../constants/reputation_exp.dart';

/// Утилита для работы с уровнями отношения и опытом
class ReputationHelper {
  ReputationHelper._();

  /// Вычислить текущий уровень отношения на основе общего опыта
  static ReputationLevel getCurrentReputationLevel(int totalExp, String factionName) {
    // Проверяем уровни от максимального к минимальному
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName) + 
        ReputationExp.getExpForLevel(ReputationLevel.deification, factionName)) {
      return ReputationLevel.maximum;
    }
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName)) {
      return ReputationLevel.deification;
    }
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.adoration, factionName)) {
      return ReputationLevel.adoration;
    }
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.honor, factionName)) {
      return ReputationLevel.honor;
    }
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.respect, factionName)) {
      return ReputationLevel.respect;
    }
    if (totalExp >= ReputationExp.getTotalExpForLevel(ReputationLevel.friendliness, factionName)) {
      return ReputationLevel.friendliness;
    }
    return ReputationLevel.indifference;
  }

  /// Получить опыт в текущем уровне (от 0 до требуемого для уровня)
  static int getExpInCurrentLevel(int totalExp, ReputationLevel currentLevel, String factionName) {
    final totalExpForPreviousLevels = ReputationExp.getTotalExpForLevel(currentLevel, factionName);
    return totalExp - totalExpForPreviousLevels;
  }

  /// Получить требуемый опыт для текущего уровня
  static int getRequiredExpForCurrentLevel(ReputationLevel currentLevel, String factionName) {
    return ReputationExp.getExpForLevel(currentLevel, factionName);
  }

  /// Получить общий опыт, необходимый для достижения целевого уровня
  static int getTotalExpForTargetLevel(ReputationLevel targetLevel, String factionName) {
    if (targetLevel == ReputationLevel.maximum) {
      // Максимальный уровень = Обожествление + его требуемый опыт
      return ReputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName) +
          ReputationExp.getExpForLevel(ReputationLevel.deification, factionName);
    }
    // Для остальных уровней: сумма всех предыдущих + требуемый для целевого уровня
    return ReputationExp.getTotalExpForLevel(targetLevel, factionName) +
        ReputationExp.getExpForLevel(targetLevel, factionName);
  }

  /// Вычислить общий опыт на основе текущего уровня и опыта на уровне
  static int getTotalExp(ReputationLevel currentLevel, int currentLevelExp, String factionName) {
    final totalExpForPreviousLevels = ReputationExp.getTotalExpForLevel(currentLevel, factionName);
    return totalExpForPreviousLevels + currentLevelExp;
  }

  /// Вычислить, сколько опыта нужно для достижения целевого уровня
  static int getNeededExp(ReputationLevel currentLevel, int currentLevelExp, ReputationLevel targetLevel, String factionName) {
    final totalExp = getTotalExp(currentLevel, currentLevelExp, factionName);
    final totalExpForTarget = getTotalExpForTargetLevel(targetLevel, factionName);
    return (totalExpForTarget - totalExp).clamp(0, double.infinity).toInt();
  }
}

