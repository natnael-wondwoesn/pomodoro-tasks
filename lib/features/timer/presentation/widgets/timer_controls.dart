import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';
import 'package:pomodoro_tasks/features/timer/presentation/bloc/timer_bloc.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerBlocState>(
      builder: (context, state) {
        final timerState = state.timerState;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timerState.status == TimerStatus.idle)
              _buildButton(
                context,
                icon: Icons.play_arrow_rounded,
                label: 'Start',
                onPressed: () => context.read<TimerBloc>().add(const TimerStarted()),
              ),
            if (timerState.status == TimerStatus.running) ...[
              _buildButton(
                context,
                icon: Icons.pause_rounded,
                label: 'Pause',
                onPressed: () => context.read<TimerBloc>().add(TimerPaused()),
              ),
              const SizedBox(width: 12),
              _buildButton(
                context,
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                onPressed: () => context.read<TimerBloc>().add(TimerSkipped()),
                secondary: true,
              ),
            ],
            if (timerState.status == TimerStatus.paused) ...[
              _buildButton(
                context,
                icon: Icons.play_arrow_rounded,
                label: 'Resume',
                onPressed: () => context.read<TimerBloc>().add(TimerResumed()),
              ),
              const SizedBox(width: 12),
              _buildButton(
                context,
                icon: Icons.stop_rounded,
                label: 'Reset',
                onPressed: () => context.read<TimerBloc>().add(TimerReset()),
                secondary: true,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool secondary = false,
  }) {
    if (secondary) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
