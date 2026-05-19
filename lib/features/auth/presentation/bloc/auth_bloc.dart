import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/sign_out.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/get_current_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/create_pair.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/join_pair.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final CreatePair createPair;
  final JoinPair joinPair;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.createPair,
    required this.joinPair,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCreatePairRequested>(_onCreatePairRequested);
    on<AuthJoinPairRequested>(_onJoinPairRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await signOut(const NoParams());
    emit(AuthUnauthenticated());
  }

  Future<void> _onCreatePairRequested(
    AuthCreatePairRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await createPair(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (code) => emit(AuthPairCreated(code)),
    );
  }

  Future<void> _onJoinPairRequested(
    AuthJoinPairRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await joinPair(JoinPairParams(pairCode: event.pairCode));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
