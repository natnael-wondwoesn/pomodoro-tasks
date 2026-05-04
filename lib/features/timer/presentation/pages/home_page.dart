import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/widgets/task_list_widget.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/widgets/partner_panel.dart';
import 'package:pomodoro_tasks/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:pomodoro_tasks/features/timer/presentation/widgets/timer_circle.dart';
import 'package:pomodoro_tasks/features/timer/presentation/widgets/timer_controls.dart';

class HomePage extends StatelessWidget {
  final String pairId;
  final String partnerName;

  const HomePage({super.key, required this.pairId, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use split layout on wider screens
          if (constraints.maxWidth > 600) {
            return _buildSplitLayout(context);
          }
          return _buildSingleColumnLayout(context);
        },
      ),
    );
  }

  Widget _buildSplitLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Timer + My Tasks
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTimerSection(context),
                const SizedBox(height: 24),
                _buildMyTasksSection(context),
              ],
            ),
          ),
        ),
        // Divider
        Container(width: 1, color: Theme.of(context).dividerColor),
        // Right: Partner Timeline
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PartnerPanel(partnerName: partnerName),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimerSection(context),
          const SizedBox(height: 20),
          _buildMyTasksSection(context),
          const SizedBox(height: 20),
          PartnerPanel(partnerName: partnerName),
        ],
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerBlocState>(
      builder: (context, state) {
        return Column(
          children: [
            TimerCircle(timerState: state.timerState),
            const SizedBox(height: 16),
            const TimerControls(),
          ],
        );
      },
    );
  }

  Widget _buildMyTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MY TASKS',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TaskListWidget(pairId: pairId, compact: true),
      ],
    );
  }
}
