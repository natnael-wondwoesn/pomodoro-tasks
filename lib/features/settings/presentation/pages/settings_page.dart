import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_tasks/core/theme/app_gradients.dart';
import 'package:pomodoro_tasks/features/settings/domain/entities/app_settings.dart'
    as settings_entity;
import 'package:pomodoro_tasks/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_config.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isLight
              ? AppGradients.backgroundLight
              : AppGradients.backgroundDark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final settings = state.settings;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _buildSection(context, 'Appearance', [
                          _buildDropdown<settings_entity.ThemeMode>(
                            context,
                            'Theme',
                            settings.themeMode,
                            settings_entity.ThemeMode.values,
                            (value) => _update(
                              context,
                              settings.copyWith(themeMode: value),
                            ),
                          ),
                          _buildDropdown<settings_entity.LayoutDensity>(
                            context,
                            'Density',
                            settings.layoutDensity,
                            settings_entity.LayoutDensity.values,
                            (value) => _update(
                              context,
                              settings.copyWith(layoutDensity: value),
                            ),
                          ),
                          _buildSlider(
                            context,
                            'Font Size',
                            settings.fontSize,
                            0.8,
                            1.4,
                            (value) => _update(
                              context,
                              settings.copyWith(fontSize: value),
                            ),
                          ),
                        ]),

                        _buildSection(context, 'Timer', [
                          _buildDropdown<TimerMode>(
                            context,
                            'Mode',
                            settings.timerConfig.mode,
                            TimerMode.values,
                            (value) => _update(
                              context,
                              settings.copyWith(
                                timerConfig: settings.timerConfig.copyWith(
                                  mode: value,
                                ),
                              ),
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
                                  shortBreakDuration: Duration(
                                    minutes: minutes,
                                  ),
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

                        _buildSection(context, 'Quotes', [
                          _buildDropdown<String>(
                            context,
                            'Language',
                            settings.quoteLanguage,
                            ['en', 'am'],
                            (value) => _update(
                              context,
                              settings.copyWith(quoteLanguage: value),
                            ),
                            labelBuilder: (v) =>
                                v == 'en' ? 'English' : 'Amharic',
                          ),
                        ]),

                        _buildSection(context, 'Notifications', [
                          SwitchListTile(
                            title: const Text('Sound'),
                            value: settings.soundEnabled,
                            onChanged: (value) => _update(
                              context,
                              settings.copyWith(soundEnabled: value),
                            ),
                          ),
                        ]),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
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
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      labelBuilder?.call(e) ?? e.toString().split('.').last,
                    ),
                  ),
                )
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
    const minMinutes = 1;
    const maxMinutes = 240;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: minutes > minMinutes
                    ? () => onChanged(minutes - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
              ),
              SizedBox(
                width: 92,
                child: TextFormField(
                  key: ValueKey('$label-$minutes'),
                  initialValue: minutes.toString(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    suffixText: 'min',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  onFieldSubmitted: (value) => _submitMinutes(
                    context,
                    value,
                    minutes,
                    onChanged,
                    minMinutes,
                    maxMinutes,
                  ),
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                ),
              ),
              IconButton(
                onPressed: minutes < maxMinutes
                    ? () => onChanged(minutes + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitMinutes(
    BuildContext context,
    String value,
    int fallback,
    ValueChanged<int> onChanged,
    int min,
    int max,
  ) {
    final parsed = int.tryParse(value);
    final minutes = (parsed ?? fallback).clamp(min, max);
    onChanged(minutes);

    if (parsed != null && parsed != minutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timer duration must be $min-$max minutes.')),
      );
    }
  }

  void _update(BuildContext context, settings_entity.AppSettings settings) {
    context.read<SettingsBloc>().add(SettingsUpdated(settings));
  }
}
