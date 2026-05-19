import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';

abstract class CanvasRepository {
  Stream<List<SharedCanvas>> getCanvases({required String pairId});

  Future<Either<Failure, SharedCanvas>> createCanvas({
    required String pairId,
    required String createdBy,
    required String title,
    Uint8List? imageBytes,
  });

  Future<Either<Failure, void>> deleteCanvas({
    required String pairId,
    required String canvasId,
  });

  Stream<List<Stroke>> getStrokes({
    required String pairId,
    required String canvasId,
  });

  Future<Either<Failure, void>> addStroke({
    required String pairId,
    required String canvasId,
    required Stroke stroke,
  });

  Future<Either<Failure, void>> undoStroke({
    required String pairId,
    required String canvasId,
    required String strokeId,
  });
}
