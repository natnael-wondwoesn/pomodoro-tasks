import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.partnerId,
    super.pairId,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      partnerId: data['partnerId'],
      pairId: data['pairId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'partnerId': partnerId,
      'pairId': pairId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
