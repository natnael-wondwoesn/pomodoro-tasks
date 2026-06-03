import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/quiz_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/quizzes/data/models/quiz_result_model.dart';
import 'package:pomodoro_tasks/features/quizzes/domain/entities/quiz_result.dart';

class QuizFlowPage extends StatefulWidget {
  final QuizDefinition quiz;
  final String pairId;
  final String userId;

  const QuizFlowPage({
    super.key,
    required this.quiz,
    required this.pairId,
    required this.userId,
  });

  @override
  State<QuizFlowPage> createState() => _QuizFlowPageState();
}

class _QuizFlowPageState extends State<QuizFlowPage> {
  int _currentIndex = 0;
  final List<int> _answers = [];
  bool _submitting = false;

  QuizQuestion get _currentQuestion =>
      widget.quiz.questions[_currentIndex];
  bool get _isLast => _currentIndex >= widget.quiz.questions.length - 1;
  double get _progress =>
      (_currentIndex + 1) / widget.quiz.questions.length;

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
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentIndex + 1}/${widget.quiz.questions.length}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.quiz.emoji,
                        style: const TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentQuestion.text,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ..._currentQuestion.options.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OptionButton(
                                text: entry.value.text,
                                onTap: () => _selectOption(entry.key),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              if (_submitting)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectOption(int optionIndex) async {
    _answers.add(optionIndex);

    if (_isLast) {
      await _submitResults();
    } else {
      setState(() => _currentIndex++);
    }
  }

  Future<void> _submitResults() async {
    setState(() => _submitting = true);

    final resultCategory = widget.quiz.calculateResult(_answers);
    final userResult = QuizUserResult(
      answers: _answers,
      result: resultCategory,
      completedAt: DateTime.now(),
    );

    final docRef = FirebaseFirestore.instance
        .collection('pairs')
        .doc(widget.pairId)
        .collection('quizResults')
        .doc(widget.quiz.id);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'results': {
          widget.userId: QuizResultModel.userResultToFirestore(userResult),
        },
      });
    } else {
      await docRef.update({
        'results.${widget.userId}':
            QuizResultModel.userResultToFirestore(userResult),
      });
    }

    if (mounted) Navigator.pop(context);
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
