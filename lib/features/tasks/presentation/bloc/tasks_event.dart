part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TasksEvent {
  final String pairId;
  final String userId;

  const TasksLoadRequested({required this.pairId, required this.userId});

  @override
  List<Object?> get props => [pairId, userId];
}

class TasksUpdated extends TasksEvent {
  final List<TaskEntity> tasks;

  const TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskAddRequested extends TasksEvent {
  final String pairId;
  final TaskEntity task;

  const TaskAddRequested({required this.pairId, required this.task});

  @override
  List<Object?> get props => [pairId, task];
}

class TaskUpdateRequested extends TasksEvent {
  final String pairId;
  final TaskEntity task;

  const TaskUpdateRequested({required this.pairId, required this.task});

  @override
  List<Object?> get props => [pairId, task];
}

class TaskDeleteRequested extends TasksEvent {
  final String pairId;
  final String taskId;

  const TaskDeleteRequested({required this.pairId, required this.taskId});

  @override
  List<Object?> get props => [pairId, taskId];
}

class TaskReorderRequested extends TasksEvent {
  final String pairId;
  final int oldIndex;
  final int newIndex;

  const TaskReorderRequested({
    required this.pairId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [pairId, oldIndex, newIndex];
}
