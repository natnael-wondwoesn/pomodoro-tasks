import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/tasks/domain/repositories/tasks_repository.dart';

class DeleteTask implements UseCase<void, DeleteTaskParams> {
  final TasksRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return repository.deleteTask(pairId: params.pairId, taskId: params.taskId);
  }
}

class DeleteTaskParams {
  final String pairId;
  final String taskId;

  const DeleteTaskParams({required this.pairId, required this.taskId});
}
