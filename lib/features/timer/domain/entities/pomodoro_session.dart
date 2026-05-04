import 'package:equatable/equatable.dart';
import 'timer_state_entity.dart';

class PomodoroSession extends Equatable {
  final String id;
  final String userId;
  final String? taskId;
  final SessionType type;
  final DateTime startedAt;
  final Duration duration;
  final DateTime? completedAt;
  final String status; // active, completed, cancelled

  const PomodoroSession({
    required this.id,
    required this.userId,
    this.taskId,
    required this.type,
    required this.startedAt,
    required this.duration,
    this.completedAt,
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, userId, taskId, type, startedAt, duration, completedAt, status];
}
