import '../utils/question_source.dart';

class Question {
  final int id;
  final String question;
  final List<String> answers;
  final QuestionSource source;

  const Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          question == other.question &&
          source == other.source &&
          _listEquals(answers, other.answers);

  @override
  int get hashCode => id.hashCode ^ question.hashCode ^ source.hashCode ^ _listHashCode(answers);

  @override
  String toString() => 'Question(id: $id, question: $question, answers: $answers, source: $source)';

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHashCode(List<String> list) {
    int result = 0;
    for (final item in list) {
      result ^= item.hashCode;
    }
    return result;
  }
}
