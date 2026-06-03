import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/notifications/notification_service.dart';
import 'package:pomodoro_tasks/features/settings/domain/entities/app_settings.dart';
import 'package:pomodoro_tasks/features/settings/domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdated>(_onUpdated);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final settings = await repository.getSettings();
    NotificationService.instance.setSoundEnabled(settings.soundEnabled);
    emit(SettingsState(settings: settings, isLoaded: true));
  }

  Future<void> _onUpdated(
    SettingsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    NotificationService.instance.setSoundEnabled(event.settings.soundEnabled);
    emit(SettingsState(settings: event.settings, isLoaded: true));
    await repository.saveSettings(event.settings);
  }
}
