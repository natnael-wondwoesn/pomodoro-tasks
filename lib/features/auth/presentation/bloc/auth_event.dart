part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthCreatePairRequested extends AuthEvent {}

class AuthJoinPairRequested extends AuthEvent {
  final String pairCode;

  const AuthJoinPairRequested({required this.pairCode});

  @override
  List<Object?> get props => [pairCode];
}
