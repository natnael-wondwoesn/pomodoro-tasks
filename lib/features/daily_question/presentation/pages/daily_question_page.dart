import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/daily_questions_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/daily_question/data/models/daily_question_model.dart';
import 'package:pomodoro_tasks/features/daily_question/domain/entities/daily_question.dart';

class DailyQuestionPage extends StatefulWidget {
  final String pairId;
  final String userId;

  const DailyQuestionPage({
    super.key,
    required this.pairId,
    required this.userId,
  });

  @override
  State<DailyQuestionPage> createState() => _DailyQuestionPageState();
}

class _DailyQuestionPageState extends State<DailyQuestionPage> {
  final _answerController = TextEditingController();
  bool _submitting = false;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DocumentReference get _docRef => FirebaseFirestore.instance
      .collection('pairs')
      .doc(widget.pairId)
      .collection('dailyQuestions')
      .doc(_todayKey);

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

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
                    Text(
                      "Today's Question",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _docRef.snapshots(),
                  builder: (context, snapshot) {
                    final question = _resolveQuestion(snapshot);
                    return _buildContent(context, question);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyQuestion question) {
    final hasAnswered = question.hasAnswered(widget.userId);
    final bothAnswered = question.bothAnswered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Question bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.chat_bubble_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Answer section
          if (!hasAnswered) _buildAnswerInput(context, question),
          if (hasAnswered && !bothAnswered) _buildWaitingState(context),
          if (bothAnswered) _buildRevealedAnswers(context, question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(BuildContext context, DailyQuestion question) {
    return Column(
      children: [
        TextField(
          controller: _answerController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitting ? null : () => _submitAnswer(question),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Answer',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 48,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for your partner...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "You'll both see each other's answers once they respond!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedAnswers(BuildContext context, DailyQuestion question) {
    final entries = question.answers.entries.toList();
    final myAnswer = question.answers[widget.userId];
    final partnerAnswer = entries
        .where((e) => e.key != widget.userId)
        .map((e) => e.value)
        .firstOrNull;

    return Column(
      children: [
        _buildAnswerBubble(
          context,
          label: 'You',
          answer: myAnswer?.text ?? '',
          gradient: AppGradients.accent,
        ),
        const SizedBox(height: 16),
        _buildAnswerBubble(
          context,
          label: 'Partner',
          answer: partnerAnswer?.text ?? '',
          gradient: AppGradients.partner,
        ),
      ],
    );
  }

  Widget _buildAnswerBubble(
    BuildContext context, {
    required String label,
    required String answer,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer(DailyQuestion question) async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);

    try {
      final answer = DailyQuestionAnswer(
        userId: widget.userId,
        text: text,
        answeredAt: DateTime.now(),
      );

      final docSnapshot = await _docRef.get();
      if (!docSnapshot.exists) {
        await _docRef.set({
          ...DailyQuestionModel(
            dateKey: question.dateKey,
            questionText: question.questionText,
            questionId: question.questionId,
          ).toFirestore(),
          'answers': {
            widget.userId: DailyQuestionModel.answerToFirestore(answer),
          },
        });
      } else {
        await _docRef.update({
          'answers.${widget.userId}':
              DailyQuestionModel.answerToFirestore(answer),
        });

        // Check if both answered — set revealedAt
        final updated = await _docRef.get();
        final data = updated.data() as Map<String, dynamic>? ?? {};
        final answers = data['answers'] as Map<String, dynamic>? ?? {};
        if (answers.length >= 2 && data['revealedAt'] == null) {
          await _docRef.update({
            'revealedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
