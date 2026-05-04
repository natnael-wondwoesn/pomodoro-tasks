import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pomodoro_tasks/core/theme/app_colors.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';

class TimerCircle extends StatelessWidget {
  final TimerStateEntity timerState;

  const TimerCircle({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _TimerPainter(
          progress: timerState.progress,
          type: timerState.type,
          brightness: Theme.of(context).brightness,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timerState.formattedTime,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                timerState.statusLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Round ${timerState.currentRound} of ${timerState.totalRounds}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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

    // Background circle
    final bgPaint = Paint()
      ..color = (brightness == Brightness.light
              ? AppColors.primaryLight
              : AppColors.primaryDark)
          .withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressColor = type == SessionType.work
        ? (brightness == Brightness.light ? AppColors.primaryLight : AppColors.primaryDark)
        : (brightness == Brightness.light ? AppColors.partnerLight : AppColors.partnerDark);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
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
