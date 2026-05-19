import 'dart:async';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/get_canvases.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/create_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/delete_canvas.dart';

part 'canvas_event.dart';
part 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  final GetCanvases getCanvases;
  final CreateCanvas createCanvas;
  final DeleteCanvas deleteCanvas;

  StreamSubscription<List<SharedCanvas>>? _canvasesSubscription;

  CanvasBloc({
    required this.getCanvases,
    required this.createCanvas,
    required this.deleteCanvas,
  }) : super(CanvasInitial()) {
    on<CanvasLoadRequested>(_onLoadRequested);
    on<CanvasListUpdated>(_onListUpdated);
    on<CanvasCreateRequested>(_onCreateRequested);
    on<CanvasDeleteRequested>(_onDeleteRequested);
  }

  @override
  Future<void> close() {
    _canvasesSubscription?.cancel();
    return super.close();
  }

  void _onLoadRequested(CanvasLoadRequested event, Emitter<CanvasState> emit) {
    _canvasesSubscription?.cancel();
    _canvasesSubscription = getCanvases(pairId: event.pairId).listen(
      (canvases) => add(CanvasListUpdated(canvases)),
    );
  }

  void _onListUpdated(CanvasListUpdated event, Emitter<CanvasState> emit) {
    emit(CanvasLoaded(event.canvases));
  }

  Future<void> _onCreateRequested(
    CanvasCreateRequested event,
    Emitter<CanvasState> emit,
  ) async {
    final result = await createCanvas(CreateCanvasParams(
      pairId: event.pairId,
      createdBy: event.createdBy,
      title: event.title,
      imageBytes: event.imageBytes,
    ));
    result.fold(
      (failure) => emit(CanvasError(failure.message)),
      (canvas) => emit(CanvasCreated(canvas)),
    );
  }

  Future<void> _onDeleteRequested(
    CanvasDeleteRequested event,
    Emitter<CanvasState> emit,
  ) async {
    final result = await deleteCanvas(DeleteCanvasParams(
      pairId: event.pairId,
      canvasId: event.canvasId,
    ));
    result.fold(
      (failure) => emit(CanvasError(failure.message)),
      (_) {},
    );
  }
}
