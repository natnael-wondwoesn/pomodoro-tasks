import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pomodoro_tasks/core/data/date_ideas_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:url_launcher/url_launcher.dart';

const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

class DateIdeasPage extends StatefulWidget {
  final String pairId;

  const DateIdeasPage({super.key, required this.pairId});

  @override
  State<DateIdeasPage> createState() => _DateIdeasPageState();
}

class _DateIdeasPageState extends State<DateIdeasPage> {
  DateIdeaCategory? _filter;
  DateIdea? _randomIdea;
  bool _showFavorites = false;

  List<DateIdea> get _filteredIdeas {
    if (_filter == null) return DateIdeasPool.ideas;
    return DateIdeasPool.ideas.where((i) => i.category == _filter).toList();
  }

  void _getRandomIdea() {
    final pool = _filteredIdeas;
    setState(() {
      _randomIdea = pool[Random().nextInt(pool.length)];
    });
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
                    Text(
                      'Date Ideas',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _showFavorites
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _showFavorites ? Colors.red : null,
                      ),
                      onPressed: () =>
                          setState(() => _showFavorites = !_showFavorites),
                    ),
                  ],
                ),
              ),

              // Random idea button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.accent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _getRandomIdea,
                          icon: const Icon(
                            Icons.shuffle_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Random Date Idea!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _AddisAiButton(onPressed: () => _showAddisAiSheet(context)),
                  ],
                ),
              ),

              // Random idea display
              if (_randomIdea != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _DateIdeaCard(
                    idea: _randomIdea!,
                    pairId: widget.pairId,
                    highlighted: true,
                  ),
                ),

              // Category filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'All'),
                      ...DateIdeaCategory.values.map((cat) {
                        final label = switch (cat) {
                          DateIdeaCategory.adventure =>
                            '\u{1F3D4}\uFE0F Adventure',
                          DateIdeaCategory.cozy => '\u{1F6CB}\uFE0F Cozy',
                          DateIdeaCategory.creative => '\u{1F3A8} Creative',
                          DateIdeaCategory.foodie => '\u{1F37D}\uFE0F Foodie',
                          DateIdeaCategory.free => '\u{1F33F} Free',
                        };
                        return _buildFilterChip(cat, label);
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Ideas list or favorites
              Expanded(
                child: _showFavorites
                    ? _buildFavorites()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredIdeas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _DateIdeaCard(
                          idea: _filteredIdeas[index],
                          pairId: widget.pairId,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddisAiSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddisDateAiSheet(),
    );
  }

  Widget _buildFilterChip(DateIdeaCategory? cat, String label) {
    final selected = _filter == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = cat),
      ),
    );
  }

  Widget _buildFavorites() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pairs')
          .doc(widget.pairId)
          .collection('savedDateIdeas')
          .snapshots(),
      builder: (context, snapshot) {
        final savedIds = (snapshot.data?.docs ?? [])
            .map((doc) => doc.id)
            .toSet();

        final favoriteIdeas = DateIdeasPool.ideas
            .where((idea) => savedIds.contains(idea.id))
            .toList();

        if (favoriteIdeas.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No favorites yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the heart on any idea to save it!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteIdeas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _DateIdeaCard(idea: favoriteIdeas[index], pairId: widget.pairId),
        );
      },
    );
  }
}

class _DateIdeaCard extends StatelessWidget {
  final DateIdea idea;
  final String pairId;
  final bool highlighted;

  const _DateIdeaCard({
    required this.idea,
    required this.pairId,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: highlighted ? AppGradients.accent : null,
        color: highlighted
            ? null
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(idea.categoryEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idea.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: highlighted ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  idea.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: highlighted
                        ? Colors.white.withValues(alpha: 0.85)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          _FavoriteButton(ideaId: idea.id, pairId: pairId),
        ],
      ),
    );
  }
}

class _AddisAiButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddisAiButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Find Addis Ababa date ideas with Gemini',
      child: SizedBox(
        height: 52,
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Addis AI'),
        ),
      ),
    );
  }
}

class _AddisDateAiSheet extends StatefulWidget {
  const _AddisDateAiSheet();

  @override
  State<_AddisDateAiSheet> createState() => _AddisDateAiSheetState();
}

class _AddisDateAiSheetState extends State<_AddisDateAiSheet> {
  final TextEditingController _promptController = TextEditingController(
    text: 'weekend, affordable, quiet',
  );
  final _client = _GeminiDateIdeasClient();

