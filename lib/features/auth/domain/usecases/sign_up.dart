import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/repositories/auth_repository.dart';

class SignUp implements UseCase<AppUser, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}
