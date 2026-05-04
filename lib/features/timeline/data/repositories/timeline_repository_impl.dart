import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timeline/data/datasources/timeline_remote_datasource.dart';
import 'package:pomodoro_tasks/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  final TimelineRemoteDatasource remoteDatasource;

  TimelineRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<PomodoroSession?> getPartnerActiveSession({
    required String pairId,
    required String partnerId,
  }) {
    return remoteDatasource.getPartnerActiveSession(
      pairId: pairId,
      partnerId: partnerId,
    );
  }

  @override
  Stream<List<TaskEntity>> getPartnerTasks({
    required String pairId,
    required String partnerId,
  }) {
    return remoteDatasource.getPartnerTasks(
      pairId: pairId,
      partnerId: partnerId,
    );
  }
}
