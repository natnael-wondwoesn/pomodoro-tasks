part of 'drawing_bloc.dart';

class DrawingState extends Equatable {
  final List<Stroke> remoteStrokes;
  final List<StrokePoint> currentStrokePoints;
  final String selectedColor;
  final double strokeWidth;
  final bool isEraser;
  final String? error;

  const DrawingState({
    this.remoteStrokes = const [],
    this.currentStrokePoints = const [],
    this.selectedColor = '#5A3E2B',
    this.strokeWidth = 3.0,
    this.isEraser = false,
    this.error,
  });

  DrawingState copyWith({
    List<Stroke>? remoteStrokes,
    List<StrokePoint>? currentStrokePoints,
    String? selectedColor,
    double? strokeWidth,
    bool? isEraser,
    String? error,
  }) {
    return DrawingState(
      remoteStrokes: remoteStrokes ?? this.remoteStrokes,
      currentStrokePoints: currentStrokePoints ?? this.currentStrokePoints,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        remoteStrokes,
        currentStrokePoints,
        selectedColor,
        strokeWidth,
        isEraser,
        error,
      ];
}
