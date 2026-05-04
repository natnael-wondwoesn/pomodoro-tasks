part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class SettingsUpdated extends SettingsEvent {
  final AppSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}
