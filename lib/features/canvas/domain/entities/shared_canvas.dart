import 'package:equatable/equatable.dart';

class SharedCanvas extends Equatable {
  final String id;
  final String pairId;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String createdBy;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharedCanvas({
    required this.id,
    required this.pairId,
    this.imageUrl,
    this.thumbnailUrl,
    required this.createdBy,
    this.title = '',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isWhiteboard => imageUrl == null;

  @override
  List<Object?> get props => [
        id, pairId, imageUrl, thumbnailUrl,
        createdBy, title, createdAt, updatedAt,
      ];
}
