import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro_tasks/core/constants/app_constants.dart';
import 'package:pomodoro_tasks/features/roadmap/data/models/roadmap_goal_model.dart';
import 'package:pomodoro_tasks/features/roadmap/domain/entities/roadmap_goal.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  var _initialized = false;
  var _available = true;

  static const _quoteNotificationBaseId = 900000;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
      );
      await requestPermissions();
    } on MissingPluginException catch (error) {
      _available = false;
      debugPrint('Notifications unavailable until full app rebuild: $error');
    }

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || !_available) return;

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } on MissingPluginException catch (error) {
      _available = false;
      debugPrint('Notification permissions unavailable: $error');
    }
  }

  Future<void> scheduleBibleQuoteNotifications() async {
    if (kIsWeb) return;
    await init();
    if (!_available) return;

    const hours = [0, 6, 12, 18];
    for (var i = 0; i < hours.length; i++) {
      final quote = _quoteForSlot(i);
      await _plugin.zonedSchedule(
        id: _quoteNotificationBaseId + i,
        title: 'Bible verse',
        body: '${quote.text} - ${quote.reference}',
        scheduledDate: _nextTimeOfDay(hours[i]),
        notificationDetails: _quoteNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'quote:${quote.reference}',
      );
    }
  }

  Future<void> syncRoadmapDeadlineNotifications(String pairId) async {
    if (kIsWeb || pairId.isEmpty) return;
    await init();
    if (!_available) return;

    for (final roadmapId in const ['his', 'hers']) {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.pairsCollection)
          .doc(pairId)
          .collection('roadmaps')
          .doc(roadmapId)
          .collection('goals')
          .get();

      for (final doc in snapshot.docs) {
        final goal = RoadmapGoalModel.fromFirestore(doc);
        await scheduleRoadmapDeadline(
          pairId: pairId,
          roadmapId: roadmapId,
          goal: goal,
        );
      }
    }
  }

  Future<void> scheduleRoadmapDeadline({
    required String pairId,
    required String roadmapId,
    required RoadmapGoal goal,
  }) async {
    if (kIsWeb) return;
    await init();
    if (!_available) return;

    final notificationId = _deadlineNotificationId(pairId, roadmapId, goal.id);
    await _plugin.cancel(id: notificationId);

    final deadline = goal.deadlineAt;
    if (deadline == null ||
        !deadline.isAfter(DateTime.now()) ||
        goal.status != RoadmapGoalStatus.todo) {
      return;
    }

    await _plugin.zonedSchedule(
      id: notificationId,
      title: _deadlineTitle(roadmapId),
      body: goal.title,
      scheduledDate: tz.TZDateTime.from(deadline, tz.local),
      notificationDetails: _deadlineNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: 'roadmap:$pairId:$roadmapId:${goal.id}',
    );
  }

  int _deadlineNotificationId(String pairId, String roadmapId, String goalId) {
    return 100000 + _stableHash('$pairId:$roadmapId:$goalId') % 700000;
  }

  int _stableHash(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  String _deadlineTitle(String roadmapId) {
    return switch (roadmapId) {
      'his' => 'His roadmap deadline',
      'hers' => 'Hers roadmap deadline',
      _ => 'Roadmap deadline',
    };
  }

  tz.TZDateTime _nextTimeOfDay(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  _QuoteNotification _quoteForSlot(int slot) {
    final index = (DateTime.now().day + slot) % _quoteNotifications.length;
    return _quoteNotifications[index];
  }

  NotificationDetails get _deadlineNotificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'roadmap_deadlines',
        'Roadmap deadlines',
        channelDescription: 'Reminders for His and Hers roadmap deadlines',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }

  NotificationDetails get _quoteNotificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'bible_quotes',
        'Bible quotes',
        channelDescription: 'Bible verse reminders every six hours',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }
}

class _QuoteNotification {
  final String text;
  final String reference;

  const _QuoteNotification(this.text, this.reference);
}

const _quoteNotifications = [
  _QuoteNotification(
    'Commit your work to the Lord, and your plans will be established.',
    'Proverbs 16:3',
  ),
  _QuoteNotification(
    'I can do all things through Christ who strengthens me.',
    'Philippians 4:13',
  ),
  _QuoteNotification(
    'Be strong and courageous. Do not be afraid.',
    'Joshua 1:9',
  ),
  _QuoteNotification('Let us not become weary in doing good.', 'Galatians 6:9'),
  _QuoteNotification('Be still, and know that I am God.', 'Psalm 46:10'),
  _QuoteNotification('The joy of the Lord is your strength.', 'Nehemiah 8:10'),
];
