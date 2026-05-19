import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/shared_canvas.dart';
import 'package:pomodoro_tasks/features/canvas/domain/entities/stroke.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/bloc/drawing_bloc.dart';
import 'package:uuid/uuid.dart';

class DrawingCanvas extends StatefulWidget {
  final SharedCanvas canvas;
  final String pairId;
  final String userId;

  const DrawingCanvas({
    super.key,
    required this.canvas,
    required this.pairId,
    required this.userId,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<StrokePoint> _currentPoints = [];
  Size _canvasSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: ClipRect(
            child: BlocBuilder<DrawingBloc, DrawingState>(
              builder: (context, state) {
                return CustomPaint(
                  size: _canvasSize,
                  painter: _CanvasPainter(
                    remoteStrokes: state.remoteStrokes,
                    currentPoints: _currentPoints,
                    currentColor: state.selectedColor,
                    currentStrokeWidth: state.strokeWidth,
                    isEraser: state.isEraser,
                    backgroundImage: widget.canvas.imageUrl,
                  ),
                  isComplex: true,
                  willChange: true,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = _normalizePoint(details.localPosition);
    setState(() {
      _currentPoints = [point];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = _normalizePoint(details.localPosition);
    setState(() {
      _currentPoints = [..._currentPoints, point];
    });
    context.read<DrawingBloc>().add(DrawingLocalStrokeUpdated(_currentPoints));
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.isEmpty) return;

    final state = context.read<DrawingBloc>().state;
    final stroke = Stroke(
      id: const Uuid().v4(),
      points: List.from(_currentPoints),
      color: state.isEraser ? '#FFFFFF' : state.selectedColor,
      strokeWidth: state.strokeWidth,
      isEraser: state.isEraser,
      createdBy: widget.userId,
      timestamp: DateTime.now(),
    );

    context.read<DrawingBloc>().add(DrawingStrokeFinished(
          pairId: widget.pairId,
          canvasId: widget.canvas.id,
          stroke: stroke,
        ));

    setState(() {
      _currentPoints = [];
    });
  }

  StrokePoint _normalizePoint(Offset position) {
    return StrokePoint(
      position.dx / _canvasSize.width,
      position.dy / _canvasSize.height,
    );
  }
}

Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

class _CanvasPainter extends CustomPainter {
  final List<Stroke> remoteStrokes;
  final List<StrokePoint> currentPoints;
  final String currentColor;
  final double currentStrokeWidth;
  final bool isEraser;
  final String? backgroundImage;

  _CanvasPainter({
    required this.remoteStrokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.isEraser,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // White background for whiteboard mode
    if (backgroundImage == null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white,
      );
    }

    // Draw remote strokes
    for (final stroke in remoteStrokes) {
      _drawStroke(canvas, size, stroke.points, stroke.color,
          stroke.strokeWidth, stroke.isEraser);
    }

    // Draw current in-progress stroke
    if (currentPoints.isNotEmpty) {
      _drawStroke(canvas, size, currentPoints,
          isEraser ? '#FFFFFF' : currentColor, currentStrokeWidth, isEraser);
    }
  }

  void _drawStroke(Canvas canvas, Size size, List<StrokePoint> points,
      String color, double width, bool eraser) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = _hexToColor(color)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (eraser) {
      paint.blendMode = BlendMode.clear;
    }

    final path = Path();
    final first = _denormalize(points[0], size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < points.length; i++) {
      final p = _denormalize(points[i], size);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, paint);
  }

  Offset _denormalize(StrokePoint point, Size size) {
    return Offset(point.x * size.width, point.y * size.height);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}
