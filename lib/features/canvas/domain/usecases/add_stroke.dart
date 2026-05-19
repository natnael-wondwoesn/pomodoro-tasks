import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class AddStroke {
  final CanvasRepository repository;

  AddStroke(this.repository);

  Future<Either<Failure, void>> call(AddStrokeParams params) {
    return repository.addStroke(
      pairId: params.pairId,
      canvasId: params.canvasId,
      stroke: params.stroke,
    );
  }
}

class AddStrokeParams {
  final String pairId;
  final String canvasId;
  final Stroke stroke;

  const AddStrokeParams({
    required this.pairId,
    required this.canvasId,
    required this.stroke,
  });
}
