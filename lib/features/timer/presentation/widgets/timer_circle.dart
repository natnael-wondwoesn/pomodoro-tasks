import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

class TimerCircle extends StatefulWidget {
  final TimerStateEntity timerState;

  const TimerCircle({super.key, required this.timerState});

  @override
  State<TimerCircle> createState() => _TimerCircleState();
}

class _TimerCircleState extends State<TimerCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TimerCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timerState.status == TimerStatus.running &&
        widget.timerState.status == TimerStatus.idle) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: _TimerPainter(
            progress: widget.timerState.progress,
            type: widget.timerState.type,
            brightness: Theme.of(context).brightness,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.timerState.formattedTime,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Round ${widget.timerState.currentRound} of ${widget.timerState.totalRounds}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final SessionType type;
  final Brightness brightness;

  _TimerPainter({
    required this.progress,
    required this.type,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = (brightness == Brightness.light
              ? AppColors.primaryLight
              : AppColors.primaryDark)
          .withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    final progressColor = type == SessionType.work
        ? (brightness == Brightness.light ? AppColors.primaryLight : AppColors.primaryDark)
        : (brightness == Brightness.light ? AppColors.partnerLight : AppColors.partnerDark);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.type != type;
  }
}
