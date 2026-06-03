import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
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
                                : '$activeCount active, $doneCount done',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _showAddTaskDialog(context),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (tasks.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: doneCount / tasks.length,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.72),
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
                  const Text('Pomodoros: '),
                  IconButton(
                    onPressed: () {
                      if (pomodoros > 1) setState(() => pomodoros--);
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text('$pomodoros', style: const TextStyle(fontSize: 16)),
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
