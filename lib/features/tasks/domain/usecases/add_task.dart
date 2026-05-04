import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/domain/repositories/tasks_repository.dart';

class AddTask implements UseCase<TaskEntity, AddTaskParams> {
  final TasksRepository repository;

  AddTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(AddTaskParams params) {
    return repository.addTask(pairId: params.pairId, task: params.task);
  }
}

class AddTaskParams {
  final String pairId;
  final TaskEntity task;

  const AddTaskParams({required this.pairId, required this.task});
}
