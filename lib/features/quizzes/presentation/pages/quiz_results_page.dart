import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/quiz_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/quizzes/data/models/quiz_result_model.dart';

class QuizResultsPage extends StatelessWidget {
  final QuizDefinition quiz;
  final String pairId;
  final String userId;

  const QuizResultsPage({
    super.key,
    required this.quiz,
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
                    Text(quiz.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pairs')
                      .doc(pairId)
                      .collection('quizResults')
                      .doc(quiz.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                          child: Text('No results yet'));
                    }

                    final result =
                        QuizResultModel.fromFirestore(snapshot.data!);

                    final myResult = result.results[userId];
                    final partnerResult = result.results.entries
                        .where((e) => e.key != userId)
                        .map((e) => e.value)
                        .firstOrNull;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(quiz.emoji,
                              style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('Results',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge),
                          const SizedBox(height: 32),
                          if (myResult != null)
                            _ResultCard(
                              label: 'You',
                              result: myResult.result,
                              description: quiz
                                      .resultDescriptions[myResult.result] ??
                                  myResult.result,
                              gradient: AppGradients.accent,
                            ),
                          const SizedBox(height: 16),
                          if (partnerResult != null)
                            _ResultCard(
                              label: 'Partner',
                              result: partnerResult.result,
                              description: quiz.resultDescriptions[
                                      partnerResult.result] ??
                                  partnerResult.result,
                              gradient: AppGradients.partner,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.hourglass_top_rounded,
                                      size: 32,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  Text('Waiting for partner...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ],
                              ),
                            ),
                        ],
                      ),
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

class _ResultCard extends StatelessWidget {
  final String label;
  final String result;
  final String description;
  final LinearGradient gradient;

  const _ResultCard({
    required this.label,
    required this.result,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  )),
          const SizedBox(height: 8),
          Text(
            result.replaceAll('_', ' ').toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  )),
        ],
      ),
    );
  }
}
