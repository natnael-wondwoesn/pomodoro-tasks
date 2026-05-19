import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/add_stroke.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/undo_stroke.dart';

part 'drawing_event.dart';
part 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  final AddStroke addStrokeUseCase;
  final UndoStroke undoStrokeUseCase;

  StreamSubscription<List<Stroke>>? _strokesSubscription;

  DrawingBloc({
    required this.addStrokeUseCase,
    required this.undoStrokeUseCase,
  }) : super(const DrawingState()) {
    on<DrawingStartListening>(_onStartListening);
    on<DrawingStrokesUpdated>(_onStrokesUpdated);
    on<DrawingStrokeFinished>(_onStrokeFinished);
    on<DrawingLocalStrokeUpdated>(_onLocalStrokeUpdated);
    on<DrawingUndoRequested>(_onUndoRequested);
    on<DrawingColorChanged>(_onColorChanged);
    on<DrawingStrokeWidthChanged>(_onStrokeWidthChanged);
    on<DrawingEraserToggled>(_onEraserToggled);
  }

  @override
  Future<void> close() {
    _strokesSubscription?.cancel();
    return super.close();
  }

  void _onStartListening(
    DrawingStartListening event,
    Emitter<DrawingState> emit,
  ) {
    _strokesSubscription?.cancel();
    _strokesSubscription = event.strokesStream.listen(
      (strokes) => add(DrawingStrokesUpdated(strokes)),
    );
  }

  void _onStrokesUpdated(
    DrawingStrokesUpdated event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(remoteStrokes: event.strokes));
  }

  void _onLocalStrokeUpdated(
    DrawingLocalStrokeUpdated event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(currentStrokePoints: event.points));
  }

  Future<void> _onStrokeFinished(
    DrawingStrokeFinished event,
    Emitter<DrawingState> emit,
  ) async {
    emit(state.copyWith(currentStrokePoints: []));

    final result = await addStrokeUseCase(AddStrokeParams(
      pairId: event.pairId,
      canvasId: event.canvasId,
      stroke: event.stroke,
    ));
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {},
    );
  }

  Future<void> _onUndoRequested(
    DrawingUndoRequested event,
    Emitter<DrawingState> emit,
  ) async {
    // Find last stroke by this user
    final myStrokes = state.remoteStrokes
        .where((s) => s.createdBy == event.userId)
        .toList();
    if (myStrokes.isEmpty) return;

    final lastStroke = myStrokes.last;
    final result = await undoStrokeUseCase(UndoStrokeParams(
      pairId: event.pairId,
      canvasId: event.canvasId,
      strokeId: lastStroke.id,
    ));
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) {},
    );
  }

  void _onColorChanged(DrawingColorChanged event, Emitter<DrawingState> emit) {
    emit(state.copyWith(selectedColor: event.color, isEraser: false));
  }

  void _onStrokeWidthChanged(
    DrawingStrokeWidthChanged event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(strokeWidth: event.width));
  }

  void _onEraserToggled(
    DrawingEraserToggled event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(isEraser: !state.isEraser));
  }
}
