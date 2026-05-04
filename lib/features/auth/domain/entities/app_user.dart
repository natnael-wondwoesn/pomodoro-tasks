import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? partnerId;
  final String? pairId;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.partnerId,
    this.pairId,
    required this.createdAt,
  });

  bool get isPaired => pairId != null && partnerId != null;

  @override
  List<Object?> get props => [id, email, displayName, partnerId, pairId, createdAt];
}
