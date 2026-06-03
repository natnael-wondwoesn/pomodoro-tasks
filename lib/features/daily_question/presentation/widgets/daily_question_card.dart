import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/daily_questions_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/daily_question/data/models/daily_question_model.dart';
import 'package:pomodoro_tasks/features/daily_question/domain/entities/daily_question.dart';
import 'package:pomodoro_tasks/features/daily_question/presentation/pages/daily_question_page.dart';

class DailyQuestionCard extends StatelessWidget {
  final String pairId;
  final String userId;

  const DailyQuestionCard({
    super.key,
    required this.pairId,
    required this.userId,
  });

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (pairId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pairs')
          .doc(pairId)
          .collection('dailyQuestions')
          .doc(_todayKey)
          .snapshots(),
      builder: (context, snapshot) {
        final question = _resolveQuestion(snapshot);
        final hasAnswered = question.hasAnswered(userId);
        final bothAnswered = question.bothAnswered;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DailyQuestionPage(
                pairId: pairId,
                userId: userId,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Question",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        !hasAnswered
                            ? 'Tap to answer!'
                            : bothAnswered
                                ? 'Both answered! Tap to reveal'
                                : 'Waiting for partner...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  bothAnswered
                      ? Icons.visibility_rounded
                      : hasAnswered
                          ? Icons.hourglass_top_rounded
                          : Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DailyQuestion _resolveQuestion(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasData && snapshot.data!.exists) {
      return DailyQuestionModel.fromFirestore(snapshot.data!);
    }
    final now = DateTime.now();
    return DailyQuestion(
      dateKey: _todayKey,
      questionText: DailyQuestionPool.questionForDate(now),
      questionId: DailyQuestionPool.questionIdForDate(now),
    );
  }
}
