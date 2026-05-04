import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';

abstract class TimelineRepository {
  Stream<PomodoroSession?> getPartnerActiveSession({
    required String pairId,
    required String partnerId,
  });

  Stream<List<TaskEntity>> getPartnerTasks({
    required String pairId,
    required String partnerId,
  });
}
