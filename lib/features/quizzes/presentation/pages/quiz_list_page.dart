import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/quiz_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/quizzes/data/models/quiz_result_model.dart';
import 'package:pomodoro_tasks/features/quizzes/presentation/pages/quiz_flow_page.dart';
import 'package:pomodoro_tasks/features/quizzes/presentation/pages/quiz_results_page.dart';

class QuizListPage extends StatelessWidget {
  final String pairId;
  final String userId;

  const QuizListPage({
    super.key,
    required this.pairId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isLight
              ? AppGradients.backgroundLight
              : AppGradients.backgroundDark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('Couple Quizzes',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: QuizPool.quizzes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final quiz = QuizPool.quizzes[index];
                    return _QuizCard(
                      quiz: quiz,
                      pairId: pairId,
                      userId: userId,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizDefinition quiz;
  final String pairId;
  final String userId;

  const _QuizCard({
    required this.quiz,
    required this.pairId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pairs')
          .doc(pairId)
          .collection('quizResults')
          .doc(quiz.id)
          .snapshots(),
      builder: (context, snapshot) {
        final hasData = snapshot.data?.exists ?? false;
        final result = hasData
            ? QuizResultModel.fromFirestore(snapshot.data!)
            : null;
        final myCompleted = result?.hasCompleted(userId) ?? false;
        final bothCompleted = result?.bothCompleted ?? false;

        return GestureDetector(
          onTap: () {
            if (bothCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizResultsPage(
                    quiz: quiz,
                    pairId: pairId,
                    userId: userId,
                  ),
                ),
              );
            } else if (!myCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizFlowPage(
                    quiz: quiz,
                    pairId: pairId,
                    userId: userId,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(quiz.emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(quiz.description,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      _StatusBadge(
                        myCompleted: myCompleted,
                        bothCompleted: bothCompleted,
                      ),
                    ],
                  ),
                ),
                Icon(
                  bothCompleted
                      ? Icons.visibility_rounded
                      : myCompleted
                          ? Icons.hourglass_top_rounded
                          : Icons.play_arrow_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool myCompleted;
  final bool bothCompleted;

  const _StatusBadge({
    required this.myCompleted,
    required this.bothCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = bothCompleted
        ? ('View results', Colors.green)
        : myCompleted
            ? ('Waiting for partner', Colors.orange)
            : ('Take quiz', Theme.of(context).primaryColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
