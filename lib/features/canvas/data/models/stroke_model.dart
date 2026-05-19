import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';

class StrokeModel extends Stroke {
  const StrokeModel({
    required super.id,
    required super.points,
    required super.color,
    required super.strokeWidth,
    super.isEraser,
    required super.createdBy,
    required super.timestamp,
  });

  factory StrokeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointsList = (data['points'] as List<dynamic>? ?? [])
        .map((p) => StrokePoint(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
            ))
        .toList();

    return StrokeModel(
      id: doc.id,
      points: pointsList,
      color: data['color'] ?? '#000000',
      strokeWidth: (data['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      isEraser: data['isEraser'] ?? false,
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'points': points.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'color': color,
      'strokeWidth': strokeWidth,
      'isEraser': isEraser,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
