import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/pages/canvas_detail_page.dart';
import 'package:intl/intl.dart';

class CanvasGalleryPage extends StatelessWidget {
  final String pairId;
  final String userId;

  const CanvasGalleryPage({
    super.key,
    required this.pairId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CanvasBloc, CanvasState>(
      listener: (context, state) {
        if (state is CanvasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is CanvasCreated) {
          _openCanvas(context, state.canvas);
        }
      },
      buildWhen: (_, current) => current is CanvasLoaded || current is CanvasInitial,
      builder: (context, state) {
        final canvases = state is CanvasLoaded ? state.canvases : <SharedCanvas>[];

        return Stack(
          children: [
            canvases.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.brush_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No canvases yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a whiteboard or upload a photo',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: canvases.length,
                    itemBuilder: (context, index) {
                      return _CanvasCard(
                        canvas: canvases[index],
                        onTap: () => _openCanvas(context, canvases[index]),
                        onDelete: () {
                          context.read<CanvasBloc>().add(CanvasDeleteRequested(
                                pairId: pairId,
                                canvasId: canvases[index].id,
                              ));
                        },
                      );
                    },
                  ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _CreateFab(pairId: pairId, userId: userId),
            ),
          ],
        );
      },
    );
  }

  void _openCanvas(BuildContext context, SharedCanvas canvas) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CanvasDetailPage(
          canvas: canvas,
          pairId: pairId,
          userId: userId,
        ),
      ),
    );
  }
}

class _CanvasCard extends StatelessWidget {
  final SharedCanvas canvas;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CanvasCard({
    required this.canvas,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: canvas.imageUrl != null
                  ? Image.network(
                      canvas.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => _placeholderIcon(theme),
                    )
                  : Container(
                      color: Colors.white,
                      child: Icon(
                        Icons.draw_rounded,
                        size: 40,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canvas.title.isEmpty
                        ? (canvas.isWhiteboard ? 'Whiteboard' : 'Photo')
                        : canvas.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.MMMd().add_jm().format(canvas.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.image_rounded,
        size: 40,
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete canvas?'),
        content: const Text('This will permanently remove this canvas and all drawings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CreateFab extends StatelessWidget {
  final String pairId;
  final String userId;

  const _CreateFab({required this.pairId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'upload_photo',
          onPressed: () => _uploadPhoto(context),
          child: const Icon(Icons.photo_library_rounded),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'new_whiteboard',
          onPressed: () => _createWhiteboard(context),
          child: const Icon(Icons.draw_rounded),
        ),
      ],
    );
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!context.mounted) return;

    context.read<CanvasBloc>().add(CanvasCreateRequested(
          pairId: pairId,
          createdBy: userId,
          title: '',
          imageBytes: bytes,
        ));
  }

  void _createWhiteboard(BuildContext context) {
    context.read<CanvasBloc>().add(CanvasCreateRequested(
          pairId: pairId,
          createdBy: userId,
          title: '',
        ));
  }
}
