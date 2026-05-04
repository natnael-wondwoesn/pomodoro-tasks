import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/auth/domain/repositories/auth_repository.dart';

class CreatePair implements UseCase<String, NoParams> {
  final AuthRepository repository;

  CreatePair(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.createPair();
  }
}
