class DailyQuestionAnswer {
  final String userId;
  final String text;
  final DateTime answeredAt;

  const DailyQuestionAnswer({
    required this.userId,
    required this.text,
    required this.answeredAt,
  });
}

class DailyQuestion {
  final String dateKey;
  final String questionText;
  final int questionId;
  final Map<String, DailyQuestionAnswer> answers;
  final DateTime? revealedAt;

  const DailyQuestion({
    required this.dateKey,
    required this.questionText,
    required this.questionId,
    this.answers = const {},
    this.revealedAt,
  });

  bool get isRevealed => revealedAt != null;

  bool hasAnswered(String userId) => answers.containsKey(userId);

  bool get bothAnswered => answers.length >= 2;
}
