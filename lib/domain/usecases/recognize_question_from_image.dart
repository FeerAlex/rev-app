import '../entities/question.dart';
import '../repositories/question_repository.dart';
import '../repositories/text_recognizer.dart';
import '../utils/text_similarity.dart';

/// Результат распознавания вопроса с изображения
class RecognitionResult {
  /// Найденный вопрос (null если не найден)
  final Question? question;
  
  /// Коэффициент совпадения (0.0 - 1.0)
  final double score;
  
  /// Распознанный текст с изображения
  final String recognizedText;

  const RecognitionResult({
    this.question,
    required this.score,
    required this.recognizedText,
  });

  /// Успешно ли найден вопрос
  bool get isFound => question != null;
}

/// Use Case для распознавания вопроса с изображения
/// Объединяет OCR (TextRecognizer) и fuzzy search по базе вопросов.
class RecognizeQuestionFromImage {
  final TextRecognizer textRecognizer;
  final QuestionRepository clubQuestionRepository;
  final QuestionRepository examQuestionRepository;
  final double threshold;

  RecognizeQuestionFromImage({
    required this.textRecognizer,
    required this.clubQuestionRepository,
    required this.examQuestionRepository,
    this.threshold = 0.6,
  });

  /// [imagePath] — путь к файлу изображения
  Future<RecognitionResult> call(String imagePath) async {
    try {
      // 1. OCR
      final recognizedText = await textRecognizer.recognizeTextFromImage(imagePath);

      if (recognizedText.isEmpty) {
        return const RecognitionResult(
          score: 0.0,
          recognizedText: '',
        );
      }

      // 2. Загружаем все вопросы из обоих источников
      final clubQuestions = await clubQuestionRepository.getAllQuestions();
      final examQuestions = await examQuestionRepository.getAllQuestions();
      final allQuestions = [...clubQuestions, ...examQuestions];

      if (allQuestions.isEmpty) {
        return RecognitionResult(
          score: 0.0,
          recognizedText: recognizedText,
        );
      }

      // 3. Разбиваем распознанный текст на строки
      final lines = recognizedText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();


      // 4. Ищем лучшее совпадение среди всех строк и полного текста
      MatchResult? bestMatch;
      double bestScore = 0.0;

      // Сначала пробуем полный текст (все строки объединённые)
      final fullTextMatch = findBestMatch(
        recognizedText,
        allQuestions,
        threshold: threshold,
      );

      if (fullTextMatch != null) {
        bestScore = fullTextMatch.score;
        bestMatch = fullTextMatch;
      }

      // Затем пробуем каждую строку отдельно
      for (final line in lines) {
        final matchResult = findBestMatch(
          line,
          allQuestions,
          threshold: threshold,
        );


        if (matchResult != null && matchResult.score > bestScore) {
          bestScore = matchResult.score;
          bestMatch = matchResult;
        }
      }


      if (bestMatch != null) {
        return RecognitionResult(
          question: bestMatch.question,
          score: bestMatch.score,
          recognizedText: recognizedText,
        );
      }

      // Не найдено совпадение выше порога
      return RecognitionResult(
        score: 0.0,
        recognizedText: recognizedText,
      );
    } catch (e) {
      return const RecognitionResult(
        score: 0.0,
        recognizedText: '',
      );
    }
  }
}

