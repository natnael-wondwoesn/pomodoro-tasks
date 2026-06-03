import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/core/notifications/notification_service.dart';
import 'package:pomodoro_tasks/features/roadmap/data/models/roadmap_goal_model.dart';
import 'package:pomodoro_tasks/features/roadmap/domain/entities/roadmap_goal.dart';

class RoadmapPage extends StatefulWidget {
  final String pairId;
  final String userId;
  final String? partnerId;

  const RoadmapPage({
    super.key,
    required this.pairId,
    required this.userId,
    this.partnerId,
  });

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  _RoadmapKind? _selectedKind;

  static const double _mapWidth = 620;
  static const double _minMapHeight = 1280;

  @override
  Widget build(BuildContext context) {
    if (_selectedKind == null) {
      return _RoadmapSelectorPage(
        hasPartner: widget.partnerId != null,
        onSelected: (kind) => setState(() => _selectedKind = kind),
      );
    }

    final selectedKind = _selectedKind!;
    final config = _RoadmapConfig.fromKind(
      selectedKind,
      userId: widget.userId,
      partnerId: widget.partnerId,
      pairId: widget.pairId,
    );

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<RoadmapGoal>>(
        stream: _watchRoadmapGoals(config.roadmapId),
        builder: (context, snapshot) {
          final levels = _buildLevels(snapshot.data ?? const <RoadmapGoal>[]);
          final mapHeight = _mapHeightFor(levels.length);
          final completedCount = levels
              .where((level) => level.status == _RoadmapStatus.done)
              .length;
          final totalPomodoros = levels.fold<int>(
            0,
            (total, level) => total + level.estimatedPomodoros,
          );
          final completedPomodoros = levels.fold<int>(
            0,
            (total, level) =>
                total +
                level.completedPomodoros.clamp(0, level.estimatedPomodoros),
          );

          return SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _RoadmapHeader(
                    title: config.title,
                    completedCount: completedCount,
                    totalCount: levels.length,
                    completedPomodoros: completedPomodoros,
                    totalPomodoros: totalPomodoros,
                    onBack: () => setState(() => _selectedKind = null),
                  ),
                ),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _RoadmapErrorBanner(error: snapshot.error),
                  ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          if (levels.isEmpty)
                            _RoadmapEmptyState(config: config)
                          else
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(bottom: 116),
                              child: GameLevelsScrollingMap(
                                key: ValueKey(_levelsSignature(levels)),
                                width: constraints.maxWidth,
                                imageWidth: _mapWidth,
                                imageHeight: mapHeight,
                                pointsPositionDeltaY: 8,
                                currentPointDeltaY: 16,
                                backgroundImageWidget: _RoadmapMapBackground(
                                  levels: levels,
                                  width: _mapWidth,
                                  height: mapHeight,
                                ),
                                x_values: levels
                                    .map((level) => level.x)
                                    .toList(),
                                y_values: levels
                                    .map((level) => level.y)
                                    .toList(),
                                points: levels
                                    .map(
                                      (level) => PointModel(
                                        76,
                                        _RoadmapNode(
                                          level: level,
                                          onTap: () =>
                                              _showGoalActions(context, level),
                                        ),
                                        isCurrent:
                                            level.status ==
                                            _RoadmapStatus.current,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          if (levels.isNotEmpty)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 14,
                              child: _CurrentGoalBar(levels: levels),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: widget.pairId.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: FloatingActionButton.extended(
                onPressed: () => _showAddGoalSheet(context, config),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Goal'),
              ),
            ),
    );
  }

  Stream<List<RoadmapGoal>> _watchRoadmapGoals(String roadmapId) {
    if (widget.pairId.isEmpty) return Stream.value(const <RoadmapGoal>[]);

    return _goalsRef(widget.pairId, roadmapId).snapshots().asyncMap((
      snapshot,
    ) async {
      final goals = snapshot.docs
          .map((doc) => RoadmapGoalModel.fromFirestore(doc))
          .toList();
      if (roadmapId == 'his' || roadmapId == 'hers') {
        for (final goal in goals) {
          await NotificationService.instance.scheduleRoadmapDeadline(
            pairId: widget.pairId,
            roadmapId: roadmapId,
            goal: goal,
          );
        }
      }
      return goals;
    });
  }

  CollectionReference _goalsRef(String pairId, String roadmapId) {
    return FirebaseFirestore.instance
        .collection(AppConstants.pairsCollection)
        .doc(pairId)
        .collection('roadmaps')
        .doc(roadmapId)
        .collection('goals');
  }

  List<_RoadmapLevel> _buildLevels(List<RoadmapGoal> goals) {
    final sortedGoals = [...goals]
      ..sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.createdAt.compareTo(b.createdAt);
      });

    final mapHeight = _mapHeightFor(sortedGoals.length);
    var currentAssigned = false;

    return List.generate(sortedGoals.length, (index) {
      final goal = sortedGoals[index];
      final status = _statusFor(goal, currentAssigned);

      if (status == _RoadmapStatus.current) {
        currentAssigned = true;
      }

      final position = _positionFor(index, mapHeight);
      return _RoadmapLevel(
        id: goal.id,
        roadmapId: _selectedKind!.name,
        number: index + 1,
        title: goal.title,
        description: goal.description,
        completedPomodoros: goal.completedPomodoros,
        estimatedPomodoros: math.max(1, goal.estimatedPomodoros),
        deadlineAt: goal.deadlineAt,
        status: status,
        x: position.dx,
        y: position.dy,
      );
    });
  }

