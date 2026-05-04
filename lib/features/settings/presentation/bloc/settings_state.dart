part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final AppSettings settings;
  final bool isLoaded;

  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoaded = false,
  });

  @override
  List<Object?> get props => [settings, isLoaded];
}
