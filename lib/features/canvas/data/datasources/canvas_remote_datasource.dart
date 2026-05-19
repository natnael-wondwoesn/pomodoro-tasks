import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/features/canvas/data/models/canvas_model.dart';
import 'package:pomodoro_tasks/features/canvas/data/models/stroke_model.dart';

abstract class CanvasRemoteDatasource {
  Stream<List<CanvasModel>> getCanvases({required String pairId});

  Future<CanvasModel> createCanvas({
    required String pairId,
    required String createdBy,
    required String title,
    Uint8List? imageBytes,
  });

  Future<void> deleteCanvas({required String pairId, required String canvasId});

  Stream<List<StrokeModel>> getStrokes({
    required String pairId,
    required String canvasId,
  });

  Future<void> addStroke({
    required String pairId,
    required String canvasId,
    required StrokeModel stroke,
  });

  Future<void> undoStroke({
    required String pairId,
    required String canvasId,
    required String strokeId,
  });
}

class CanvasRemoteDatasourceImpl implements CanvasRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  CanvasRemoteDatasourceImpl({
    required this.firestore,
    required this.storage,
  });

  CollectionReference _canvasesRef(String pairId) {
    return firestore
        .collection(AppConstants.pairsCollection)
        .doc(pairId)
        .collection(AppConstants.canvasesCollection);
  }

  CollectionReference _strokesRef(String pairId, String canvasId) {
    return _canvasesRef(pairId)
        .doc(canvasId)
        .collection(AppConstants.strokesCollection);
  }

  @override
  Stream<List<CanvasModel>> getCanvases({required String pairId}) {
    return _canvasesRef(pairId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CanvasModel.fromFirestore(doc)).toList());
  }

  @override
  Future<CanvasModel> createCanvas({
    required String pairId,
    required String createdBy,
    required String title,
    Uint8List? imageBytes,
  }) async {
    final now = DateTime.now();
    String? imageUrl;

    // Create the canvas doc first to get an ID
    final docRef = _canvasesRef(pairId).doc();

    if (imageBytes != null) {
      final ref = storage.ref('pairs/$pairId/canvases/${docRef.id}/original.jpg');
      await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      imageUrl = await ref.getDownloadURL();
    }

    final canvas = CanvasModel(
      id: docRef.id,
      pairId: pairId,
      imageUrl: imageUrl,
      createdBy: createdBy,
      title: title,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(canvas.toFirestore());
    return canvas;
  }

  @override
  Future<void> deleteCanvas({
    required String pairId,
    required String canvasId,
  }) async {
    // Delete strokes subcollection
    final strokes = await _strokesRef(pairId, canvasId).get();
    for (final doc in strokes.docs) {
      await doc.reference.delete();
    }

    // Delete image from storage if it exists
    try {
      await storage.ref('pairs/$pairId/canvases/$canvasId/original.jpg').delete();
    } catch (_) {
      // Image may not exist (whiteboard canvas)
    }

    // Delete canvas doc
    await _canvasesRef(pairId).doc(canvasId).delete();
  }

  @override
  Stream<List<StrokeModel>> getStrokes({
    required String pairId,
    required String canvasId,
  }) {
    return _strokesRef(pairId, canvasId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StrokeModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addStroke({
    required String pairId,
    required String canvasId,
    required StrokeModel stroke,
  }) async {
    await _strokesRef(pairId, canvasId).add(stroke.toFirestore());

    // Update canvas timestamp
    await _canvasesRef(pairId).doc(canvasId).update({
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> undoStroke({
    required String pairId,
    required String canvasId,
    required String strokeId,
  }) async {
    await _strokesRef(pairId, canvasId).doc(strokeId).delete();
  }
}
