import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../datasources/questions_data.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final String _assetPath;
  List<Question>? _cachedQuestions;

  QuestionRepositoryImpl({String assetPath = QuestionsData.defaultAssetPath}) : _assetPath = assetPath;

  Future<List<Question>> _loadQuestions() async {
    _cachedQuestions ??= await QuestionsData.loadQuestionsFromJson(assetPath: _assetPath);
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
