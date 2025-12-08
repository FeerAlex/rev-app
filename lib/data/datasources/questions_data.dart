import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/question.dart';

/// Источник данных для загрузки вопросов из JSON файла
class QuestionsData {
  const QuestionsData._();

  /// Загружает вопросы из JSON файла
  static Future<List<Question>> loadQuestionsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      return jsonList.map((json) => Question(
        id: json['id'] as int,
        question: json['question'] as String,
        answer: json['answer'] as String,
      )).toList();
    } catch (e) {
      // Если файл не найден или произошла ошибка, возвращаем пустой список
      return [];
    }
  }
}
