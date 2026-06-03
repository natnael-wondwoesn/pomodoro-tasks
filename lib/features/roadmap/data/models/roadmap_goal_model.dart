import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/roadmap/domain/entities/roadmap_goal.dart';

class RoadmapGoalModel extends RoadmapGoal {
  const RoadmapGoalModel({
    required super.id,
    required super.title,
    super.description,
    super.estimatedPomodoros,
    super.completedPomodoros,
    super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.deadlineAt,
    super.order,
  });

  factory RoadmapGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoadmapGoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      estimatedPomodoros: data['estimatedPomodoros'] ?? 1,
      completedPomodoros: data['completedPomodoros'] ?? 0,
      status: RoadmapGoalStatus.values.byName(data['status'] ?? 'todo'),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadlineAt: (data['deadlineAt'] as Timestamp?)?.toDate(),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'status': status.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deadlineAt': deadlineAt == null ? null : Timestamp.fromDate(deadlineAt!),
      'order': order,
    };
  }
}
