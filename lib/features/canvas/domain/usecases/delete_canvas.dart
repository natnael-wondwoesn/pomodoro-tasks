import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class DeleteCanvas {
  final CanvasRepository repository;

  DeleteCanvas(this.repository);

  Future<Either<Failure, void>> call(DeleteCanvasParams params) {
    return repository.deleteCanvas(
      pairId: params.pairId,
      canvasId: params.canvasId,
    );
  }
}

class DeleteCanvasParams {
  final String pairId;
  final String canvasId;

  const DeleteCanvasParams({
    required this.pairId,
    required this.canvasId,
  });
}
