import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/services/streak_service.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final String pairId;
  final String userId;
  final String? partnerId;

  const StreakCard({
    super.key,
    required this.pairId,
    required this.userId,
    this.partnerId,
  });

  @override
  Widget build(BuildContext context) {
    if (pairId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<AllStreaks>(
      stream: StreakService.instance.watchStreaks(
        pairId: pairId,
        userId: userId,
        partnerId: partnerId,
      ),
      builder: (context, snapshot) {
        final streaks = snapshot.data ?? const AllStreaks();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _StreakTile(
                  emoji: '\u{1F525}',
                  label: 'My Streak',
                  current: streaks.myStreak.current,
                  best: streaks.myStreak.best,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _StreakTile(
                  emoji: '\u2764\uFE0F',
                  label: 'Together',
                  current: streaks.coupleStreak.current,
                  best: streaks.coupleStreak.best,
                  color: AppColors.partnerLight,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _StreakTile(
                  emoji: '\u{1F331}',
                  label: 'Partner',
                  current: streaks.partnerStreak.current,
                  best: streaks.partnerStreak.best,
                  color: AppColors.partnerLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StreakTile extends StatelessWidget {
  final String emoji;
  final String label;
  final int current;
  final int best;
  final Color color;

  const _StreakTile({
    required this.emoji,
    required this.label,
    required this.current,
    required this.best,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$emoji $current',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (best > 0)
          Text(
            'best: $best',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.6),
                ),
          ),
      ],
    );
  }
}
