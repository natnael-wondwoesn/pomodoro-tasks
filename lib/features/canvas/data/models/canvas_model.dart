import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';

class CanvasModel extends SharedCanvas {
  const CanvasModel({
    required super.id,
    required super.pairId,
    super.imageUrl,
    super.thumbnailUrl,
    required super.createdBy,
    super.title,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CanvasModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CanvasModel(
      id: doc.id,
      pairId: data['pairId'] ?? '',
      imageUrl: data['imageUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      createdBy: data['createdBy'] ?? '',
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pairId': pairId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdBy': createdBy,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
