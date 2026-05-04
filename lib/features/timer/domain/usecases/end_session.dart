import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/timer/domain/repositories/timer_repository.dart';

class EndSession implements UseCase<void, EndSessionParams> {
  final TimerRepository repository;

  EndSession(this.repository);

  @override
  Future<Either<Failure, void>> call(EndSessionParams params) {
    return repository.endSession(
      pairId: params.pairId,
      sessionId: params.sessionId,
      status: params.status,
    );
  }
}

class EndSessionParams {
  final String pairId;
  final String sessionId;
  final String status;

  const EndSessionParams({
    required this.pairId,
    required this.sessionId,
    required this.status,
  });
}
