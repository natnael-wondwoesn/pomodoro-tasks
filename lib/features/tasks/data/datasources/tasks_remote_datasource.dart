import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/features/tasks/data/models/task_model.dart';

abstract class TasksRemoteDatasource {
  Stream<List<TaskModel>> getTasks({required String pairId, required String userId});
  Future<TaskModel> addTask({required String pairId, required TaskModel task});
  Future<void> updateTask({required String pairId, required TaskModel task});
  Future<void> deleteTask({required String pairId, required String taskId});
}

class TasksRemoteDatasourceImpl implements TasksRemoteDatasource {
  final FirebaseFirestore firestore;

  TasksRemoteDatasourceImpl({required this.firestore});

  CollectionReference _tasksRef(String pairId) {
    return firestore
        .collection(AppConstants.pairsCollection)
        .doc(pairId)
        .collection(AppConstants.tasksCollection);
  }

  @override
  Stream<List<TaskModel>> getTasks({required String pairId, required String userId}) {
    return _tasksRef(pairId)
        .where('ownerId', isEqualTo: userId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  @override
  Future<TaskModel> addTask({required String pairId, required TaskModel task}) async {
    final doc = await _tasksRef(pairId).add(task.toFirestore());
    return task.copyWithId(doc.id);
  }

  @override
  Future<void> updateTask({required String pairId, required TaskModel task}) async {
    await _tasksRef(pairId).doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> deleteTask({required String pairId, required String taskId}) async {
    await _tasksRef(pairId).doc(taskId).delete();
  }
}
