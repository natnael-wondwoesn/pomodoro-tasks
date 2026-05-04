import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/tasks/domain/repositories/tasks_repository.dart';

class GetTasks {
  final TasksRepository repository;

  GetTasks(this.repository);

  Stream<List<TaskEntity>> call({required String pairId, required String userId}) {
    return repository.getTasks(pairId: pairId, userId: userId);
  }
}
