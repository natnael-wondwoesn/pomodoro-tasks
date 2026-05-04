import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';

class TogetherPage extends StatelessWidget {
  final String partnerName;

  const TogetherPage({super.key, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<TimelineBloc, TimelineState>(
          builder: (context, state) {
            if (state is! TimelineLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = state.partnerTasks;
            final completedCount = tasks.where((t) => t.status == TaskStatus.done).length;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Together', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),

                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.partnerLight.withValues(alpha: 0.1),
                          AppColors.partnerLight.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(context, '$completedCount', 'Tasks Done'),
                        _buildStat(context, '${tasks.length}', 'Total Tasks'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Partner's full timeline
                  Text(
                    "$partnerName's Tasks",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...tasks.map((task) => _buildTimelineTask(context, task)),

                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          '$partnerName has no tasks yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.partnerLight,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTimelineTask(BuildContext context, TaskEntity task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.status == TaskStatus.done
            ? AppColors.partnerLight.withValues(alpha: 0.08)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            task.status == TaskStatus.done
                ? Icons.check_circle
                : Icons.circle_outlined,
            color: AppColors.partnerLight,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
            ),
          ),
          Text(
            '${task.completedPomodoros}/${task.estimatedPomodoros}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
