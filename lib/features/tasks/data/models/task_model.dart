import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.estimatedPomodoros,
    super.completedPomodoros,
    super.status,
    required super.ownerId,
    required super.createdAt,
    super.order,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      estimatedPomodoros: data['estimatedPomodoros'] ?? 1,
      completedPomodoros: data['completedPomodoros'] ?? 0,
      status: TaskStatus.values.byName(data['status'] ?? 'todo'),
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: data['order'] ?? 0,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      estimatedPomodoros: entity.estimatedPomodoros,
      completedPomodoros: entity.completedPomodoros,
      status: entity.status,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt,
      order: entity.order,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'status': status.name,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }

  TaskModel copyWithId(String newId) {
    return TaskModel(
      id: newId,
      title: title,
      description: description,
      estimatedPomodoros: estimatedPomodoros,
      completedPomodoros: completedPomodoros,
      status: status,
      ownerId: ownerId,
      createdAt: createdAt,
      order: order,
    );
  }
}
