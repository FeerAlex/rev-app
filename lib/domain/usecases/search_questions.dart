import '../entities/question.dart';
import '../repositories/question_repository.dart';

class SearchQuestions {
  final QuestionRepository repository;

  SearchQuestions(this.repository);

  Future<List<Question>> call(String query) async {
    return await repository.searchQuestions(query);
  }
}
