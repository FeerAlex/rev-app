class Question {
  final int id;
  final String question;
  final String answer;

  const Question({
    required this.id,
    required this.question,
    required this.answer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          question == other.question &&
          answer == other.answer;

  @override
  int get hashCode => id.hashCode ^ question.hashCode ^ answer.hashCode;

  @override
  String toString() => 'Question(id: $id, question: $question, answer: $answer)';
}
