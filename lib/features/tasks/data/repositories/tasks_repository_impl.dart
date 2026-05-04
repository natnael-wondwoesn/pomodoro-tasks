import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/tasks/data/datasources/tasks_remote_datasource.dart';
import 'package:pomodoro_tasks/features/tasks/data/models/task_model.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDatasource remoteDatasource;

  TasksRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<List<TaskEntity>> getTasks({required String pairId, required String userId}) {
    return remoteDatasource.getTasks(pairId: pairId, userId: userId);
  }

  @override
  Future<Either<Failure, TaskEntity>> addTask({
    required String pairId,
    required TaskEntity task,
  }) async {
    try {
      final model = TaskModel.fromEntity(task);
      final result = await remoteDatasource.addTask(pairId: pairId, task: model);
      return Right(result);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask({
    required String pairId,
    required TaskEntity task,
  }) async {
    try {
      final model = TaskModel.fromEntity(task);
      await remoteDatasource.updateTask(pairId: pairId, task: model);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask({
    required String pairId,
    required String taskId,
  }) async {
    try {
      await remoteDatasource.deleteTask(pairId: pairId, taskId: taskId);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }
}
