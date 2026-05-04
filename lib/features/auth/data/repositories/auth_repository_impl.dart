import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signIn(email: email, password: password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDatasource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDatasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getCurrentUser() async {
    try {
      final user = await remoteDatasource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createPair() async {
    try {
      final code = await remoteDatasource.createPair();
      return Right(code);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> joinPair({required String pairCode}) async {
    try {
      final user = await remoteDatasource.joinPair(pairCode: pairCode);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      remoteDatasource.authStateChanges.asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        try {
          return await remoteDatasource.getCurrentUser();
        } catch (_) {
          return null;
        }
      });
}
