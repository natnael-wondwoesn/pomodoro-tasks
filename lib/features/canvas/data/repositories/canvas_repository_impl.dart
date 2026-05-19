import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/canvas/data/datasources/canvas_remote_datasource.dart';
import 'package:pomodoro_tasks/features/canvas/data/models/stroke_model.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';

class CanvasRepositoryImpl implements CanvasRepository {
  final CanvasRemoteDatasource remoteDatasource;

  CanvasRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<List<SharedCanvas>> getCanvases({required String pairId}) {
    return remoteDatasource.getCanvases(pairId: pairId);
  }

  @override
  Future<Either<Failure, SharedCanvas>> createCanvas({
    required String pairId,
    required String createdBy,
    required String title,
    Uint8List? imageBytes,
  }) async {
    try {
      final canvas = await remoteDatasource.createCanvas(
        pairId: pairId,
        createdBy: createdBy,
        title: title,
        imageBytes: imageBytes,
      );
      return Right(canvas);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCanvas({
    required String pairId,
    required String canvasId,
  }) async {
    try {
      await remoteDatasource.deleteCanvas(pairId: pairId, canvasId: canvasId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Stroke>> getStrokes({
    required String pairId,
    required String canvasId,
  }) {
    return remoteDatasource.getStrokes(pairId: pairId, canvasId: canvasId);
  }

  @override
  Future<Either<Failure, void>> addStroke({
    required String pairId,
    required String canvasId,
    required Stroke stroke,
  }) async {
    try {
      final model = StrokeModel(
        id: stroke.id,
        points: stroke.points,
        color: stroke.color,
        strokeWidth: stroke.strokeWidth,
        isEraser: stroke.isEraser,
        createdBy: stroke.createdBy,
        timestamp: stroke.timestamp,
      );
      await remoteDatasource.addStroke(
        pairId: pairId,
        canvasId: canvasId,
        stroke: model,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> undoStroke({
    required String pairId,
    required String canvasId,
    required String strokeId,
  }) async {
    try {
      await remoteDatasource.undoStroke(
        pairId: pairId,
        canvasId: canvasId,
        strokeId: strokeId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
