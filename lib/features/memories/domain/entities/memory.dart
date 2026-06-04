import 'dart:typed_data';

class Memory {
  final String id;
  final String title;
  final String? note;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;

  const Memory({
    required this.id,
    required this.title,
    this.note,
    this.imageUrl,
    this.imageBytes,
    required this.date,
    required this.createdBy,
    required this.createdAt,
  });
}
