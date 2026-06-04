import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_tasks/core/notifications/notification_service.dart';

class NudgeService {
  NudgeService._();
  static final NudgeService instance = NudgeService._();

  StreamSubscription? _subscription;
  DateTime? _lastNudgeSent;

  static const _cooldownMinutes = 30;

  static const _playfulMessages = [
    "Hey, your pomodoros miss you!",
    "I see someone's taking a looong break...",
    "Race you to the next pomodoro?",
    "Your tasks are getting lonely over here",
    "Tick tock, no more procrastinating!",
    "I'm lapping you in pomodoros right now",
    "Did you forget about your goals?",
  ];

  static const _sweetMessages = [
    "You've got this! I believe in you",
    "Thinking of you, go crush that task!",
    "Proud of how hard you're working",
    "Sending focus energy your way",
    "You inspire me to work harder",
    "Just a little nudge because I care",
    "Go get it! I'm cheering you on",
  ];

  bool get canSendNudge {
    if (_lastNudgeSent == null) return true;
    return DateTime.now().difference(_lastNudgeSent!).inMinutes >= _cooldownMinutes;
  }

  int get cooldownRemainingMinutes {
    if (_lastNudgeSent == null) return 0;
    final elapsed = DateTime.now().difference(_lastNudgeSent!).inMinutes;
    return max(0, _cooldownMinutes - elapsed);
  }

  String get randomMessage {
    final allMessages = [..._playfulMessages, ..._sweetMessages];
    return allMessages[Random().nextInt(allMessages.length)];
  }

  Future<void> sendNudge({
    required String pairId,
    required String fromUserId,
    required String targetUserId,
  }) async {
    if (!canSendNudge) return;

    final message = randomMessage;

    await FirebaseFirestore.instance
        .collection('pairs')
        .doc(pairId)
        .collection('nudges')
        .add({
      'fromUserId': fromUserId,
      'targetUserId': targetUserId,
      'message': message,
      'sentAt': FieldValue.serverTimestamp(),
      'seen': false,
    });

    _lastNudgeSent = DateTime.now();
  }

  void startListening({
    required String pairId,
    required String currentUserId,
  }) {
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('pairs')
        .doc(pairId)
        .collection('nudges')
        .where('targetUserId', isEqualTo: currentUserId)
        .orderBy('sentAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['seen'] != true) {
            _showNudgeNotification(data['message'] as String? ?? 'Hey!');
            change.doc.reference.update({'seen': true});
          }
        }
      }
    }, onError: (error) {
      debugPrint('Nudge listener error: $error');
    });
  }

  void _showNudgeNotification(String message) {
    NotificationService.instance.showTimerComplete(
      title: 'Nudge from your partner',
      body: message,
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
