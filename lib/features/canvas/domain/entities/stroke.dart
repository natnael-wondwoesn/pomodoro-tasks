import 'package:equatable/equatable.dart';

class StrokePoint {
  final double x;
  final double y;

  const StrokePoint(this.x, this.y);
}

class Stroke extends Equatable {
  final String id;
  final List<StrokePoint> points;
  final String color;
  final double strokeWidth;
  final bool isEraser;
  final String createdBy;
  final DateTime timestamp;

  const Stroke({
    required this.id,
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
    required this.createdBy,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, color, strokeWidth, isEraser, createdBy, timestamp];
}
