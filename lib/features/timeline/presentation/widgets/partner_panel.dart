import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/services/nudge_service.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

class PartnerPanel extends StatefulWidget {
  final String partnerName;
  final String? pairId;
  final String? userId;
  final String? partnerId;

  const PartnerPanel({
    super.key,
    required this.partnerName,
    this.pairId,
    this.userId,
    this.partnerId,
  });

  @override
  State<PartnerPanel> createState() => _PartnerPanelState();
}

class _PartnerPanelState extends State<PartnerPanel> {
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
            // Partner header with nudge button
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${widget.partnerName.toUpperCase()}'S DAY",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (widget.pairId != null &&
                    widget.userId != null &&
                    widget.partnerId != null)
                  _NudgeButton(
                    pairId: widget.pairId!,
                    userId: widget.userId!,
                    partnerId: widget.partnerId!,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Current status card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: session != null
                    ? AppColors.partnerLight.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(10),
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

class _NudgeButton extends StatefulWidget {
  final String pairId;
  final String userId;
  final String partnerId;

  const _NudgeButton({
    required this.pairId,
    required this.userId,
    required this.partnerId,
  });

  @override
  State<_NudgeButton> createState() => _NudgeButtonState();
}

class _NudgeButtonState extends State<_NudgeButton> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final canSend = NudgeService.instance.canSendNudge && !_sending;
    final cooldown = NudgeService.instance.cooldownRemainingMinutes;

    return Tooltip(
      message: canSend ? 'Send a nudge!' : 'Wait ${cooldown}m',
      child: Container(
        decoration: BoxDecoration(
          gradient: canSend ? AppGradients.partner : null,
          color: canSend ? null : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: canSend ? _sendNudge : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: 16,
                  color: canSend ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nudge',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: canSend ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendNudge() async {
    setState(() => _sending = true);
    try {
      await NudgeService.instance.sendNudge(
        pairId: widget.pairId,
        fromUserId: widget.userId,
        targetUserId: widget.partnerId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nudge sent!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
