import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/notifications/notification_service.dart';
import 'package:pomodoro_tasks/core/services/nudge_service.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/core/widgets/app_logo.dart';
import 'package:pomodoro_tasks/features/auth/domain/entities/app_user.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/widgets/quote_card.dart';
import 'package:pomodoro_tasks/features/timer/presentation/pages/home_page.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/pages/tasks_page.dart';
import 'package:pomodoro_tasks/features/roadmap/presentation/pages/roadmap_page.dart';
import 'package:pomodoro_tasks/features/calendar/presentation/pages/calendar_page.dart';
import 'package:pomodoro_tasks/features/date_ideas/presentation/pages/date_ideas_page.dart';
import 'package:pomodoro_tasks/features/memories/presentation/pages/memory_timeline_page.dart';
import 'package:pomodoro_tasks/features/quizzes/presentation/pages/quiz_list_page.dart';
import 'package:pomodoro_tasks/features/settings/presentation/pages/settings_page.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/pages/canvas_gallery_page.dart';
import 'package:pomodoro_tasks/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:pomodoro_tasks/features/settings/presentation/bloc/settings_bloc.dart';
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

  static const _tabTitles = ['Home', 'Tasks', 'Roadmap', 'Canvas'];

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  void _initializeBlocs() {
    context.read<QuotesBloc>().add(const QuotesLoadDaily());

    context.read<TimerBloc>().add(
      TimerUserSet(userId: widget.user.id, pairId: widget.user.pairId),
    );

    // Sync initial timer config from settings
    final settings = context.read<SettingsBloc>().state.settings;
    context.read<TimerBloc>().add(TimerConfigUpdated(settings.timerConfig));

    if (widget.user.pairId != null) {
      context.read<TasksBloc>().add(
        TasksLoadRequested(pairId: widget.user.pairId!, userId: widget.user.id),
      );

      context.read<CanvasBloc>().add(
        CanvasLoadRequested(pairId: widget.user.pairId!),
      );

      NotificationService.instance.syncRoadmapDeadlineNotifications(
        widget.user.pairId!,
      );

      // Start listening for nudge notifications
      NudgeService.instance.startListening(
        pairId: widget.user.pairId!,
        currentUserId: widget.user.id,
      );

      if (widget.user.partnerId != null) {
        context.read<TimelineBloc>().add(
          TimelineLoadRequested(
            pairId: widget.user.pairId!,
            partnerId: widget.user.partnerId!,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) =>
          prev.settings.timerConfig != curr.settings.timerConfig,
      listener: (context, state) {
        context.read<TimerBloc>().add(
          TimerConfigUpdated(state.settings.timerConfig),
        );
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isLight
                ? AppGradients.backgroundLight
                : AppGradients.backgroundDark,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const AppLogo(size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _tabTitles[_currentIndex],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 22,
                        ),
                        tooltip: 'Calendar',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CalendarPage(
                              pairId: widget.user.pairId ?? '',
                              userId: widget.user.id,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, size: 22),
                        tooltip: 'Memories',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemoryTimelinePage(
                              pairId: widget.user.pairId ?? '',
                              userId: widget.user.id,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lightbulb_rounded, size: 22),
                        tooltip: 'Date Ideas',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DateIdeasPage(pairId: widget.user.pairId ?? ''),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.psychology_rounded, size: 22),
                        tooltip: 'Quizzes',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizListPage(
                              pairId: widget.user.pairId ?? '',
                              userId: widget.user.id,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, size: 22),
                        tooltip: 'Settings',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quote card on Home only
                if (_currentIndex == 0) const QuoteCard(),

                // Page content with fade transition
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: isLight
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.black.withValues(alpha: 0.3),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_rounded),
              label: 'Roadmap',
            ),
            NavigationDestination(
              icon: Icon(Icons.brush_rounded),
              label: 'Canvas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          key: const ValueKey('home'),
          pairId: widget.user.pairId ?? '',
          userId: widget.user.id,
          partnerId: widget.user.partnerId,
          partnerName: 'Partner',
          onOpenTasks: () => setState(() => _currentIndex = 1),
        );
      case 1:
        return TasksPage(
          key: const ValueKey('tasks'),
          pairId: widget.user.pairId ?? '',
          userId: widget.user.id,
        );
      case 2:
        return RoadmapPage(
          key: const ValueKey('roadmap'),
          pairId: widget.user.pairId ?? '',
          userId: widget.user.id,
          partnerId: widget.user.partnerId,
        );
      case 3:
        return CanvasGalleryPage(
          key: const ValueKey('canvas'),
          pairId: widget.user.pairId ?? '',
          userId: widget.user.id,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