  _AddisDateIdeasResult? _result;
  String? _error;
  var _loading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Addis date scout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            decoration: const InputDecoration(
              hintText: 'Mood, budget, day, vibe...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            minLines: 1,
            maxLines: 2,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _search,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore_rounded),
              label: Text(_loading ? 'Searching Addis...' : 'Find & rate'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _AddisAiError(message: _error!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _AddisAiResultView(result: _result!),
          ],
        ],
      ),
    );
  }

  Future<void> _search() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _client.findDateIdeas(prompt);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _AddisAiError extends StatelessWidget {
  final String message;

  const _AddisAiError({required this.message});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

class _AddisAiResultView extends StatelessWidget {
  final _AddisDateIdeasResult result;

  const _AddisAiResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final idea in result.ideas) _AddisIdeaTile(idea: idea),
        if (result.sources.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Sources', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final source in result.sources.take(4))
                ActionChip(
                  avatar: const Icon(Icons.public_rounded, size: 16),
                  label: Text(source.title, overflow: TextOverflow.ellipsis),
                  onPressed: source.uri.isEmpty
                      ? null
                      : () => _openExternalUrl(source.uri),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AddisIdeaTile extends StatelessWidget {
  final _AddisDateIdea idea;

  const _AddisIdeaTile({required this.idea});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: idea.sourceUrl.isEmpty
            ? null
            : () => _openExternalUrl(idea.sourceUrl),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      idea.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _RatingPill(score: idea.rating),
                ],
              ),
              const SizedBox(height: 6),
              Text(idea.summary),
              if (idea.location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_rounded, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(idea.location)),
                  ],
                ),
              ],
              if (idea.bestFor.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  idea.bestFor,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (idea.sourceUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.open_in_new_rounded, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        idea.sourceTitle.isEmpty
                            ? 'Open reference'
                            : idea.sourceTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _RatingPill extends StatelessWidget {
  final int score;

  const _RatingPill({required this.score});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          '$score/10',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GeminiDateIdeasClient {
  static const _model = 'gemini-2.5-flash';

  Future<_AddisDateIdeasResult> findDateIdeas(String userPrompt) async {
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
              {'text': _promptFor(userPrompt)},
            ],
          },
        ],
        'tools': [
          {'google_search': <String, Object?>{}},
        ],
        'generationConfig': {'temperature': 0.35},
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
      throw Exception('Gemini returned no date ideas.');
    }

    final parsed = _decodeJsonObject(text);
    final sources = _sourcesFrom(candidate);
    return _AddisDateIdeasResult.fromJson(parsed, sources);
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
      throw Exception('Gemini returned an unreadable response.');
    }
    return jsonDecode(withoutFence.substring(start, end + 1))
        as Map<String, dynamic>;
  }

  String _promptFor(String userPrompt) {
    final now = DateTime.now();
    final monthYear = '${_monthName(now.month)} ${now.year}';

    return '''
You are a local Addis Ababa date-night scout. Use Google Search with queries dated to $monthYear to find CURRENT, REAL date ideas or events happening NOW in Addis Ababa, Ethiopia.

User vibe: $userPrompt

## Search Strategy
1. Search for: "Addis Ababa events $monthYear", "things to do Addis Ababa this week", "best date spots Addis Ababa ${now.year}"
2. Search for: "Addis Ababa $userPrompt ${now.year}"
3. Prioritize results from the last 90 days. Discard anything older than 12 months unless it is a permanent venue still operating.
4. Cross-reference: if a venue/event appears in multiple recent sources, rank it higher.

## Strict Rules
- ADDIS ABABA ONLY. Reject anything outside the city.
- ONLY include places/events you found via search with evidence they currently exist and operate. Never invent or hallucinate venues.
- Prefer: ongoing exhibitions, new restaurant openings, weekly live music nights, seasonal markets, recently reviewed cafes, active cultural centers, parks with recent visitor reviews.
- If a place has a Google Maps listing, Instagram, or recent TripAdvisor/Google review (within 6 months), it is more trustworthy.
- Rate each idea 1-10 for couple date quality: safety, romantic atmosphere, uniqueness, affordability, and how easy it is to get there.
- Do NOT invent prices, hours, or phone numbers unless the search source explicitly states them.
- Every idea MUST include the actual URL you found it from. Use the real source page — not a made-up link.
- If you cannot find 3 verified ideas, return fewer rather than fabricating.

## Response Format
Return ONLY valid JSON (no markdown, no explanation):
{
  "ideas": [
    {
      "title": "short descriptive title",
      "location": "specific neighborhood or landmark in Addis Ababa",
      "rating": 8,
      "summary": "2-3 sentences on why this is a great date and what to expect",
      "bestFor": "e.g. budget-friendly weekend afternoon / romantic evening / adventurous couples",
      "sourceTitle": "title of the webpage you found this from",
      "sourceUrl": "https://actual-source-url.com"
    }
  ]
}
Return 5 ideas maximum. Quality over quantity.
''';
  }

  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }

  List<_AddisDateIdeaSource> _sourcesFrom(Map<String, dynamic>? candidate) {
    final metadata = candidate?['groundingMetadata'] as Map<String, dynamic>?;
    final chunks = metadata?['groundingChunks'] as List?;
    if (chunks == null) return const [];

    return chunks
        .whereType<Map<String, dynamic>>()
        .map((chunk) => chunk['web'])
        .whereType<Map<String, dynamic>>()
        .map(_AddisDateIdeaSource.fromJson)
        .where((source) => source.title.isNotEmpty)
        .toList();
  }
}

