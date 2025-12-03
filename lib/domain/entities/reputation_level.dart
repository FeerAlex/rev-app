/// Уровни отношения к фракции
enum ReputationLevel {
  indifference, // Равнодушие
  friendliness, // Дружелюбие
  respect, // Уважение
  honor, // Почтение
  adoration, // Преклонение
  deification, // Обожествление
  maximum, // Максимальный
}

extension ReputationLevelExtension on ReputationLevel {
  /// Получить название уровня на русском языке
  String get displayName {
    switch (this) {
      case ReputationLevel.indifference:
        return 'Равнодушие';
      case ReputationLevel.friendliness:
        return 'Дружелюбие';
      case ReputationLevel.respect:
        return 'Уважение';
      case ReputationLevel.honor:
        return 'Почтение';
      case ReputationLevel.adoration:
        return 'Преклонение';
      case ReputationLevel.deification:
        return 'Обожествление';
      case ReputationLevel.maximum:
        return 'Максимальный';
    }
  }

  /// Получить числовое значение уровня (для хранения в БД)
  int get value {
    switch (this) {
      case ReputationLevel.indifference:
        return 0;
      case ReputationLevel.friendliness:
        return 1;
      case ReputationLevel.respect:
        return 2;
      case ReputationLevel.honor:
        return 3;
      case ReputationLevel.adoration:
        return 4;
      case ReputationLevel.deification:
        return 5;
      case ReputationLevel.maximum:
        return 6;
    }
  }

  /// Создать ReputationLevel из числового значения
  static ReputationLevel fromValue(int value) {
    switch (value) {
      case 0:
        return ReputationLevel.indifference;
      case 1:
        return ReputationLevel.friendliness;
      case 2:
        return ReputationLevel.respect;
      case 3:
        return ReputationLevel.honor;
      case 4:
        return ReputationLevel.adoration;
      case 5:
        return ReputationLevel.deification;
      case 6:
        return ReputationLevel.maximum;
      default:
        return ReputationLevel.maximum;
    }
  }
}

