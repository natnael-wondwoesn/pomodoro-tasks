import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';
import 'package:pomodoro_tasks/features/timer/domain/repositories/timer_repository.dart';

class TimerRepositoryImpl implements TimerRepository {
  final FirebaseFirestore firestore;

  TimerRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, PomodoroSession>> startSession({
    required String userId,
    required String pairId,
    required SessionType type,
    required Duration duration,
    String? taskId,
  }) async {
    try {
      final doc = await firestore
          .collection(AppConstants.pairsCollection)
          .doc(pairId)
          .collection(AppConstants.sessionsCollection)
          .add({
        'userId': userId,
        'taskId': taskId,
        'type': type.name,
        'startedAt': FieldValue.serverTimestamp(),
        'duration': duration.inSeconds,
        'completedAt': null,
        'status': 'active',
      });

      final session = PomodoroSession(
        id: doc.id,
        userId: userId,
        taskId: taskId,
        type: type,
        startedAt: DateTime.now(),
        duration: duration,
        status: 'active',
      );

      return Right(session);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endSession({
    required String pairId,
    required String sessionId,
    required String status,
  }) async {
    try {
      await firestore
          .collection(AppConstants.pairsCollection)
          .doc(pairId)
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({
        'completedAt': FieldValue.serverTimestamp(),
        'status': status,
      });
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure(e.toString()));
    }
  }

  @override
  Stream<PomodoroSession?> getPartnerActiveSession({
    required String pairId,
    required String partnerId,
  }) {
    return firestore
        .collection(AppConstants.pairsCollection)
        .doc(pairId)
        .collection(AppConstants.sessionsCollection)
        .where('userId', isEqualTo: partnerId)
        .where('status', isEqualTo: 'active')
        .orderBy('startedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return PomodoroSession(
        id: doc.id,
        userId: data['userId'],
        taskId: data['taskId'],
        type: SessionType.values.byName(data['type']),
        startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        duration: Duration(seconds: data['duration']),
        status: data['status'],
      );
    });
  }
}
