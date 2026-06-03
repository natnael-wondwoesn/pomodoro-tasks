class QuizUserResult {
  final List<int> answers;
  final String result;
  final DateTime completedAt;

  const QuizUserResult({
    required this.answers,
    required this.result,
    required this.completedAt,
  });
}

class QuizResult {
  final String quizId;
  final Map<String, QuizUserResult> results;

  const QuizResult({
    required this.quizId,
    this.results = const {},
  });

  bool hasCompleted(String userId) => results.containsKey(userId);
  bool get bothCompleted => results.length >= 2;
}
