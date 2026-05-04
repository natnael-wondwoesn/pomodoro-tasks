import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/widgets/quote_card.dart';
import 'package:pomodoro_tasks/features/timer/presentation/pages/home_page.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/pages/tasks_page.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/pages/together_page.dart';
import 'package:pomodoro_tasks/features/settings/presentation/pages/settings_page.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:pomodoro_tasks/features/timer/presentation/bloc/timer_bloc.dart';

class AppShell extends StatefulWidget {
  final AppUser user;

  const AppShell({super.key, required this.user});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  void _initializeBlocs() {
    // Load quotes
    context.read<QuotesBloc>().add(const QuotesLoadDaily());

    // Set user for timer
    context.read<TimerBloc>().add(TimerUserSet(
          userId: widget.user.id,
          pairId: widget.user.pairId,
        ));

    // Load tasks
    if (widget.user.pairId != null) {
      context.read<TasksBloc>().add(TasksLoadRequested(
            pairId: widget.user.pairId!,
            userId: widget.user.id,
          ));

      // Load partner timeline
      if (widget.user.partnerId != null) {
        context.read<TimelineBloc>().add(TimelineLoadRequested(
              pairId: widget.user.pairId!,
              partnerId: widget.user.partnerId!,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isLight ? AppGradients.backgroundLight : AppGradients.backgroundDark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Bible quote (visible on Home, Tasks, Together)
              if (_currentIndex < 3) const QuoteCard(),

              // Page content
              Expanded(child: _buildPage()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: isLight
            ? Colors.white.withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Together'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          pairId: widget.user.pairId ?? '',
          partnerName: 'Partner',
        );
      case 1:
        return TasksPage(
          pairId: widget.user.pairId ?? '',
          userId: widget.user.id,
        );
      case 2:
        return TogetherPage(partnerName: 'Partner');
      case 3:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
