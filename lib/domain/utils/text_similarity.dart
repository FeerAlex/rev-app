import '../entities/question.dart';

/// Утилиты для работы с текстовым сходством и нечётким поиском

/// Нормализует текст для сравнения
/// 
/// Приводит к lowercase, удаляет знаки препинания, 
/// оставляет только буквы и пробелы (включая русские)
String normalizeText(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s\u0400-\u04FF]'), '') // только буквы и пробелы
      .replaceAll(RegExp(r'\s+'), ' ') // множественные пробелы в один
      .trim();
}

/// Вычисляет коэффициент сходства между двумя строками
/// 
/// Использует алгоритм Levenshtein distance (расстояние редактирования)
/// Возвращает значение от 0.0 (нет совпадения) до 1.0 (полное совпадение)
double calculateSimilarity(String text1, String text2) {
  if (text1 == text2) return 1.0;
  if (text1.isEmpty || text2.isEmpty) return 0.0;

  final len1 = text1.length;
  final len2 = text2.length;
  
  // Матрица расстояний
  final matrix = List.generate(
    len1 + 1,
    (i) => List.filled(len2 + 1, 0),
  );

  // Инициализация первой строки и столбца
  for (var i = 0; i <= len1; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j <= len2; j++) {
    matrix[0][j] = j;
  }

  // Заполнение матрицы
  for (var i = 1; i <= len1; i++) {
    for (var j = 1; j <= len2; j++) {
      final cost = text1[i - 1] == text2[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1, // удаление
        matrix[i][j - 1] + 1, // вставка
        matrix[i - 1][j - 1] + cost, // замена
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  final distance = matrix[len1][len2];
  final maxLen = len1 > len2 ? len1 : len2;
  
  // Преобразуем расстояние в similarity score (0-1)
  return 1.0 - (distance / maxLen);
}

/// Результат поиска с информацией о совпадении
class MatchResult {
  final Question question;
  final double score;

  const MatchResult({
    required this.question,
    required this.score,
  });
}

/// Находит лучшее совпадение вопроса в списке
/// 
/// [query] - поисковый запрос (распознанный текст)
/// [questions] - список вопросов для поиска
/// [threshold] - минимальный порог совпадения (по умолчанию 0.6 = 60%)
/// 
/// Возвращает MatchResult с вопросом и score, или null если не найдено
MatchResult? findBestMatch(
  String query,
  List<Question> questions, {
  double threshold = 0.6,
}) {
  if (query.isEmpty || questions.isEmpty) return null;

  final normalizedQuery = normalizeText(query);
  if (normalizedQuery.isEmpty) return null;

  double bestScore = 0;
  Question? bestMatch;

  for (final question in questions) {
    final normalizedQuestion = normalizeText(question.question);
    if (normalizedQuestion.isEmpty) continue;
    
    final score = calculateSimilarity(normalizedQuery, normalizedQuestion);

    if (score > bestScore) {
      bestScore = score;
      bestMatch = question;
    }
  }

  // Возвращаем только если score выше порога
  if (bestScore >= threshold && bestMatch != null) {
    return MatchResult(question: bestMatch, score: bestScore);
  }

  return null;
}

