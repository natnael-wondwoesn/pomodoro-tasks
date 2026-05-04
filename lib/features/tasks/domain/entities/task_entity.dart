import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, done }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final TaskStatus status;
  final String ownerId;
  final DateTime createdAt;
  final int order;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.status = TaskStatus.todo,
    required this.ownerId,
    required this.createdAt,
    this.order = 0,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    int? estimatedPomodoros,
    int? completedPomodoros,
    TaskStatus? status,
    int? order,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      status: status ?? this.status,
      ownerId: ownerId,
      createdAt: createdAt,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, estimatedPomodoros,
        completedPomodoros, status, ownerId, createdAt, order,
      ];
}
