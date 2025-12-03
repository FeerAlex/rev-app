import '../entities/reputation_level.dart';
import 'reputation_exp.dart';

/// Утилита для работы с уровнями отношения и опытом
class ReputationHelper {
  final ReputationExp _reputationExp;

  ReputationHelper(this._reputationExp);

  /// Вычислить текущий уровень отношения на основе общего опыта
  ReputationLevel getCurrentReputationLevel(int totalExp, String factionName) {
    // Проверяем уровни от максимального к минимальному
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName) + 
        _reputationExp.getExpForLevel(ReputationLevel.deification, factionName)) {
      return ReputationLevel.maximum;
    }
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName)) {
      return ReputationLevel.deification;
    }
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.adoration, factionName)) {
      return ReputationLevel.adoration;
    }
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.honor, factionName)) {
      return ReputationLevel.honor;
    }
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.respect, factionName)) {
      return ReputationLevel.respect;
    }
    if (totalExp >= _reputationExp.getTotalExpForLevel(ReputationLevel.friendliness, factionName)) {
      return ReputationLevel.friendliness;
    }
    return ReputationLevel.indifference;
  }

  /// Получить опыт в текущем уровне (от 0 до требуемого для уровня)
  int getExpInCurrentLevel(int totalExp, ReputationLevel currentLevel, String factionName) {
    final totalExpForPreviousLevels = _reputationExp.getTotalExpForLevel(currentLevel, factionName);
    return totalExp - totalExpForPreviousLevels;
  }

  /// Получить требуемый опыт для текущего уровня
  int getRequiredExpForCurrentLevel(ReputationLevel currentLevel, String factionName) {
    return _reputationExp.getExpForLevel(currentLevel, factionName);
  }

  /// Получить общий опыт, необходимый для достижения целевого уровня
  int getTotalExpForTargetLevel(ReputationLevel targetLevel, String factionName) {
    if (targetLevel == ReputationLevel.maximum) {
      // Максимальный уровень = Обожествление + его требуемый опыт
      return _reputationExp.getTotalExpForLevel(ReputationLevel.deification, factionName) +
          _reputationExp.getExpForLevel(ReputationLevel.deification, factionName);
    }
    // Для остальных уровней: сумма всех предыдущих + требуемый для целевого уровня
    return _reputationExp.getTotalExpForLevel(targetLevel, factionName) +
        _reputationExp.getExpForLevel(targetLevel, factionName);
  }

  /// Вычислить общий опыт на основе текущего уровня и опыта на уровне
  int getTotalExp(ReputationLevel currentLevel, int currentLevelExp, String factionName) {
    final totalExpForPreviousLevels = _reputationExp.getTotalExpForLevel(currentLevel, factionName);
    return totalExpForPreviousLevels + currentLevelExp;
  }

  /// Вычислить, сколько опыта нужно для достижения целевого уровня
  int getNeededExp(ReputationLevel currentLevel, int currentLevelExp, ReputationLevel targetLevel, String factionName) {
    final totalExp = getTotalExp(currentLevel, currentLevelExp, factionName);
    final totalExpForTarget = getTotalExpForTargetLevel(targetLevel, factionName);
    return (totalExpForTarget - totalExp).clamp(0, double.infinity).toInt();
  }
}

