import 'package:equatable/equatable.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_config.dart';

enum ThemeMode { light, dark, system }
enum LayoutDensity { compact, comfortable, spacious }
enum TimerStyle { circular, linear, minimal }

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final int accentColorIndex;
  final double fontSize;
  final LayoutDensity layoutDensity;
  final TimerStyle timerStyle;
  final String quoteLanguage;
  final bool soundEnabled;
  final PomodoroConfig timerConfig;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.accentColorIndex = 0,
    this.fontSize = 1.0,
    this.layoutDensity = LayoutDensity.comfortable,
    this.timerStyle = TimerStyle.circular,
    this.quoteLanguage = 'en',
    this.soundEnabled = true,
    this.timerConfig = const PomodoroConfig(),
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? accentColorIndex,
    double? fontSize,
    LayoutDensity? layoutDensity,
    TimerStyle? timerStyle,
    String? quoteLanguage,
    bool? soundEnabled,
    PomodoroConfig? timerConfig,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      fontSize: fontSize ?? this.fontSize,
      layoutDensity: layoutDensity ?? this.layoutDensity,
      timerStyle: timerStyle ?? this.timerStyle,
      quoteLanguage: quoteLanguage ?? this.quoteLanguage,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      timerConfig: timerConfig ?? this.timerConfig,
    );
  }

  @override
  List<Object?> get props => [
        themeMode, accentColorIndex, fontSize, layoutDensity,
        timerStyle, quoteLanguage, soundEnabled, timerConfig,
      ];
}
