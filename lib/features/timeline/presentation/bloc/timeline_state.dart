part of 'timeline_bloc.dart';

abstract class TimelineState extends Equatable {
  const TimelineState();

  @override
  List<Object?> get props => [];
}

class TimelineInitial extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final PomodoroSession? partnerSession;
  final List<TaskEntity> partnerTasks;

  const TimelineLoaded({
    this.partnerSession,
    this.partnerTasks = const [],
  });

  TimelineLoaded copyWith({
    PomodoroSession? partnerSession,
    List<TaskEntity>? partnerTasks,
  }) {
    return TimelineLoaded(
      partnerSession: partnerSession ?? this.partnerSession,
      partnerTasks: partnerTasks ?? this.partnerTasks,
    );
  }

  @override
  List<Object?> get props => [partnerSession, partnerTasks];
}
