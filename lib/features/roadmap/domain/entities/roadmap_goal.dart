import 'package:equatable/equatable.dart';

enum RoadmapGoalStatus { todo, done, skipped }

class RoadmapGoal extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final RoadmapGoalStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deadlineAt;
  final int order;

  const RoadmapGoal({
    required this.id,
    required this.title,
    this.description,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.status = RoadmapGoalStatus.todo,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deadlineAt,
    this.order = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    estimatedPomodoros,
    completedPomodoros,
    status,
    createdBy,
    createdAt,
    updatedAt,
    deadlineAt,
    order,
  ];
}
