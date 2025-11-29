import 'reputation_level.dart';

/// Константы опыта, требуемого для достижения уровней отношения
class ReputationExp {
  ReputationExp._();

  // Стандартные значения опыта для уровней
  static const int indifferenceExp = 16000; // Равнодушие
  static const int friendlinessExp = 43000; // Дружелюбие
  static const int respectExp = 48000; // Уважение
  static const int honorExp = 80000; // Почтение
  static const int adorationExpStandard = 105000; // Преклонение (стандартное)
  static const int adorationExpSpecial = 115000; // Преклонение (для некоторых фракций)
  static const int deificationExpStandard = 170000; // Обожествление (стандартное)
  static const int deificationExpSpecial = 180000; // Обожествление (для некоторых фракций)

  // TODO: Определить список фракций с особыми значениями
  // Пока структура готова, конкретные фракции определим позже
  static const List<String> factionsWithSpecialExp = [];

  /// Получить требуемый опыт для уровня с учетом особых значений для некоторых фракций
  static int getExpForLevel(ReputationLevel level, String factionName) {
    final hasSpecialExp = factionsWithSpecialExp.contains(factionName);

    switch (level) {
      case ReputationLevel.indifference:
        return indifferenceExp;
      case ReputationLevel.friendliness:
        return friendlinessExp;
      case ReputationLevel.respect:
        return respectExp;
      case ReputationLevel.honor:
        return honorExp;
      case ReputationLevel.adoration:
        return hasSpecialExp ? adorationExpSpecial : adorationExpStandard;
      case ReputationLevel.deification:
        return hasSpecialExp ? deificationExpSpecial : deificationExpStandard;
      case ReputationLevel.maximum:
        // Максимальный уровень - это достижение Обожествления
        return hasSpecialExp ? deificationExpSpecial : deificationExpStandard;
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

