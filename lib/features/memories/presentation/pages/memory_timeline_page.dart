import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/memories/data/models/memory_model.dart';
import 'package:pomodoro_tasks/features/memories/domain/entities/memory.dart' as entity;
import 'package:uuid/uuid.dart';

class MemoryTimelinePage extends StatelessWidget {
  final String pairId;
  final String userId;

  const MemoryTimelinePage({
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
                    Text('Our Memories',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pairs')
                      .doc(pairId)
                      .collection('memories')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final memories = (snapshot.data?.docs ?? [])
                        .map((doc) => MemoryModel.fromFirestore(doc))
                        .toList();

                    if (memories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: 64,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text('No memories yet',
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                                'Capture your first moment together!',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: memories.length,
                      itemBuilder: (context, index) {
                        final memory = memories[index];
                        final showDateHeader = index == 0 ||
                            DateFormat('MMM y').format(memory.date) !=
                                DateFormat('MMM y')
                                    .format(memories[index - 1].date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, bottom: 12),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(memory.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(letterSpacing: 1),
                                ),
                              ),
                            _MemoryCard(memory: memory, pairId: pairId),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
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
          onPressed: () => _showAddMemorySheet(context),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _showAddMemorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddMemorySheet(pairId: pairId, userId: userId),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final entity.Memory memory;
  final String pairId;

  const _MemoryCard({required this.memory, required this.pairId});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (memory.imageUrl != null)
            SizedBox(
              height: 180,
              child: Image.network(
                memory.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: const Icon(Icons.image_rounded, size: 40),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(memory.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      DateFormat('MMM d').format(memory.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (memory.note != null && memory.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(memory.note!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemorySheet extends StatefulWidget {
  final String pairId;
  final String userId;

  const _AddMemorySheet({required this.pairId, required this.userId});

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  XFile? _selectedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
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
          Text('Add Memory',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Memory title'),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'Note (optional)'),
            maxLines: 3,
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
                  onPressed: _pickImage,
                  icon: Icon(
                    _selectedImage != null
                        ? Icons.check_circle
                        : Icons.photo_camera,
                    size: 16,
                  ),
                  label: Text(
                      _selectedImage != null ? 'Photo added' : 'Add photo'),
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
                  : const Text('Save Memory',
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
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _submitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final ref = FirebaseStorage.instance
            .ref('pairs/${widget.pairId}/memories/${const Uuid().v4()}.jpg');
        await ref.putData(bytes);
        imageUrl = await ref.getDownloadURL();
      }

      final model = MemoryModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        imageUrl: imageUrl,
        date: _selectedDate,
        createdBy: widget.userId,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('pairs')
          .doc(widget.pairId)
          .collection('memories')
          .doc(model.id)
          .set(model.toFirestore());

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
