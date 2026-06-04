import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_tasks/features/memories/domain/entities/memory.dart';

class MemoryModel extends Memory {
  const MemoryModel({
    required super.id,
    required super.title,
    super.note,
    super.imageUrl,
    super.imageBytes,
    required super.date,
    required super.createdBy,
    required super.createdAt,
  });

  factory MemoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MemoryModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      note: data['note'] as String?,
      imageUrl: data['imageUrl'] as String?,
      imageBytes: _imageBytesFromFirestore(data['imageBytes']),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'note': note,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes == null ? null : Blob(imageBytes!),
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Uint8List? _imageBytesFromFirestore(Object? value) {
    if (value is Blob) return value.bytes;
    if (value is Uint8List) return value;
    return null;
  }
}
