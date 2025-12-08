import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetAllQuestions {
  final QuestionRepository repository;

  GetAllQuestions(this.repository);

  Future<List<Question>> call() async {
    return await repository.getAllQuestions();
  }
}
