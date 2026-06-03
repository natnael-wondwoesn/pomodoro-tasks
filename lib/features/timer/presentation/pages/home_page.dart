import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/widgets/task_list_widget.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/widgets/partner_panel.dart';
import 'package:pomodoro_tasks/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:pomodoro_tasks/features/timer/presentation/widgets/timer_circle.dart';
import 'package:pomodoro_tasks/features/timer/presentation/widgets/timer_controls.dart';

class HomePage extends StatelessWidget {
  final String pairId;
  final String partnerName;

  const HomePage({super.key, required this.pairId, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, taskState) {
          final tasks = taskState is TasksLoaded
              ? taskState.tasks
              : const <TaskEntity>[];
          final openTasks = tasks
              .where((task) => task.status != TaskStatus.done)
              .toList();
          final currentTask = openTasks
              .where((task) => task.status == TaskStatus.inProgress)
              .cast<TaskEntity?>()
              .firstOrNull;
          final nextTask =
              currentTask ?? (openTasks.isEmpty ? null : openTasks.first);
          final completedCount = tasks
              .where((task) => task.status == TaskStatus.done)
              .length;
          final totalPomodoros = tasks.fold<int>(
            0,
            (total, task) => total + task.estimatedPomodoros,
          );
          final completedPomodoros = tasks.fold<int>(
            0,
            (total, task) => total + task.completedPomodoros,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final content = isWide
                  ? _WideDashboard(
                      pairId: pairId,
                      partnerName: partnerName,
                      tasks: tasks,
                      nextTask: nextTask,
                      completedCount: completedCount,
                      completedPomodoros: completedPomodoros,
                      totalPomodoros: totalPomodoros,
                    )
                  : _CompactDashboard(
                      pairId: pairId,
                      partnerName: partnerName,
                      tasks: tasks,
                      nextTask: nextTask,
                      completedCount: completedCount,
                      completedPomodoros: completedPomodoros,
                      totalPomodoros: totalPomodoros,
                    );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: content,
              );
            },
          );
        },
      ),
    );
  }
}

class _CompactDashboard extends StatelessWidget {
  final String pairId;
  final String partnerName;
  final List<TaskEntity> tasks;
  final TaskEntity? nextTask;
  final int completedCount;
  final int completedPomodoros;
  final int totalPomodoros;

  const _CompactDashboard({
    required this.pairId,
    required this.partnerName,
    required this.tasks,
    required this.nextTask,
    required this.completedCount,
    required this.completedPomodoros,
    required this.totalPomodoros,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeHeader(tasks: tasks),
        const SizedBox(height: 14),
        _FocusPanel(nextTask: nextTask),
        const SizedBox(height: 14),
        _ProgressStrip(
          completedCount: completedCount,
          totalCount: tasks.length,
          completedPomodoros: completedPomodoros,
          totalPomodoros: totalPomodoros,
        ),
        const SizedBox(height: 14),
        _NextTasksPanel(pairId: pairId),
        const SizedBox(height: 14),
        PartnerPanel(partnerName: partnerName),
      ],
    );
  }
}

class _WideDashboard extends StatelessWidget {
  final String pairId;
  final String partnerName;
  final List<TaskEntity> tasks;
  final TaskEntity? nextTask;
  final int completedCount;
  final int completedPomodoros;
  final int totalPomodoros;

  const _WideDashboard({
    required this.pairId,
    required this.partnerName,
    required this.tasks,
    required this.nextTask,
    required this.completedCount,
    required this.completedPomodoros,
    required this.totalPomodoros,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeHeader(tasks: tasks),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _FocusPanel(nextTask: nextTask),
                  const SizedBox(height: 14),
                  _ProgressStrip(
                    completedCount: completedCount,
                    totalCount: tasks.length,
                    completedPomodoros: completedPomodoros,
                    totalPomodoros: totalPomodoros,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _NextTasksPanel(pairId: pairId),
                  const SizedBox(height: 14),
                  PartnerPanel(partnerName: partnerName),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final List<TaskEntity> tasks;

  const _HomeHeader({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final remaining = tasks
        .where((task) => task.status != TaskStatus.done)
        .length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                remaining == 0
                    ? 'Clear day. Choose the next meaningful goal.'
                    : '$remaining task${remaining == 1 ? '' : 's'} left to move forward.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _StatusPill(
          icon: Icons.task_alt_rounded,
          label: '${tasks.length}',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _FocusPanel extends StatelessWidget {
  final TaskEntity? nextTask;

  const _FocusPanel({required this.nextTask});

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Focus',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _StatusPill(
                icon: Icons.bolt_rounded,
                label: nextTask == null ? 'Ready' : 'Next',
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          BlocBuilder<TimerBloc, TimerBlocState>(
            builder: (context, state) {
              return TimerCircle(timerState: state.timerState);
            },
          ),
          const SizedBox(height: 12),
          const TimerControls(),
          const SizedBox(height: 14),
          _CurrentTaskStrip(task: nextTask),
        ],
      ),
    );
  }
}

class _CurrentTaskStrip extends StatelessWidget {
  final TaskEntity? task;

  const _CurrentTaskStrip({required this.task});

  @override
  Widget build(BuildContext context) {
    final color = task == null
        ? Theme.of(context).disabledColor
        : Theme.of(context).colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.flag_rounded, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task?.title ?? 'No focus task selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task == null
                        ? 'Add or start a task from the Tasks tab.'
                        : '${task!.completedPomodoros}/${task!.estimatedPomodoros} pomodoros',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int completedPomodoros;
  final int totalPomodoros;

  const _ProgressStrip({
    required this.completedCount,
    required this.totalCount,
    required this.completedPomodoros,
    required this.totalPomodoros,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.check_circle_rounded,
            label: 'Tasks',
            value: '$completedCount/$totalCount',
            color: AppColors.partnerLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.timer_rounded,
            label: 'Pomodoros',
            value: '$completedPomodoros/$totalPomodoros',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _NextTasksPanel extends StatelessWidget {
  final String pairId;

  const _NextTasksPanel({required this.pairId});

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next up',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
          const SizedBox(height: 10),
          TaskListWidget(pairId: pairId, compact: true),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final Widget child;

  const _DashboardPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
