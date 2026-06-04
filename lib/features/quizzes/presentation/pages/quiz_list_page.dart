import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pomodoro_tasks/core/data/quiz_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/quizzes/data/models/quiz_result_model.dart';
import 'package:pomodoro_tasks/features/quizzes/presentation/pages/quiz_flow_page.dart';
import 'package:pomodoro_tasks/features/quizzes/presentation/pages/quiz_results_page.dart';

const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

class QuizListPage extends StatelessWidget {
  final String pairId;
  final String userId;

  const QuizListPage({super.key, required this.pairId, required this.userId});

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Couple Quizzes',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pairs')
                      .doc(pairId)
                      .collection('generatedQuizzes')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final generated = (snapshot.data?.docs ?? const [])
                        .map(_GeneratedQuizModel.fromFirestore)
                        .toList();
                    final quizzes = <({QuizDefinition quiz, bool canGenerate})>[
                      for (final quiz in generated)
                        (quiz: quiz.definition, canGenerate: false),
                      for (final quiz in QuizPool.quizzes)
                        (quiz: quiz, canGenerate: true),
                    ];

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: quizzes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = quizzes[index];
                        return _QuizCard(
                          quiz: item.quiz,
                          pairId: pairId,
                          userId: userId,
                          canGenerateVariant: item.canGenerate,
                        );
                      },
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

class _QuizCard extends StatefulWidget {
  final QuizDefinition quiz;
  final String pairId;
  final String userId;
  final bool canGenerateVariant;

