import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/settings/domain/entities/app_settings.dart'
    as settings_entity;
import 'package:pomodoro_tasks/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final settings = state.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),

              // Theme
              _buildSection(context, 'Appearance', [
                _buildDropdown<settings_entity.ThemeMode>(
                  context,
                  'Theme',
                  settings.themeMode,
                  settings_entity.ThemeMode.values,
                  (value) => _update(context, settings.copyWith(themeMode: value)),
                ),
                _buildDropdown<settings_entity.LayoutDensity>(
                  context,
                  'Density',
                  settings.layoutDensity,
                  settings_entity.LayoutDensity.values,
                  (value) => _update(context, settings.copyWith(layoutDensity: value)),
                ),
                _buildSlider(
                  context,
                  'Font Size',
                  settings.fontSize,
                  0.8,
                  1.4,
                  (value) => _update(context, settings.copyWith(fontSize: value)),
                ),
              ]),

              // Timer
              _buildSection(context, 'Timer', [
                _buildDropdown<TimerMode>(
                  context,
                  'Mode',
                  settings.timerConfig.mode,
                  TimerMode.values,
                  (value) => _update(
                    context,
                    settings.copyWith(timerConfig: settings.timerConfig.copyWith(mode: value)),
                  ),
                ),
                _buildDurationRow(
                  context,
                  'Work Duration',
                  settings.timerConfig.workDuration.inMinutes,
                  (minutes) => _update(
                    context,
                    settings.copyWith(
                      timerConfig: settings.timerConfig.copyWith(
                        workDuration: Duration(minutes: minutes),
                      ),
                    ),
                  ),
                ),
                _buildDurationRow(
                  context,
                  'Short Break',
                  settings.timerConfig.shortBreakDuration.inMinutes,
                  (minutes) => _update(
                    context,
                    settings.copyWith(
                      timerConfig: settings.timerConfig.copyWith(
                        shortBreakDuration: Duration(minutes: minutes),
                      ),
                    ),
                  ),
                ),
                _buildDurationRow(
                  context,
                  'Long Break',
                  settings.timerConfig.longBreakDuration.inMinutes,
                  (minutes) => _update(
                    context,
                    settings.copyWith(
                      timerConfig: settings.timerConfig.copyWith(
                        longBreakDuration: Duration(minutes: minutes),
                      ),
                    ),
                  ),
                ),
              ]),

              // Quotes
              _buildSection(context, 'Quotes', [
                _buildDropdown<String>(
                  context,
                  'Language',
                  settings.quoteLanguage,
                  ['en', 'am'],
                  (value) => _update(context, settings.copyWith(quoteLanguage: value)),
                  labelBuilder: (v) => v == 'en' ? 'English' : 'Amharic',
                ),
              ]),

              // Sound
              _buildSection(context, 'Notifications', [
                SwitchListTile(
                  title: const Text('Sound'),
                  value: settings.soundEnabled,
                  onChanged: (value) =>
                      _update(context, settings.copyWith(soundEnabled: value)),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context,
    String label,
    T value,
    List<T> items,
    ValueChanged<T> onChanged, {
    String Function(T)? labelBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          DropdownButton<T>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(labelBuilder?.call(e) ?? e.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDurationRow(
    BuildContext context,
    String label,
    int minutes,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Row(
            children: [
              IconButton(
                onPressed: minutes > 1 ? () => onChanged(minutes - 1) : null,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
              ),
              Text('$minutes min'),
              IconButton(
                onPressed: () => onChanged(minutes + 1),
                icon: const Icon(Icons.add_circle_outline, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _update(BuildContext context, settings_entity.AppSettings settings) {
    context.read<SettingsBloc>().add(SettingsUpdated(settings));
  }
}
