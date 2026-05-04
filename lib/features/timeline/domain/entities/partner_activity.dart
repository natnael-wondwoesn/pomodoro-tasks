import 'package:equatable/equatable.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

class PartnerActivity extends Equatable {
  final String partnerId;
  final String partnerName;
  final SessionType? currentSessionType;
  final Duration? remainingTime;
  final String? currentTaskTitle;
  final List<TaskEntity> upcomingTasks;
  final int completedTasksToday;
  final int totalFocusMinutesToday;

  const PartnerActivity({
    required this.partnerId,
    required this.partnerName,
    this.currentSessionType,
    this.remainingTime,
    this.currentTaskTitle,
    this.upcomingTasks = const [],
    this.completedTasksToday = 0,
    this.totalFocusMinutesToday = 0,
  });

  bool get isActive => currentSessionType != null;

  String get statusText {
    if (!isActive) return 'Idle';
    switch (currentSessionType!) {
      case SessionType.work:
        return 'Focusing';
      case SessionType.shortBreak:
        return 'Short break';
      case SessionType.longBreak:
        return 'Long break';
    }
  }

  @override
  List<Object?> get props => [
        partnerId, partnerName, currentSessionType,
        remainingTime, currentTaskTitle, upcomingTasks,
        completedTasksToday, totalFocusMinutesToday,
      ];
}
