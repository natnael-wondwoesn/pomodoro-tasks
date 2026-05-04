import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/sign_in.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/sign_up.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/sign_out.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/get_current_user.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/create_pair.dart';
import 'package:pomodoro_tasks/features/auth/domain/usecases/join_pair.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final CreatePair createPair;
  final JoinPair joinPair;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.createPair,
    required this.joinPair,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
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

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signIn(SignInParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUp(SignUpParams(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    ));
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
