import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/widgets/task_list_widget.dart';
import 'package:uuid/uuid.dart';

class TasksPage extends StatelessWidget {
  final String pairId;
  final String userId;

  const TasksPage({super.key, required this.pairId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
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
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          final tasks = state is TasksLoaded
              ? state.tasks
              : const <TaskEntity>[];
          final doneCount = tasks
              .where((task) => task.status == TaskStatus.done)
              .length;
          final activeCount = tasks.length - doneCount;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tasks',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeCount == 0
                          ? 'Nothing active. Add a task when you are ready.'
                          : '\u{1F3AF} $activeCount active  \u2705 $doneCount done',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tasks.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: doneCount / tasks.length,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: TaskListWidget(pairId: pairId),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int pomodoros = 1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Task title'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('\u{1F345} Pomodoros: ',
                      style: Theme.of(context).textTheme.bodyMedium),
                  IconButton(
                    onPressed: () {
                      if (pomodoros > 1) setState(() => pomodoros--);
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text('$pomodoros',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    onPressed: () => setState(() => pomodoros++),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final bloc = BlocProvider.of<TasksBloc>(
                    dialogContext,
                    listen: false,
                  );
                  bloc.add(
                    TaskAddRequested(
                      pairId: pairId,
                      task: TaskEntity(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        description: descController.text.isEmpty
                            ? null
                            : descController.text,
                        estimatedPomodoros: pomodoros,
                        ownerId: userId,
                        createdAt: DateTime.now(),
                      ),
                    ),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