class _AddisDateIdeasResult {
  final List<_AddisDateIdea> ideas;
  final List<_AddisDateIdeaSource> sources;

  const _AddisDateIdeasResult({required this.ideas, required this.sources});

  factory _AddisDateIdeasResult.fromJson(
    Map<String, dynamic> json,
    List<_AddisDateIdeaSource> sources,
  ) {
    final rawIdeas = ((json['ideas'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final ideas = [
      for (var index = 0; index < rawIdeas.length; index++)
        _AddisDateIdea.fromJson(
          rawIdeas[index],
          fallbackSource: sources.isEmpty
              ? null
              : sources[index.clamp(0, sources.length - 1)],
        ),
    ];
    if (ideas.isEmpty) {
      throw Exception('No Addis Ababa ideas found. Try a different vibe.');
    }
    return _AddisDateIdeasResult(ideas: ideas, sources: sources);
  }
}

class _AddisDateIdea {
  final String title;
  final String location;
  final int rating;
  final String summary;
  final String bestFor;
  final String sourceTitle;
  final String sourceUrl;

  const _AddisDateIdea({
    required this.title,
    required this.location,
    required this.rating,
    required this.summary,
    required this.bestFor,
    required this.sourceTitle,
    required this.sourceUrl,
  });

  factory _AddisDateIdea.fromJson(
    Map<String, dynamic> json, {
    _AddisDateIdeaSource? fallbackSource,
  }) {
    final rating = json['rating'];
    final sourceTitle = json['sourceTitle'] as String?;
    final sourceUrl = json['sourceUrl'] as String?;
    return _AddisDateIdea(
      title: json['title'] as String? ?? 'Addis date idea',
      location: json['location'] as String? ?? '',
      rating: rating is num ? rating.round().clamp(1, 10) : 7,
      summary: json['summary'] as String? ?? '',
      bestFor: json['bestFor'] as String? ?? '',
      sourceTitle: sourceTitle?.isNotEmpty == true
          ? sourceTitle!
          : fallbackSource?.title ?? '',
      sourceUrl: sourceUrl?.isNotEmpty == true
          ? sourceUrl!
          : fallbackSource?.uri ?? '',
    );
  }
}

class _AddisDateIdeaSource {
  final String title;
  final String uri;

  const _AddisDateIdeaSource({required this.title, required this.uri});

  factory _AddisDateIdeaSource.fromJson(Map<String, dynamic> json) {
    return _AddisDateIdeaSource(
      title: json['title'] as String? ?? '',
      uri: json['uri'] as String? ?? '',
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String ideaId;
  final String pairId;

  const _FavoriteButton({required this.ideaId, required this.pairId});

  DocumentReference get _ref => FirebaseFirestore.instance
      .collection('pairs')
      .doc(pairId)
      .collection('savedDateIdeas')
      .doc(ideaId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _ref.snapshots(),
      builder: (context, snapshot) {
        final isSaved = snapshot.data?.exists ?? false;

        return IconButton(
          icon: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isSaved ? Colors.red : Colors.grey,
          ),
          onPressed: () async {
            if (isSaved) {
              await _ref.delete();
            } else {
              await _ref.set({'savedAt': FieldValue.serverTimestamp()});
            }
          },
        );
      },
    );
  }
}
