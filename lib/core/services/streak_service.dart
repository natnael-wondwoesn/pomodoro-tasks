import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StreakData {
  final int current;
  final int best;
  final String lastActiveDate;

  const StreakData({
    this.current = 0,
    this.best = 0,
    this.lastActiveDate = '',
  });

  factory StreakData.fromMap(Map<String, dynamic> map) {
    return StreakData(
      current: map['current'] as int? ?? 0,
      best: map['best'] as int? ?? 0,
      lastActiveDate: map['lastActiveDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'current': current,
        'best': best,
        'lastActiveDate': lastActiveDate,
      };
}

class AllStreaks {
  final StreakData myStreak;
  final StreakData partnerStreak;
  final StreakData coupleStreak;

  const AllStreaks({
    this.myStreak = const StreakData(),
    this.partnerStreak = const StreakData(),
    this.coupleStreak = const StreakData(),
  });
}

class StreakService {
  StreakService._();
  static final StreakService instance = StreakService._();

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  Stream<AllStreaks> watchStreaks({
    required String pairId,
    required String userId,
    required String? partnerId,
  }) {
    return FirebaseFirestore.instance
        .collection('pairs')
        .doc(pairId)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? {};
      final streaks = data['streaks'] as Map<String, dynamic>? ?? {};

      return AllStreaks(
        myStreak: StreakData.fromMap(
            streaks[userId] as Map<String, dynamic>? ?? {}),
        partnerStreak: partnerId != null
            ? StreakData.fromMap(
                streaks[partnerId] as Map<String, dynamic>? ?? {})
            : const StreakData(),
        coupleStreak: StreakData.fromMap(
            streaks['couple'] as Map<String, dynamic>? ?? {}),
      );
    });
  }

  Future<void> recordPomodoroCompleted({
    required String pairId,
    required String userId,
  }) async {
    final today = _todayKey();
    final yesterday = _yesterdayKey();
    final pairRef =
        FirebaseFirestore.instance.collection('pairs').doc(pairId);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final doc = await tx.get(pairRef);
        final data = doc.data() ?? {};
        final streaks = Map<String, dynamic>.from(
            data['streaks'] as Map<String, dynamic>? ?? {});

        // Update individual streak
        final userStreakMap = Map<String, dynamic>.from(
            streaks[userId] as Map<String, dynamic>? ?? {});
        final userStreak = StreakData.fromMap(userStreakMap);

        final StreakData updatedUserStreak;
        if (userStreak.lastActiveDate == today) {
          // Already counted today
          updatedUserStreak = userStreak;
        } else if (userStreak.lastActiveDate == yesterday) {
          // Consecutive day
          final newCurrent = userStreak.current + 1;
          updatedUserStreak = StreakData(
            current: newCurrent,
            best: newCurrent > userStreak.best ? newCurrent : userStreak.best,
            lastActiveDate: today,
          );
        } else {
          // Streak broken, start fresh
          updatedUserStreak = StreakData(
            current: 1,
            best: userStreak.best > 0 ? userStreak.best : 1,
            lastActiveDate: today,
          );
        }
        streaks[userId] = updatedUserStreak.toMap();

        // Update couple streak
        // Check if partner was also active today
        final partnerEntries = streaks.entries
            .where((e) => e.key != userId && e.key != 'couple');
        bool partnerActiveToday = false;
        for (final entry in partnerEntries) {
          final partnerData =
              entry.value as Map<String, dynamic>? ?? {};
          if (partnerData['lastActiveDate'] == today) {
            partnerActiveToday = true;
            break;
          }
        }

        if (partnerActiveToday) {
          final coupleMap = Map<String, dynamic>.from(
              streaks['couple'] as Map<String, dynamic>? ?? {});
          final coupleStreak = StreakData.fromMap(coupleMap);

          final StreakData updatedCoupleStreak;
          if (coupleStreak.lastActiveDate == today) {
            updatedCoupleStreak = coupleStreak;
          } else if (coupleStreak.lastActiveDate == yesterday) {
            final newCurrent = coupleStreak.current + 1;
            updatedCoupleStreak = StreakData(
              current: newCurrent,
              best: newCurrent > coupleStreak.best
                  ? newCurrent
                  : coupleStreak.best,
              lastActiveDate: today,
            );
          } else {
            updatedCoupleStreak = StreakData(
              current: 1,
              best: coupleStreak.best > 0 ? coupleStreak.best : 1,
              lastActiveDate: today,
            );
          }
          streaks['couple'] = updatedCoupleStreak.toMap();
        }

        tx.update(pairRef, {'streaks': streaks});
      });
    } catch (e) {
      debugPrint('Streak update error: $e');
    }
  }
}
