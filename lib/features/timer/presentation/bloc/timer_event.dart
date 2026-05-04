part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class TimerStarted extends TimerEvent {
  final String? taskId;

  const TimerStarted({this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class TimerPaused extends TimerEvent {}

class TimerResumed extends TimerEvent {}

class TimerReset extends TimerEvent {}

class TimerTicked extends TimerEvent {}

class TimerSkipped extends TimerEvent {}

class TimerConfigUpdated extends TimerEvent {
  final PomodoroConfig config;

  const TimerConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

class TimerUserSet extends TimerEvent {
  final String userId;
  final String? pairId;

  const TimerUserSet({required this.userId, this.pairId});

  @override
  List<Object?> get props => [userId, pairId];
}
