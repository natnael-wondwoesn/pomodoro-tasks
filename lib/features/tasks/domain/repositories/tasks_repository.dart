import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';

abstract class TasksRepository {
  Stream<List<TaskEntity>> getTasks({required String pairId, required String userId});
  Future<Either<Failure, TaskEntity>> addTask({
    required String pairId,
    required TaskEntity task,
  });
  Future<Either<Failure, void>> updateTask({
    required String pairId,
    required TaskEntity task,
  });
  Future<Either<Failure, void>> deleteTask({
    required String pairId,
    required String taskId,
  });
}
