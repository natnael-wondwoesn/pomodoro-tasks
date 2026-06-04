import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  var _soundEnabled = true;

  static const _quoteNotificationBaseId = 900000;
  static const _timerNotificationId = 800000;

  Future<bool> init() async {
    if (_initialized) return true;
    if (kIsWeb) return false;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    try {
      final result = await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
      );
      debugPrint('NotificationService.init: initialize returned $result');

      _initialized = true;
      await requestPermissions();
      return true;
    } catch (error) {
      debugPrint('NotificationService.init FAILED: $error');
      return false;
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        debugPrint('NotificationService: Android permission granted=$granted');
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('NotificationService: iOS permission granted=$granted');
      }

      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macos != null) {
        final granted = await macos.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('NotificationService: macOS permission granted=$granted');
      }
    } catch (error) {
      debugPrint('NotificationService: permission request failed: $error');
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> showTimerComplete({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    if (!await init()) {
      debugPrint('NotificationService.showTimerComplete: init failed, skipping');
      return;
    }

    try {
      await _plugin.show(
        id: _timerNotificationId,
        title: title,
        body: body,
        notificationDetails: _timerNotificationDetails,
        payload: 'timer',
      );
      debugPrint('NotificationService.showTimerComplete: notification shown');
    } catch (error) {
      debugPrint('NotificationService.showTimerComplete FAILED: $error');
    }
  }

  Future<void> scheduleBibleQuoteNotifications() async {
    if (kIsWeb) return;
    if (!await init()) return;

    try {
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
      debugPrint('NotificationService: Bible quote notifications scheduled');
    } catch (error) {
      debugPrint('NotificationService.scheduleBibleQuote FAILED: $error');
    }
  }

  Future<void> syncRoadmapDeadlineNotifications(String pairId) async {
    if (kIsWeb || pairId.isEmpty) return;
    if (!await init()) return;

    try {
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
    } catch (error) {
      debugPrint('NotificationService.syncRoadmapDeadline FAILED: $error');
    }
  }

  Future<void> scheduleRoadmapDeadline({
    required String pairId,
    required String roadmapId,
    required RoadmapGoal goal,
  }) async {
    if (kIsWeb) return;
    if (!await init()) return;

    final notificationId = _deadlineNotificationId(pairId, roadmapId, goal.id);

    try {
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
    } catch (error) {
      debugPrint('NotificationService.scheduleRoadmapDeadline FAILED: $error');
    }
  }

  Future<void> cancelRoadmapDeadline({
    required String pairId,
    required String roadmapId,
    required String goalId,
  }) async {
    if (kIsWeb) return;
    if (!await init()) return;

    try {
      await _plugin.cancel(
        id: _deadlineNotificationId(pairId, roadmapId, goalId),
      );
    } catch (error) {
      debugPrint('NotificationService.cancelRoadmapDeadline FAILED: $error');
    }
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

  NotificationDetails get _timerNotificationDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'timer_alerts',
        'Timer alerts',
        channelDescription: 'Pomodoro timer completion alerts',
        importance: Importance.high,
        priority: Priority.high,
        playSound: _soundEnabled,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _soundEnabled,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _soundEnabled,
      ),
    );
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