  const _QuizCard({
    required this.quiz,
    required this.pairId,
    required this.userId,
    required this.canGenerateVariant,
  });

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  final _client = _GeminiQuizClient();
  var _generating = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pairs')
          .doc(widget.pairId)
          .collection('quizResults')
          .doc(widget.quiz.id)
          .snapshots(),
      builder: (context, snapshot) {
        final hasData = snapshot.data?.exists ?? false;
        final result = hasData
            ? QuizResultModel.fromFirestore(snapshot.data!)
            : null;
        final myCompleted = result?.hasCompleted(widget.userId) ?? false;
        final bothCompleted = result?.bothCompleted ?? false;

        return GestureDetector(
          onTap: () {
            if (bothCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizResultsPage(
                    quiz: widget.quiz,
                    pairId: widget.pairId,
                    userId: widget.userId,
                  ),
                ),
              );
            } else if (!myCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizFlowPage(
                    quiz: widget.quiz,
                    pairId: widget.pairId,
                    userId: widget.userId,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
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
                    child: Text(
                      widget.quiz.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.quiz.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.quiz.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _StatusBadge(
                            myCompleted: myCompleted,
                            bothCompleted: bothCompleted,
                          ),
                          if (widget.canGenerateVariant)
                            _GeminiVariantChip(
                              generating: _generating,
                              onPressed: _generating
                                  ? null
                                  : () => _generateVariant(context),
                            ),
                        ],
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

  Future<void> _generateVariant(BuildContext context) async {
    setState(() => _generating = true);

    try {
      final quiz = await _client.generateQuiz(
        '${widget.quiz.title}: ${widget.quiz.description}',
        seedQuiz: widget.quiz,
      );
      await FirebaseFirestore.instance
          .collection('pairs')
          .doc(widget.pairId)
          .collection('generatedQuizzes')
          .doc(quiz.id)
          .set({
            ..._GeneratedQuizModel(quiz).toFirestore(),
            'sourceQuizId': widget.quiz.id,
            'createdBy': widget.userId,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuizFlowPage(
            quiz: quiz,
            pairId: widget.pairId,
            userId: widget.userId,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate quiz: $error')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool myCompleted;
  final bool bothCompleted;

  const _StatusBadge({required this.myCompleted, required this.bothCompleted});

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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _GeminiVariantChip extends StatelessWidget {
  final bool generating;
  final VoidCallback? onPressed;

  const _GeminiVariantChip({required this.generating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: generating
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_awesome_rounded, size: 16),
      label: const Text('AI version'),
      onPressed: onPressed,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }
}

class _GeminiQuizClient {
  static const _model = 'gemini-2.5-flash';

  Future<QuizDefinition> generateQuiz(
    String topic, {
    required QuizDefinition seedQuiz,
  }) async {
    if (_geminiApiKey.isEmpty) {
      throw Exception(
        'Missing GEMINI_API_KEY. Build with --dart-define=GEMINI_API_KEY=your_key.',
      );
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _geminiApiKey},
    );
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _promptFor(topic, seedQuiz)},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.55},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gemini request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidate =
        ((data['candidates'] as List?) ?? const []).firstOrNull
            as Map<String, dynamic>?;
    final parts =
        ((candidate?['content'] as Map<String, dynamic>?)?['parts'] as List?) ??
        const [];
    final text = parts
        .whereType<Map<String, dynamic>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw Exception('Gemini returned no quiz.');
    }

    return _GeneratedQuizModel.fromJson(_decodeJsonObject(text)).definition;
  }

  Map<String, dynamic> _decodeJsonObject(String text) {
    final trimmed = text.trim();
    final withoutFence = trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
    final start = withoutFence.indexOf('{');
    final end = withoutFence.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('Gemini returned an unreadable quiz.');
    }
    return jsonDecode(withoutFence.substring(start, end + 1))
        as Map<String, dynamic>;
  }

  String _promptFor(String topic, QuizDefinition seedQuiz) {
    final idSuffix = DateTime.now().millisecondsSinceEpoch;
    final categoryKeys = seedQuiz.resultDescriptions.keys.join(', ');
    final categoryDescriptions = seedQuiz.resultDescriptions.entries
        .map((e) => '  - ${e.key}: ${e.value}')
        .join('\n');
    return '''
You are a couples relationship coach creating a personalized compatibility quiz. Your goal is to help couples understand each other better through thoughtful, revealing questions.

## Context
You are creating a fresh variant of an existing quiz category for a couples app.

Existing quiz baseline:
- Title: "${seedQuiz.title}"
- Description: "${seedQuiz.description}"
- Result categories and their meanings:
$categoryDescriptions

The user wants this specific angle/focus:
"$topic"

## Quiz Design Principles
1. **Scenario-based questions** — present realistic relationship situations rather than abstract preferences. "It's Saturday morning and neither of you has plans..." is better than "Do you prefer..."
2. **No obvious "right" answers** — every option should feel like a valid, healthy choice. Avoid making any category sound negative.
3. **Emotional depth gradient** — start with lighter, fun questions and gradually move to deeper emotional territory by question 4-5.
4. **Couple-specific framing** — questions should be about "you and your partner" or "in your relationship", not generic personality questions.
5. **Cultural sensitivity** — avoid assumptions about lifestyle, religion, income, or living situation. Keep it universal.
6. **Balanced category distribution** — each of the 4 categories should appear as an option in at least 3 of the 5 questions, so no category is under-represented.

## Strict Rules
- Keep it healthy, respectful, and suitable for all couples.
- Exactly 5 questions. No more, no less.
- Every question must have exactly 4 options (one per category).
- Use exactly 4 result categories with short snake_case keys.
- Prefer the same result category keys ($categoryKeys) unless the topic genuinely demands different categories. If you change them, make the new categories equally balanced and non-judgmental.
- Every option's category field must exactly match one of the result category keys.
- Result descriptions must be warm, affirming, and actionable — tell the person what their strength is AND give one concrete tip for connecting with a partner who has a different result.
- Make the title clearly related to "${seedQuiz.title}" but distinctive and engaging.
- The emoji should visually represent the quiz topic, not just a heart.

## Response Format
Return ONLY valid JSON (no markdown fences, no explanation, no preamble):
{
  "id": "gemini_$idSuffix",
  "title": "short engaging quiz title",
  "description": "one compelling sentence that makes couples want to take this quiz",
  "emoji": "single relevant emoji",
  "resultDescriptions": {
    "category_key": "Display Name \u2014 warm, specific description of this type with a tip for understanding partners who differ"
  },
  "questions": [
    {
      "text": "scenario-based question framed for couples",
      "options": [
        {"text": "natural, conversational answer (not a label)", "category": "category_key"}
      ]
    }
  ]
}
''';
  }
}

class _GeneratedQuizModel {
  final QuizDefinition definition;

  const _GeneratedQuizModel(this.definition);

  factory _GeneratedQuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? const {};
    return _GeneratedQuizModel.fromJson({...data, 'id': doc.id});
  }

  factory _GeneratedQuizModel.fromJson(Map<String, dynamic> json) {
    final resultDescriptions =
        (json['resultDescriptions'] as Map<String, dynamic>? ?? const {}).map(
          (key, value) => MapEntry(key, value.toString()),
        );
    final questions = ((json['questions'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_questionFromJson)
        .where((question) => question.options.length >= 2)
        .take(5)
        .toList();

    if (questions.isEmpty || resultDescriptions.isEmpty) {
      throw Exception('Generated quiz was incomplete.');
    }

    return _GeneratedQuizModel(
      QuizDefinition(
        id:
            json['id'] as String? ??
            'gemini_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title'] as String? ?? 'Gemini Quiz',
        description: json['description'] as String? ?? 'A custom couple quiz.',
        emoji: json['emoji'] as String? ?? '\u{2728}',
        questions: questions,
        resultDescriptions: resultDescriptions,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': definition.id,
      'title': definition.title,
      'description': definition.description,
      'emoji': definition.emoji,
      'resultDescriptions': definition.resultDescriptions,
      'questions': [
        for (final question in definition.questions)
          {
            'text': question.text,
            'options': [
              for (final option in question.options)
                {'text': option.text, 'category': option.category},
            ],
          },
      ],
    };
  }

  static QuizQuestion _questionFromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      text: json['text'] as String? ?? '',
      options: ((json['options'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (option) => QuizOption(
              text: option['text'] as String? ?? '',
              category: option['category'] as String? ?? '',
            ),
          )
          .where(
            (option) => option.text.isNotEmpty && option.category.isNotEmpty,
          )
          .take(4)
          .toList(),
    );
  }
}
