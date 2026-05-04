import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

abstract class TimerRepository {
  Future<Either<Failure, PomodoroSession>> startSession({
    required String userId,
    required String pairId,
    required SessionType type,
    required Duration duration,
    String? taskId,
  });

  Future<Either<Failure, void>> endSession({
    required String pairId,
    required String sessionId,
    required String status,
  });

  Stream<PomodoroSession?> getPartnerActiveSession({
    required String pairId,
    required String partnerId,
  });
}
