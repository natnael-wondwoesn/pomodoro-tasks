import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

class PartnerPanel extends StatelessWidget {
  final String partnerName;

  const PartnerPanel({super.key, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, TimelineState>(
      builder: (context, state) {
        if (state is! TimelineLoaded) {
          return Center(
            child: Text(
              'Connecting...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final session = state.partnerSession;
        final tasks = state.partnerTasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner status
            Text(
              "${partnerName.toUpperCase()}'S DAY",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),

            // Current status card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: session != null
                    ? AppColors.partnerLight.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: session != null
                    ? Border.all(color: AppColors.partnerLight.withValues(alpha: 0.3))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: session != null ? AppColors.partnerLight : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session != null ? _getStatusText(session.type) : 'Idle',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.partnerLight,
                              ),
                        ),
                        if (session != null)
                          Text(
                            _getRemainingText(session),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Partner tasks
            if (tasks.isNotEmpty) ...[
              Text(
                'UPCOMING',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ...tasks
                  .where((t) => t.status != TaskStatus.done)
                  .take(4)
                  .map((task) => _buildPartnerTask(context, task)),
            ],

            if (tasks.where((t) => t.status == TaskStatus.done).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'COMPLETED TODAY',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ...tasks
                  .where((t) => t.status == TaskStatus.done)
                  .take(3)
                  .map((task) => _buildPartnerTask(context, task)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPartnerTask(BuildContext context, TaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            task.status == TaskStatus.done
                ? Icons.check_circle_outline
                : Icons.circle_outlined,
            size: 14,
            color: AppColors.partnerLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Focusing';
      case SessionType.shortBreak:
        return 'Short break';
      case SessionType.longBreak:
        return 'Long break';
    }
  }

  String _getRemainingText(dynamic session) {
    final elapsed = DateTime.now().difference(session.startedAt as DateTime);
    final remaining = (session.duration as Duration) - elapsed;
    if (remaining.isNegative) return 'Finishing up...';
    return '${remaining.inMinutes} min left';
  }
}
