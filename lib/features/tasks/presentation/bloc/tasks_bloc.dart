import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/domain/usecases/get_tasks.dart';
import 'package:pomodoro_tasks/features/tasks/domain/usecases/add_task.dart';
import 'package:pomodoro_tasks/features/tasks/domain/usecases/update_task.dart';
import 'package:pomodoro_tasks/features/tasks/domain/usecases/delete_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  TasksBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TasksInitial()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TasksUpdated>(_onTasksUpdated);
    on<TaskAddRequested>(_onAddRequested);
    on<TaskUpdateRequested>(_onUpdateRequested);
    on<TaskDeleteRequested>(_onDeleteRequested);
    on<TaskReorderRequested>(_onReorderRequested);
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }

  void _onLoadRequested(TasksLoadRequested event, Emitter<TasksState> emit) {
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasks(pairId: event.pairId, userId: event.userId).listen(
      (tasks) => add(TasksUpdated(tasks)),
    );
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TasksState> emit) {
    emit(TasksLoaded(event.tasks));
  }

  Future<void> _onAddRequested(TaskAddRequested event, Emitter<TasksState> emit) async {
    final result = await addTask(AddTaskParams(pairId: event.pairId, task: event.task));
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onUpdateRequested(TaskUpdateRequested event, Emitter<TasksState> emit) async {
    final result = await updateTask(UpdateTaskParams(pairId: event.pairId, task: event.task));
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteRequested(TaskDeleteRequested event, Emitter<TasksState> emit) async {
    final result = await deleteTask(DeleteTaskParams(pairId: event.pairId, taskId: event.taskId));
    result.fold(
      (failure) => emit(TasksError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onReorderRequested(TaskReorderRequested event, Emitter<TasksState> emit) async {
    if (state is! TasksLoaded) return;
    final tasks = List<TaskEntity>.from((state as TasksLoaded).tasks);
    final task = tasks.removeAt(event.oldIndex);
    tasks.insert(event.newIndex, task);

    for (int i = 0; i < tasks.length; i++) {
      final updated = tasks[i].copyWith(order: i);
      await updateTask(UpdateTaskParams(pairId: event.pairId, task: updated));
    }
  }
}
