part of 'canvas_bloc.dart';

abstract class CanvasEvent extends Equatable {
  const CanvasEvent();

  @override
  List<Object?> get props => [];
}

class CanvasLoadRequested extends CanvasEvent {
  final String pairId;

  const CanvasLoadRequested({required this.pairId});

  @override
  List<Object?> get props => [pairId];
}

class CanvasListUpdated extends CanvasEvent {
  final List<SharedCanvas> canvases;

  const CanvasListUpdated(this.canvases);

  @override
  List<Object?> get props => [canvases];
}

class CanvasCreateRequested extends CanvasEvent {
  final String pairId;
  final String createdBy;
  final String title;
  final Uint8List? imageBytes;

  const CanvasCreateRequested({
    required this.pairId,
    required this.createdBy,
    this.title = '',
    this.imageBytes,
  });

  @override
  List<Object?> get props => [pairId, createdBy, title];
}

class CanvasDeleteRequested extends CanvasEvent {
  final String pairId;
  final String canvasId;

  const CanvasDeleteRequested({
    required this.pairId,
    required this.canvasId,
  });

  @override
  List<Object?> get props => [pairId, canvasId];
}
