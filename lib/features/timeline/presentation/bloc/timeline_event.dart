part of 'timeline_bloc.dart';

abstract class TimelineEvent extends Equatable {
  const TimelineEvent();

  @override
  List<Object?> get props => [];
}

class TimelineLoadRequested extends TimelineEvent {
  final String pairId;
  final String partnerId;

  const TimelineLoadRequested({required this.pairId, required this.partnerId});

  @override
  List<Object?> get props => [pairId, partnerId];
}

class TimelineSessionUpdated extends TimelineEvent {
  final PomodoroSession? session;

  const TimelineSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}

class TimelineTasksUpdated extends TimelineEvent {
  final List<TaskEntity> tasks;

  const TimelineTasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}
