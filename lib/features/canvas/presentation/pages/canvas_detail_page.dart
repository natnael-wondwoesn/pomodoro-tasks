import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/repositories/canvas_repository.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/bloc/drawing_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/widgets/drawing_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/widgets/drawing_toolbar.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/add_stroke.dart';
import 'package:pomodoro_tasks/features/canvas/domain/usecases/undo_stroke.dart';
import 'package:pomodoro_tasks/injection_container.dart' as di;

class CanvasDetailPage extends StatelessWidget {
  final SharedCanvas canvas;
  final String pairId;
  final String userId;

  const CanvasDetailPage({
    super.key,
    required this.canvas,
    required this.pairId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = DrawingBloc(
          addStrokeUseCase: di.sl<AddStroke>(),
          undoStrokeUseCase: di.sl<UndoStroke>(),
        );
        final strokesStream = di.sl<CanvasRepository>().getStrokes(
              pairId: pairId,
              canvasId: canvas.id,
            );
        bloc.add(DrawingStartListening(strokesStream));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            canvas.title.isEmpty
                ? (canvas.isWhiteboard ? 'Whiteboard' : 'Photo')
                : canvas.title,
          ),
          actions: [
            BlocBuilder<DrawingBloc, DrawingState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<DrawingBloc>().add(DrawingUndoRequested(
                          pairId: pairId,
                          canvasId: canvas.id,
                          userId: userId,
                        ));
                  },
                  icon: const Icon(Icons.undo_rounded),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: DrawingCanvas(
                canvas: canvas,
                pairId: pairId,
                userId: userId,
              ),
            ),
            DrawingToolbar(
              pairId: pairId,
              canvasId: canvas.id,
              userId: userId,
            ),
          ],
        ),
      ),
    );
  }
}
