/// Источник вопроса
enum QuestionSource {
  /// Клуб знатоков
  club,
  
  /// Теософский экзамен
  exam,
}

extension QuestionSourceExtension on QuestionSource {
  /// Возвращает отображаемое название источника
  String get displayName {
    switch (this) {
      case QuestionSource.club:
        return 'Клуб знатоков';
      case QuestionSource.exam:
        return 'Теософский экзамен';
    }
  }
}

