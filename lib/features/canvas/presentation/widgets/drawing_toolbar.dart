import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/bloc/drawing_bloc.dart';

class DrawingToolbar extends StatelessWidget {
  final String pairId;
  final String canvasId;
  final String userId;

  const DrawingToolbar({
    super.key,
    required this.pairId,
    required this.canvasId,
    required this.userId,
  });

  static const _colors = [
    '#5A3E2B', // dark brown
    '#C47F52', // warm orange
    '#D4956A', // light orange
    '#7B9E6B', // green
    '#4A90D9', // blue
    '#D94A4A', // red
    '#9B59B6', // purple
    '#2C3E50', // dark navy
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: BlocBuilder<DrawingBloc, DrawingState>(
          builder: (context, state) {
            return Row(
              children: [
                // Color picker
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colors.map((color) {
                        final isSelected =
                            state.selectedColor == color && !state.isEraser;
                        return GestureDetector(
                          onTap: () => context
                              .read<DrawingBloc>()
                              .add(DrawingColorChanged(color)),
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _hexToColor(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Stroke width toggle
                IconButton(
                  onPressed: () {
                    final newWidth = state.strokeWidth <= 3.0 ? 8.0 : 3.0;
                    context
                        .read<DrawingBloc>()
                        .add(DrawingStrokeWidthChanged(newWidth));
                  },
                  icon: Icon(
                    state.strokeWidth <= 3.0
                        ? Icons.edit_rounded
                        : Icons.brush_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: state.strokeWidth <= 3.0 ? 'Thick' : 'Thin',
                ),
                // Eraser
                IconButton(
                  onPressed: () =>
                      context.read<DrawingBloc>().add(DrawingEraserToggled()),
                  icon: Icon(
                    Icons.auto_fix_high_rounded,
                    color: state.isEraser ? Colors.amber : Colors.white,
                    size: 22,
                  ),
                  tooltip: 'Eraser',
                ),
                // Undo
                IconButton(
                  onPressed: () {
                    context.read<DrawingBloc>().add(DrawingUndoRequested(
                          pairId: pairId,
                          canvasId: canvasId,
                          userId: userId,
                        ));
                  },
                  icon: const Icon(
                    Icons.undo_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: 'Undo',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
