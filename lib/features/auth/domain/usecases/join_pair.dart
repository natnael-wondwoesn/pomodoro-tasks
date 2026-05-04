import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/repositories/auth_repository.dart';

class JoinPair implements UseCase<AppUser, JoinPairParams> {
  final AuthRepository repository;

  JoinPair(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(JoinPairParams params) {
    return repository.joinPair(pairCode: params.pairCode);
  }
}

class JoinPairParams {
  final String pairCode;

  const JoinPairParams({required this.pairCode});
}
