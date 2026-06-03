import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pomodoro_tasks/features/calendar/domain/entities/shared_event.dart';

class SharedEventModel extends SharedEvent {
  const SharedEventModel({
    required super.id,
    required super.title,
    super.description,
    required super.dateTime,
    super.category,
    required super.createdBy,
    required super.createdAt,
    super.reminderMinutesBefore,
  });

  factory SharedEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SharedEventModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: _parseCategory(data['category'] as String?),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reminderMinutesBefore: data['reminderMinutesBefore'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'category': category.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  static EventCategory _parseCategory(String? value) {
    return EventCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventCategory.other,
    );
  }
}
