import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/data/date_ideas_pool.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('Date Ideas',
                        style: Theme.of(context).textTheme.headlineMedium),
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
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
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
                    icon: const Icon(Icons.shuffle_rounded,
                        color: Colors.white),
                    label: const Text('Random Date Idea!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
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
                          DateIdeaCategory.adventure => '\u{1F3D4}\uFE0F Adventure',
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
                Icon(Icons.favorite_border_rounded,
                    size: 48,
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Tap the heart on any idea to save it!',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteIdeas.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _DateIdeaCard(
            idea: favoriteIdeas[index],
            pairId: widget.pairId,
          ),
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
                Text(idea.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: highlighted ? Colors.white : null,
                        )),
                const SizedBox(height: 4),
                Text(idea.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: highlighted
                              ? Colors.white.withValues(alpha: 0.85)
                              : null,
                        )),
              ],
            ),
          ),
          _FavoriteButton(ideaId: idea.id, pairId: pairId),
        ],
      ),
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
