import 'package:equatable/equatable.dart';

enum TimerMode { classic, flexible, taskLinked }

class PomodoroConfig extends Equatable {
  final Duration workDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int roundsBeforeLongBreak;
  final TimerMode mode;

  const PomodoroConfig({
    this.workDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.roundsBeforeLongBreak = 4,
    this.mode = TimerMode.classic,
  });

  PomodoroConfig copyWith({
    Duration? workDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? roundsBeforeLongBreak,
    TimerMode? mode,
  }) {
    return PomodoroConfig(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      roundsBeforeLongBreak: roundsBeforeLongBreak ?? this.roundsBeforeLongBreak,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        roundsBeforeLongBreak,
        mode,
      ];
}
