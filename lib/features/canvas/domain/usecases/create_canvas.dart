import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class CreateCanvas {
  final CanvasRepository repository;

  CreateCanvas(this.repository);

  Future<Either<Failure, SharedCanvas>> call(CreateCanvasParams params) {
    return repository.createCanvas(
      pairId: params.pairId,
      createdBy: params.createdBy,
      title: params.title,
      imageBytes: params.imageBytes,
    );
  }
}

class CreateCanvasParams {
  final String pairId;
  final String createdBy;
  final String title;
  final Uint8List? imageBytes;

  const CreateCanvasParams({
    required this.pairId,
    required this.createdBy,
    this.title = '',
    this.imageBytes,
  });
}
