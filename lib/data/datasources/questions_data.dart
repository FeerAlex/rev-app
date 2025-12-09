import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/question.dart';

/// Источник данных для загрузки вопросов из JSON файла
class QuestionsData {
  const QuestionsData._();

  static const defaultAssetPath = 'assets/questions/questions_club.json';

  /// Загружает вопросы из JSON файла по указанному пути
  static Future<List<Question>> loadQuestionsFromJson({String assetPath = defaultAssetPath}) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      return jsonList.map((json) => Question(
        id: json['id'] as int,
        question: json['question'] as String,
        answers: (json['answers'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      )).toList();
    } catch (e) {
      // Если файл не найден или произошла ошибка, возвращаем пустой список
      return [];
    }
  }
}
