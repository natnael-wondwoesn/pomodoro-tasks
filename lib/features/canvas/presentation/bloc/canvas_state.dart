part of 'canvas_bloc.dart';

abstract class CanvasState extends Equatable {
  const CanvasState();

  @override
  List<Object?> get props => [];
}

class CanvasInitial extends CanvasState {}

class CanvasLoaded extends CanvasState {
  final List<SharedCanvas> canvases;

  const CanvasLoaded(this.canvases);

  @override
  List<Object?> get props => [canvases];
}

class CanvasCreated extends CanvasState {
  final SharedCanvas canvas;

  const CanvasCreated(this.canvas);

  @override
  List<Object?> get props => [canvas];
}

class CanvasError extends CanvasState {
  final String message;

  const CanvasError(this.message);

  @override
  List<Object?> get props => [message];
}
