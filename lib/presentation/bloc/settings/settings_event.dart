import 'package:equatable/equatable.dart';
import '../../../domain/entities/settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateSettingsEvent extends SettingsEvent {
  final Settings settings;

  const UpdateSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

