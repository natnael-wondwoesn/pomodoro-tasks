import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/calendar/data/models/shared_event_model.dart';
import 'package:pomodoro_tasks/features/calendar/domain/entities/shared_event.dart';
import 'package:uuid/uuid.dart';

class CalendarPage extends StatelessWidget {
  final String pairId;
  final String userId;

  const CalendarPage({
    super.key,
    required this.pairId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isLight
              ? AppGradients.backgroundLight
              : AppGradients.backgroundDark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Our Calendar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pairs')
                      .doc(pairId)
                      .collection('events')
                      .orderBy('dateTime')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final events = (snapshot.data?.docs ?? [])
                        .map((doc) => SharedEventModel.fromFirestore(doc))
                        .toList();

                    if (events.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 64,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('No events yet',
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text('Plan something special together!',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _EventCard(event: events[index], pairId: pairId),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => _showAddEventSheet(context),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddEventSheet(pairId: pairId, userId: userId),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SharedEvent event;
  final String pairId;

  const _EventCard({required this.event, required this.pairId});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = event.dateTime.difference(now);
    final countdown = diff.isNegative
        ? 'Past'
        : diff.inDays > 0
            ? 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}'
            : diff.inHours > 0
                ? 'in ${diff.inHours}h'
                : 'Soon!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(event.categoryEmoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEE, MMM d \u2022 h:mm a').format(event.dateTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(event.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: diff.isNegative
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(countdown,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: diff.isNegative
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    )),
          ),
        ],
      ),
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  final String pairId;
  final String userId;

  const _AddEventSheet({required this.pairId, required this.userId});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  EventCategory _category = EventCategory.dateNight;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Event',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Event title'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(hintText: 'Description (optional)'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: EventCategory.values.map((cat) {
              final event = SharedEvent(
                id: '', title: '', dateTime: DateTime.now(),
                createdBy: '', createdAt: DateTime.now(), category: cat,
              );
              return ChoiceChip(
                label: Text('${event.categoryEmoji} ${event.categoryLabel}'),
                selected: _category == cat,
                onSelected: (_) => setState(() => _category = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(DateFormat('MMM d, y').format(_selectedDate)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(_selectedTime.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Add Event',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _submitting = true);

    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final model = SharedEventModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      dateTime: dateTime,
      category: _category,
      createdBy: widget.userId,
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('pairs')
        .doc(widget.pairId)
        .collection('events')
        .doc(model.id)
        .set(model.toFirestore());

    if (mounted) Navigator.pop(context);
  }
}
