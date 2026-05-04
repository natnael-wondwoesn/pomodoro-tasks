import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pomodoro_tasks/firebase_options.dart';
import 'package:pomodoro_tasks/app_shell.dart';
import 'package:pomodoro_tasks/core/theme/app_theme.dart';
import 'package:pomodoro_tasks/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pomodoro_tasks/features/auth/presentation/pages/login_page.dart';
import 'package:pomodoro_tasks/features/auth/presentation/pages/pair_setup_page.dart';
import 'package:pomodoro_tasks/features/quotes/presentation/bloc/quotes_bloc.dart';
import 'package:pomodoro_tasks/features/settings/domain/entities/app_settings.dart'
    as settings_entity;
import 'package:pomodoro_tasks/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:pomodoro_tasks/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:pomodoro_tasks/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:pomodoro_tasks/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  runApp(const PomodoroTasksApp());
}

class PomodoroTasksApp extends StatelessWidget {
  const PomodoroTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => di.sl<TimerBloc>()),
        BlocProvider(create: (_) => di.sl<TasksBloc>()),
        BlocProvider(create: (_) => di.sl<TimelineBloc>()),
        BlocProvider(create: (_) => di.sl<QuotesBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()..add(SettingsLoadRequested())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final themeMode = _mapThemeMode(settingsState.settings.themeMode);

          return MaterialApp(
            title: 'Pomodoro Tasks',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  if (!state.user.isPaired) {
                    return const PairSetupPage();
                  }
                  return AppShell(user: state.user);
                }
                if (state is AuthPairCreated) {
                  return const PairSetupPage();
                }
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }

  ThemeMode _mapThemeMode(settings_entity.ThemeMode mode) {
    switch (mode) {
      case settings_entity.ThemeMode.light:
        return ThemeMode.light;
      case settings_entity.ThemeMode.dark:
        return ThemeMode.dark;
      case settings_entity.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
