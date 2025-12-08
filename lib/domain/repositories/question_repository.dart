import '../entities/question.dart';

abstract class QuestionRepository {
  Future<List<Question>> getAllQuestions();
  Future<List<Question>> searchQuestions(String query);
}
