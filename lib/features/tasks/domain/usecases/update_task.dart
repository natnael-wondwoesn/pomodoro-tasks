import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/domain/repositories/tasks_repository.dart';

class UpdateTask implements UseCase<void, UpdateTaskParams> {
  final TasksRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTaskParams params) {
    return repository.updateTask(pairId: params.pairId, task: params.task);
  }
}

class UpdateTaskParams {
  final String pairId;
  final TaskEntity task;

  const UpdateTaskParams({required this.pairId, required this.task});
}
