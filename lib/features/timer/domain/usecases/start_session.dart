import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';
import 'package:pomodoro_tasks/features/timer/domain/repositories/timer_repository.dart';

class StartSession implements UseCase<PomodoroSession, StartSessionParams> {
  final TimerRepository repository;

  StartSession(this.repository);

  @override
  Future<Either<Failure, PomodoroSession>> call(StartSessionParams params) {
    return repository.startSession(
      userId: params.userId,
      pairId: params.pairId,
      type: params.type,
      duration: params.duration,
      taskId: params.taskId,
    );
  }
}

class StartSessionParams {
  final String userId;
  final String pairId;
  final SessionType type;
  final Duration duration;
  final String? taskId;

  const StartSessionParams({
    required this.userId,
    required this.pairId,
    required this.type,
    required this.duration,
    this.taskId,
  });
}
