part of 'drawing_bloc.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();

  @override
  List<Object?> get props => [];
}

class DrawingStartListening extends DrawingEvent {
  final Stream<List<Stroke>> strokesStream;

  const DrawingStartListening(this.strokesStream);
}

class DrawingStrokesUpdated extends DrawingEvent {
  final List<Stroke> strokes;

  const DrawingStrokesUpdated(this.strokes);

  @override
  List<Object?> get props => [strokes];
}

class DrawingLocalStrokeUpdated extends DrawingEvent {
  final List<StrokePoint> points;

  const DrawingLocalStrokeUpdated(this.points);

  @override
  List<Object?> get props => [points];
}

class DrawingStrokeFinished extends DrawingEvent {
  final String pairId;
  final String canvasId;
  final Stroke stroke;

  const DrawingStrokeFinished({
    required this.pairId,
    required this.canvasId,
    required this.stroke,
  });

  @override
  List<Object?> get props => [pairId, canvasId, stroke];
}

class DrawingUndoRequested extends DrawingEvent {
  final String pairId;
  final String canvasId;
  final String userId;

  const DrawingUndoRequested({
    required this.pairId,
    required this.canvasId,
    required this.userId,
  });

  @override
  List<Object?> get props => [pairId, canvasId, userId];
}

class DrawingColorChanged extends DrawingEvent {
  final String color;

  const DrawingColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

class DrawingStrokeWidthChanged extends DrawingEvent {
  final double width;

  const DrawingStrokeWidthChanged(this.width);

  @override
  List<Object?> get props => [width];
}

class DrawingEraserToggled extends DrawingEvent {}