  String _levelsSignature(List<_RoadmapLevel> levels) {
    return levels
        .map(
          (level) =>
              '${level.id}:${level.status.name}:${level.completedPomodoros}',
        )
        .join('|');
  }

  double _mapHeightFor(int levelCount) {
    return math.max(_minMapHeight, 240 + math.max(0, levelCount - 1) * 185);
  }

  _RoadmapStatus _statusFor(RoadmapGoal goal, bool currentAssigned) {
    if (goal.status == RoadmapGoalStatus.done ||
        goal.status == RoadmapGoalStatus.skipped) {
      return _RoadmapStatus.done;
    }
    if (currentAssigned) return _RoadmapStatus.locked;
    return _RoadmapStatus.current;
  }

  Offset _positionFor(int index, double mapHeight) {
    const startY = 110.0;
    const spacing = 185.0;
    final y = startY + (index * spacing);
    final wave = math.sin(index * 1.35) * 185;
    final laneOffset = switch (index % 4) {
      0 => -38.0,
      1 => 42.0,
      2 => 18.0,
      _ => -54.0,
    };
    final x = (_mapWidth / 2) + wave + laneOffset;
    return Offset(x.clamp(92, _mapWidth - 92), y.clamp(96, mapHeight - 116));
  }

  void _showAddGoalSheet(BuildContext context, _RoadmapConfig config) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxHeight: 380),
      builder: (sheetContext) {
        return _AddRoadmapGoalSheet(pairId: widget.pairId, config: config);
      },
    );
  }

  Future<void> _showGoalActions(BuildContext context, _RoadmapLevel level) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(level.title),
          content: Text(_goalActionMessage(level)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            if (level.status == _RoadmapStatus.current) ...[
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _completeGoal(context, level, skipped: true);
                },
                child: const Text('Skip'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _completeGoal(context, level);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
              ),
            ],
          ],
        );
      },
    );
  }

  String _goalActionMessage(_RoadmapLevel level) {
    return switch (level.status) {
      _RoadmapStatus.done => 'This goal is already complete.',
      _RoadmapStatus.locked =>
        'Finish or skip the current goal to unlock this one.',
      _RoadmapStatus.current =>
        'Mark this goal done or skip it to unlock the next goal.',
    };
  }

  Future<void> _completeGoal(
    BuildContext context,
    _RoadmapLevel level, {
    bool skipped = false,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.pairsCollection)
          .doc(widget.pairId)
          .collection('roadmaps')
          .doc(level.roadmapId)
          .collection('goals')
          .doc(level.id)
          .update({
            'status': skipped
                ? RoadmapGoalStatus.skipped.name
                : RoadmapGoalStatus.done.name,
            'completedPomodoros': skipped ? 0 : level.estimatedPomodoros,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
      await NotificationService.instance.scheduleRoadmapDeadline(
        pairId: widget.pairId,
        roadmapId: level.roadmapId,
        goal: RoadmapGoal(
          id: level.id,
          title: level.title,
          description: level.description,
          estimatedPomodoros: level.estimatedPomodoros,
          completedPomodoros: skipped ? 0 : level.estimatedPomodoros,
          status: skipped ? RoadmapGoalStatus.skipped : RoadmapGoalStatus.done,
          createdBy: widget.userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deadlineAt: level.deadlineAt,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update roadmap goal: $error')),
      );
    }
  }
}

class _AddRoadmapGoalSheet extends StatefulWidget {
  final String pairId;
  final _RoadmapConfig config;

  const _AddRoadmapGoalSheet({required this.pairId, required this.config});

  @override
  State<_AddRoadmapGoalSheet> createState() => _AddRoadmapGoalSheetState();
}

class _AddRoadmapGoalSheetState extends State<_AddRoadmapGoalSheet> {
  final TextEditingController _titleController = TextEditingController();
  var _pomodoros = 1;
  var _isSaving = false;
  DateTime? _deadlineAt;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New ${widget.config.title.toLowerCase()} goal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Goal title'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Pomodoros', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: _pomodoros > 1
                    ? () => setState(() => _pomodoros--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text(
                '$_pomodoros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: _pomodoros < 12
                    ? () => setState(() => _pomodoros++)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickDeadline,
            icon: const Icon(Icons.event_rounded),
            label: Text(
              _deadlineAt == null
                  ? 'Add deadline'
                  : DateFormat('MMM d, h:mm a').format(_deadlineAt!),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _addGoal,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.flag_rounded),
              label: Text(_isSaving ? 'Adding...' : 'Add to roadmap'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final firestore = FirebaseFirestore.instance;
      final roadmapRef = firestore
          .collection(AppConstants.pairsCollection)
          .doc(widget.pairId)
          .collection('roadmaps')
          .doc(widget.config.roadmapId);
      final goalRef = roadmapRef.collection('goals').doc();
      final batch = firestore.batch();

      batch.set(roadmapRef, {
        'type': widget.config.roadmapId,
        'pairId': widget.pairId,
        'ownerId': widget.config.ownerId,
        'updatedAt': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
      final goal = RoadmapGoalModel(
        id: goalRef.id,
        title: title,
        createdBy: widget.config.createdBy,
        createdAt: now,
        updatedAt: now,
        deadlineAt: _deadlineAt,
        estimatedPomodoros: _pomodoros,
        order: now.millisecondsSinceEpoch,
      );
      batch.set(goalRef, goal.toFirestore());
      await batch.commit();
      await NotificationService.instance.scheduleRoadmapDeadline(
        pairId: widget.pairId,
        roadmapId: widget.config.roadmapId,
        goal: goal,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add roadmap goal: $error')),
      );
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadlineAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _deadlineAt == null
          ? TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)))
          : TimeOfDay.fromDateTime(_deadlineAt!),
    );
    if (selectedTime == null || !mounted) return;

    setState(() {
      _deadlineAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }
}

enum _RoadmapKind { his, hers, ours }

class _RoadmapConfig {
  final _RoadmapKind kind;
  final String roadmapId;
  final String title;
  final String subtitle;
  final IconData icon;
  final String? ownerId;
  final String createdBy;

  const _RoadmapConfig({
    required this.kind,
    required this.roadmapId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.ownerId,
    required this.createdBy,
  });

  factory _RoadmapConfig.fromKind(
    _RoadmapKind kind, {
    required String userId,
    required String? partnerId,
    required String pairId,
  }) {
    return switch (kind) {
      _RoadmapKind.his => _RoadmapConfig(
        kind: kind,
        roadmapId: 'his',
        title: 'His roadmap',
        subtitle: 'Partner goals and progress',
        icon: Icons.person_rounded,
        ownerId: partnerId,
        createdBy: userId,
      ),
      _RoadmapKind.hers => _RoadmapConfig(
        kind: kind,
        roadmapId: 'hers',
        title: 'Hers roadmap',
        subtitle: 'Your personal goals',
        icon: Icons.face_3_rounded,
        ownerId: userId,
        createdBy: userId,
      ),
      _RoadmapKind.ours => _RoadmapConfig(
        kind: kind,
        roadmapId: 'ours',
        title: 'Ours roadmap',
        subtitle: 'Long-term goals together',
        icon: Icons.favorite_rounded,
        ownerId: null,
        createdBy: userId,
      ),
    };
  }
}

class _RoadmapSelectorPage extends StatelessWidget {
  final bool hasPartner;
  final ValueChanged<_RoadmapKind> onSelected;

  const _RoadmapSelectorPage({
    required this.hasPartner,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final configs = [
      _RoadmapSelectorConfig(
        kind: _RoadmapKind.his,
        title: 'His',
        subtitle: hasPartner
            ? 'Partner goals and progress'
            : 'Pair first to view partner goals',
        icon: Icons.person_rounded,
        enabled: hasPartner,
      ),
      const _RoadmapSelectorConfig(
        kind: _RoadmapKind.hers,
        title: 'Hers',
        subtitle: 'Your personal goals',
        icon: Icons.face_3_rounded,
        enabled: true,
      ),
      const _RoadmapSelectorConfig(
        kind: _RoadmapKind.ours,
        title: 'Ours',
        subtitle: 'Long-term goals together',
        icon: Icons.favorite_rounded,
        enabled: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roadmaps',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Choose which path to open.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: configs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final config = configs[index];
                    return _RoadmapSelectorTile(
                      config: config,
                      onTap: config.enabled
                          ? () => onSelected(config.kind)
                          : null,
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

class _RoadmapSelectorTile extends StatelessWidget {
  final _RoadmapSelectorConfig config;
  final VoidCallback? onTap;

  const _RoadmapSelectorTile({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return Material(
      color: colorScheme.surface.withValues(alpha: enabled ? 0.82 : 0.48),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(
                    alpha: enabled ? 0.18 : 0.08,
                  ),
                ),
                child: Icon(
                  config.icon,
                  color: enabled
                      ? colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_rounded,
                color: enabled
                    ? colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapSelectorConfig {
  final _RoadmapKind kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;

  const _RoadmapSelectorConfig({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
  });
}

class _RoadmapErrorBanner extends StatelessWidget {
  final Object? error;

  const _RoadmapErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Roadmap could not load: $error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapEmptyState extends StatelessWidget {
  final _RoadmapConfig config;

  const _RoadmapEmptyState({required this.config});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  config.icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No goals yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Add the first goal to start this roadmap.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapHeader extends StatelessWidget {
  final String title;
  final int completedCount;
  final int totalCount;
  final int completedPomodoros;
  final int totalPomodoros;
  final VoidCallback onBack;

  const _RoadmapHeader({
    required this.title,
    required this.completedCount,
    required this.totalCount,
    required this.completedPomodoros,
    required this.totalPomodoros,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            _StatPill(
              icon: Icons.local_fire_department_rounded,
              label: '$completedCount/$totalCount',
            ),
            const SizedBox(width: 8),
            _StatPill(
              icon: Icons.timer_rounded,
              label: '$completedPomodoros/$totalPomodoros',
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _RoadmapMapBackground extends StatelessWidget {
  final List<_RoadmapLevel> levels;
  final double width;
  final double height;

  const _RoadmapMapBackground({
    required this.levels,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return CustomPaint(
      size: Size(width, height),
      painter: _RoadmapPainter(
        levels: levels,
        sourceWidth: width,
        sourceHeight: height,
        isLight: isLight,
        primary: Theme.of(context).colorScheme.primary,
        surface: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

class _RoadmapPainter extends CustomPainter {
  final List<_RoadmapLevel> levels;
  final double sourceWidth;
  final double sourceHeight;
  final bool isLight;
  final Color primary;
  final Color surface;

  _RoadmapPainter({
    required this.levels,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.isLight,
    required this.primary,
    required this.surface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLight
            ? const [Color(0xFFFFF7E4), Color(0xFFE9F6ED), Color(0xFFFFE7F0)]
            : const [Color(0xFF24170D), Color(0xFF173023), Color(0xFF301925)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    _drawCandyField(canvas, size);
    _drawPath(canvas, size);
  }

  void _drawCandyField(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [
      Color(0xFFE86A92),
      Color(0xFF49A5D8),
      Color(0xFFFFC857),
      Color(0xFF74B86E),
    ];

    for (var i = 0; i < 36; i++) {
      final x = 38 + (i * 137) % size.width;
      final y = 42 + (i * 97) % size.height;
      paint.color = colors[i % colors.length].withValues(
        alpha: isLight ? 0.14 : 0.2,
      );
      canvas.drawCircle(Offset(x, y), 16 + (i % 4) * 4, paint);
    }
  }

  Offset _scaledPoint(_RoadmapLevel level, Size size) {
    return Offset(
      level.x * size.width / sourceWidth,
      level.y * size.height / sourceHeight,
    );
  }

  void _drawPath(Canvas canvas, Size size) {
    if (levels.length < 2) return;

    final first = _scaledPoint(levels.first, size);
    final path = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < levels.length; i++) {
      final previous = _scaledPoint(levels[i - 1], size);
      final current = _scaledPoint(levels[i], size);
      final midY = (previous.dy + current.dy) / 2;
      path.cubicTo(previous.dx, midY, current.dx, midY, current.dx, current.dy);
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isLight ? 0.08 : 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 44
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shadowPaint);

    final basePaint = Paint()
      ..color = surface.withValues(alpha: isLight ? 0.92 : 0.74)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, basePaint);

    final progressPath = Path()..moveTo(first.dx, first.dy);
    for (var i = 1; i < levels.length; i++) {
      if (levels[i - 1].status == _RoadmapStatus.locked) break;
      final previousPoint = _scaledPoint(levels[i - 1], size);
      final currentPoint = _scaledPoint(levels[i], size);
      final midY = (previousPoint.dy + currentPoint.dy) / 2;
      progressPath.cubicTo(
        previousPoint.dx,
        midY,
        currentPoint.dx,
        midY,
        currentPoint.dx,
        currentPoint.dy,
      );
      if (levels[i].status == _RoadmapStatus.current) break;
    }

    final progressPaint = Paint()
      ..color = primary.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RoadmapPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.isLight != isLight ||
        oldDelegate.primary != primary ||
        oldDelegate.surface != surface;
  }
}

class _RoadmapNode extends StatelessWidget {
  final _RoadmapLevel level;
  final VoidCallback onTap;

  const _RoadmapNode({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (level.status) {
      _RoadmapStatus.done => const Color(0xFF4A9F68),
      _RoadmapStatus.current => Theme.of(context).colorScheme.primary,
      _RoadmapStatus.locked => Theme.of(context).disabledColor,
    };
    final foreground = level.status == _RoadmapStatus.locked
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48)
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              switch (level.status) {
                _RoadmapStatus.done => Icons.check_rounded,
                _RoadmapStatus.current => Icons.flag_rounded,
                _RoadmapStatus.locked => Icons.lock_rounded,
              },
              color: foreground,
              size: 30,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 130,
            child: Text(
              level.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentGoalBar extends StatelessWidget {
  final List<_RoadmapLevel> levels;

  const _CurrentGoalBar({required this.levels});

  @override
  Widget build(BuildContext context) {
    final current = levels.firstWhere(
      (level) => level.status == _RoadmapStatus.current,
      orElse: () => levels.last,
    );
    final progress =
        current.completedPomodoros / math.max(1, current.estimatedPomodoros);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text('${current.number}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (current.description != null &&
                      current.description!.isNotEmpty)
                    Text(
                      current.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (current.deadlineAt != null)
                    Text(
                      'Due ${DateFormat('MMM d, h:mm a').format(current.deadlineAt!)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress.clamp(0, 1)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${current.completedPomodoros}/${current.estimatedPomodoros}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

enum _RoadmapStatus { done, current, locked }

class _RoadmapLevel {
  final String id;
  final String roadmapId;
  final int number;
  final String title;
  final String? description;
  final int completedPomodoros;
  final int estimatedPomodoros;
  final DateTime? deadlineAt;
  final _RoadmapStatus status;
  final double x;
  final double y;

  const _RoadmapLevel({
    required this.id,
    required this.roadmapId,
    required this.number,
    required this.title,
    required this.description,
    required this.completedPomodoros,
    required this.estimatedPomodoros,
    required this.deadlineAt,
    required this.status,
    required this.x,
    required this.y,
  });
}
