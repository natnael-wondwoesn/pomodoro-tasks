import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/bloc/tasks_bloc.dart';

class TaskListWidget extends StatelessWidget {
  final String pairId;
  final bool compact;

  const TaskListWidget({super.key, required this.pairId, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        if (state is! TasksLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = state.tasks;
        if (tasks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 34,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add one clear next step.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        if (compact) {
          return _buildCompactList(context, tasks);
        }

        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            context.read<TasksBloc>().add(
              TaskReorderRequested(
                pairId: pairId,
                oldIndex: oldIndex,
                newIndex: newIndex,
              ),
            );
          },
          itemBuilder: (context, index) {
            return _buildTaskTile(context, tasks[index]);
          },
        );
      },
    );
  }

  Widget _buildCompactList(BuildContext context, List<TaskEntity> tasks) {
    final displayTasks = [...tasks]
      ..sort((a, b) {
        final statusCompare = _statusRank(
          a.status,
        ).compareTo(_statusRank(b.status));
        if (statusCompare != 0) return statusCompare;
        return a.order.compareTo(b.order);
      });
    final openTasks = displayTasks
        .where((task) => task.status != TaskStatus.done)
        .take(4)
        .toList();
    final visibleTasks = openTasks.isEmpty
        ? displayTasks.take(3).toList()
        : openTasks;

    return Column(
      children: visibleTasks
          .map((task) => _buildCompactTile(context, task))
          .toList(),
    );
  }

  int _statusRank(TaskStatus status) {
    return switch (status) {
      TaskStatus.inProgress => 0,
      TaskStatus.todo => 1,
      TaskStatus.done => 2,
    };
  }

  Widget _buildCompactTile(BuildContext context, TaskEntity task) {
    final isActive = task.status == TaskStatus.inProgress;
    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
            : Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            task.status == TaskStatus.done
                ? Icons.check_circle
                : task.status == TaskStatus.inProgress
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 16,
            color: task.status == TaskStatus.done
                ? AppColors.partnerLight
                : Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: task.status == TaskStatus.done
                    ? TextDecoration.lineThrough
                    : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (task.estimatedPomodoros > 0)
            Text(
              '${task.completedPomodoros}/${task.estimatedPomodoros}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskEntity task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.withValues(alpha: 0.1),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) {
        context.read<TasksBloc>().add(
          TaskDeleteRequested(pairId: pairId, taskId: task.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: task.status == TaskStatus.inProgress
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                final newStatus = task.status == TaskStatus.done
                    ? TaskStatus.todo
                    : TaskStatus.done;
                context.read<TasksBloc>().add(
                  TaskUpdateRequested(
                    pairId: pairId,
                    task: task.copyWith(status: newStatus),
                  ),
                );
              },
              child: Icon(
                task.status == TaskStatus.done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.status == TaskStatus.done
                    ? AppColors.partnerLight
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: task.status == TaskStatus.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${task.completedPomodoros}/${task.estimatedPomodoros}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
