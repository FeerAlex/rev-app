import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/questions_data.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  List<Question>? _cachedQuestions;

  QuestionRepositoryImpl();

  Future<List<Question>> _loadQuestions() async {
    _cachedQuestions ??= await QuestionsData.loadQuestionsFromJson();
    return _cachedQuestions!;
  }

  @override
  Future<List<Question>> getAllQuestions() async {
    return await _loadQuestions();
  }

  @override
  Future<List<Question>> searchQuestions(String query) async {
    if (query.trim().isEmpty) {
      return await getAllQuestions();
    }

    final allQuestions = await _loadQuestions();
    final queryLower = query.toLowerCase().trim();

    return allQuestions.where((question) {
      return question.question.toLowerCase().contains(queryLower) ||
          question.answers.any((answer) => answer.toLowerCase().contains(queryLower));
    }).toList();
  }
}
