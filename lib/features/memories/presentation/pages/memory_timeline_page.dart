import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/memories/data/models/memory_model.dart';
import 'package:pomodoro_tasks/features/memories/domain/entities/memory.dart'
    as entity;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Our Memories',
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
                            Icon(
                              Icons.favorite_rounded,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No memories yet',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Capture your first moment together!',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: memories.length,
                      itemBuilder: (context, index) {
                        final memory = memories[index];
                        final showDateHeader =
                            index == 0 ||
                            DateFormat('MMM y').format(memory.date) !=
                                DateFormat(
                                  'MMM y',
                                ).format(memories[index - 1].date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 12,
                                ),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(memory.date),
                                  style: Theme.of(context).textTheme.labelLarge
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
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openMemoryDetail(context),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (memory.imageUrl != null)
                  SizedBox(
                    height: 180,
                    child: Hero(
                      tag: _heroTag,
                      child: Image.network(
                        memory.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.image_rounded, size: 40),
                        ),
                      ),
                    ),
                  )
                else if (memory.imageBytes != null)
                  SizedBox(
                    height: 180,
                    child: Hero(
                      tag: _heroTag,
                      child: Image.memory(
                        memory.imageBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.image_rounded, size: 40),
                        ),
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
                            child: Text(
                              memory.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
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
                          child: Text(
                            memory.note!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _heroTag => 'memory-${memory.id}';

  void _openMemoryDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _MemoryDetailPage(memory: memory, heroTag: _heroTag),
      ),
    );
  }
}

class _MemoryDetailPage extends StatelessWidget {
  final entity.Memory memory;
  final String heroTag;

  const _MemoryDetailPage({required this.memory, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: _MemoryDetailImage(memory: memory),
                    ),
                  ),
                ),
                _MemoryDetailInfo(memory: memory),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryDetailImage extends StatelessWidget {
  final entity.Memory memory;

  const _MemoryDetailImage({required this.memory});

  @override
  Widget build(BuildContext context) {
    final imageUrl = memory.imageUrl;
    final imageBytes = memory.imageBytes;

    if (imageUrl != null) {
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const _MemoryImageFallback(),
        ),
      );
    }

    if (imageBytes != null) {
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const _MemoryImageFallback(),
        ),
      );
    }

    return const _MemoryImageFallback();
  }
}

class _MemoryImageFallback extends StatelessWidget {
  const _MemoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.favorite_rounded, color: Colors.white70, size: 72);
  }
}

class _MemoryDetailInfo extends StatelessWidget {
  final entity.Memory memory;

  const _MemoryDetailInfo({required this.memory});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              memory.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM d, yyyy').format(memory.date),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            if (memory.note != null && memory.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                memory.note!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
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
  static const int _maxInlineImageBytes = 850 * 1024;

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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Memory', style: Theme.of(context).textTheme.headlineSmall),
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
                  onPressed: _showImageSourcePicker,
                  icon: Icon(
                    _selectedImage != null
                        ? Icons.check_circle
                        : Icons.photo_camera,
                    size: 16,
                  ),
                  label: Text(
                    _selectedImage != null ? 'Photo added' : 'Add photo',
                  ),
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
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Memory',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Take photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 65,
    );
    if (image != null) setState(() => _selectedImage = image);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title before saving.')),
      );
      return;
    }
    setState(() => _submitting = true);

    try {
      final imageBytes = await _readSelectedImageBytes();
      if (!mounted) return;

      if (_selectedImage != null) {
        if (imageBytes == null) return;
      }

      final model = MemoryModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        imageBytes: imageBytes,
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
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save memory: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<Uint8List?> _readSelectedImageBytes() async {
    final image = _selectedImage;
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    if (bytes.length <= _maxInlineImageBytes) return bytes;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That photo is too large. Try taking it again or choose a smaller image.',
          ),
        ),
      );
    }
    return null;
  }
}
