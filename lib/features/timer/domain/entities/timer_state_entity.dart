import 'package:equatable/equatable.dart';

enum TimerStatus { idle, running, paused }

enum SessionType { work, shortBreak, longBreak }

class TimerStateEntity extends Equatable {
  final TimerStatus status;
  final SessionType type;
  final Duration remaining;
  final Duration total;
  final int currentRound;
  final int totalRounds;
  final String? linkedTaskId;

  const TimerStateEntity({
    this.status = TimerStatus.idle,
    this.type = SessionType.work,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
    this.currentRound = 1,
    this.totalRounds = 4,
    this.linkedTaskId,
  });

  double get progress {
    if (total.inSeconds == 0) return 0;
    return 1 - (remaining.inSeconds / total.inSeconds);
  }

  String get formattedTime {
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get statusLabel {
    switch (type) {
      case SessionType.work:
        return 'FOCUS TIME';
      case SessionType.shortBreak:
        return 'SHORT BREAK';
      case SessionType.longBreak:
        return 'LONG BREAK';
    }
  }

  TimerStateEntity copyWith({
    TimerStatus? status,
    SessionType? type,
    Duration? remaining,
    Duration? total,
    int? currentRound,
    int? totalRounds,
    String? linkedTaskId,
  }) {
    return TimerStateEntity(
      status: status ?? this.status,
      type: type ?? this.type,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
    );
  }

  @override
  List<Object?> get props => [status, type, remaining, total, currentRound, totalRounds, linkedTaskId];
}
