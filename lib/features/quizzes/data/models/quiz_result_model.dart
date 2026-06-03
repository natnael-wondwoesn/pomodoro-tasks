import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/quizzes/domain/entities/quiz_result.dart';

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.quizId,
    super.results = const {},
  });

  factory QuizResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final resultsRaw = data['results'] as Map<String, dynamic>? ?? {};

    final results = resultsRaw.map((userId, value) {
      final r = value as Map<String, dynamic>;
      return MapEntry(
        userId,
        QuizUserResult(
          answers: (r['answers'] as List<dynamic>?)
                  ?.map((a) => a as int)
                  .toList() ??
              [],
          result: r['result'] as String? ?? '',
          completedAt:
              (r['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
      );
    });

    return QuizResultModel(quizId: doc.id, results: results);
  }

  static Map<String, dynamic> userResultToFirestore(QuizUserResult result) {
    return {
      'answers': result.answers,
      'result': result.result,
      'completedAt': Timestamp.fromDate(result.completedAt),
    };
  }
}
