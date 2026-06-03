enum EventCategory { dateNight, appointment, milestone, other }

class SharedEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final EventCategory category;
  final String createdBy;
  final DateTime createdAt;
  final int? reminderMinutesBefore;

  const SharedEvent({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.category = EventCategory.other,
    required this.createdBy,
    required this.createdAt,
    this.reminderMinutesBefore,
  });

  String get categoryEmoji => switch (category) {
        EventCategory.dateNight => '\u{1F491}',
        EventCategory.appointment => '\u{1F4CB}',
        EventCategory.milestone => '\u2B50',
        EventCategory.other => '\u{1F4CC}',
      };

  String get categoryLabel => switch (category) {
        EventCategory.dateNight => 'Date Night',
        EventCategory.appointment => 'Appointment',
        EventCategory.milestone => 'Milestone',
        EventCategory.other => 'Other',
      };
}
