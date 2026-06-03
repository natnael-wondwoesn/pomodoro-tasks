import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/memories/domain/entities/memory.dart';

class MemoryModel extends Memory {
  const MemoryModel({
    required super.id,
    required super.title,
    super.note,
    super.imageUrl,
    required super.date,
    required super.createdBy,
    required super.createdAt,
  });

  factory MemoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MemoryModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      note: data['note'] as String?,
      imageUrl: data['imageUrl'] as String?,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'note': note,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
