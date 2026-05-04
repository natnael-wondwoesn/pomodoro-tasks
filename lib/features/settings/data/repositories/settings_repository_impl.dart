import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_tasks/features/settings/domain/entities/app_settings.dart';
import 'package:pomodoro_tasks/features/settings/domain/repositories/settings_repository.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_config.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences preferences;
  static const _settingsKey = 'app_settings';

  SettingsRepositoryImpl({required this.preferences});

  @override
  Future<AppSettings> getSettings() async {
    final json = preferences.getString(_settingsKey);
    if (json == null) return const AppSettings();

    final data = jsonDecode(json) as Map<String, dynamic>;
    return AppSettings(
      themeMode: ThemeMode.values[data['themeMode'] ?? 0],
      accentColorIndex: data['accentColorIndex'] ?? 0,
      fontSize: (data['fontSize'] ?? 1.0).toDouble(),
      layoutDensity: LayoutDensity.values[data['layoutDensity'] ?? 1],
      timerStyle: TimerStyle.values[data['timerStyle'] ?? 0],
      quoteLanguage: data['quoteLanguage'] ?? 'en',
      soundEnabled: data['soundEnabled'] ?? true,
      timerConfig: PomodoroConfig(
        workDuration: Duration(minutes: data['workMinutes'] ?? 25),
        shortBreakDuration: Duration(minutes: data['shortBreakMinutes'] ?? 5),
        longBreakDuration: Duration(minutes: data['longBreakMinutes'] ?? 15),
        roundsBeforeLongBreak: data['rounds'] ?? 4,
        mode: TimerMode.values[data['timerMode'] ?? 0],
      ),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final data = {
      'themeMode': settings.themeMode.index,
      'accentColorIndex': settings.accentColorIndex,
      'fontSize': settings.fontSize,
      'layoutDensity': settings.layoutDensity.index,
      'timerStyle': settings.timerStyle.index,
      'quoteLanguage': settings.quoteLanguage,
      'soundEnabled': settings.soundEnabled,
      'workMinutes': settings.timerConfig.workDuration.inMinutes,
      'shortBreakMinutes': settings.timerConfig.shortBreakDuration.inMinutes,
      'longBreakMinutes': settings.timerConfig.longBreakDuration.inMinutes,
      'rounds': settings.timerConfig.roundsBeforeLongBreak,
      'timerMode': settings.timerConfig.mode.index,
    };
    await preferences.setString(_settingsKey, jsonEncode(data));
  }
}
