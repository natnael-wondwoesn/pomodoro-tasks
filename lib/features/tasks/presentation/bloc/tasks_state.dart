part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoaded extends TasksState {
  final List<TaskEntity> tasks;

  const TasksLoaded(this.tasks);

  List<TaskEntity> get todoTasks => tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<TaskEntity> get inProgressTasks => tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskEntity> get doneTasks => tasks.where((t) => t.status == TaskStatus.done).toList();

  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}
