import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/daily_question/domain/entities/daily_question.dart';

class DailyQuestionModel extends DailyQuestion {
  const DailyQuestionModel({
    required super.dateKey,
    required super.questionText,
    required super.questionId,
    super.answers = const {},
    super.revealedAt,
  });

  factory DailyQuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final answersRaw = data['answers'] as Map<String, dynamic>? ?? {};

    final answers = answersRaw.map((userId, value) {
      final answerData = value as Map<String, dynamic>;
      return MapEntry(
        userId,
        DailyQuestionAnswer(
          userId: userId,
          text: answerData['text'] as String? ?? '',
          answeredAt: (answerData['answeredAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
        ),
      );
    });

    return DailyQuestionModel(
      dateKey: doc.id,
      questionText: data['questionText'] as String? ?? '',
      questionId: data['questionId'] as int? ?? 0,
      answers: answers,
      revealedAt: (data['revealedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'questionId': questionId,
      'revealedAt': revealedAt != null ? Timestamp.fromDate(revealedAt!) : null,
    };
  }

  static Map<String, dynamic> answerToFirestore(DailyQuestionAnswer answer) {
    return {
      'text': answer.text,
      'answeredAt': Timestamp.fromDate(answer.answeredAt),
    };
  }
}
