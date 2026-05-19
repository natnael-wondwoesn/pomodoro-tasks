import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AppUser>> getCurrentUser();

  Future<Either<Failure, String>> createPair();

  Future<Either<Failure, AppUser>> joinPair({required String pairCode});

  Stream<AppUser?> get authStateChanges;
}
