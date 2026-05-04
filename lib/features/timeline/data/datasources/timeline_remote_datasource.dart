import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/features/tasks/data/models/task_model.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

abstract class TimelineRemoteDatasource {
  Stream<PomodoroSession?> getPartnerActiveSession({
    required String pairId,
    required String partnerId,
  });
  Stream<List<TaskModel>> getPartnerTasks({
    required String pairId,
    required String partnerId,
  });
}

class TimelineRemoteDatasourceImpl implements TimelineRemoteDatasource {
  final FirebaseFirestore firestore;

  TimelineRemoteDatasourceImpl({required this.firestore});

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

  @override
  Stream<List<TaskModel>> getPartnerTasks({
    required String pairId,
    required String partnerId,
  }) {
    return firestore
        .collection(AppConstants.pairsCollection)
        .doc(pairId)
        .collection(AppConstants.tasksCollection)
        .where('ownerId', isEqualTo: partnerId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }
}
