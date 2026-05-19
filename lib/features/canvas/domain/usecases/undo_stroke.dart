import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class UndoStroke {
  final CanvasRepository repository;

  UndoStroke(this.repository);

  Future<Either<Failure, void>> call(UndoStrokeParams params) {
    return repository.undoStroke(
      pairId: params.pairId,
      canvasId: params.canvasId,
      strokeId: params.strokeId,
    );
  }
}

class UndoStrokeParams {
  final String pairId;
  final String canvasId;
  final String strokeId;

  const UndoStrokeParams({
    required this.pairId,
    required this.canvasId,
    required this.strokeId,
  });
}
