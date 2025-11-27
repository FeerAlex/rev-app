import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_settings.dart';
import '../../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;

  SettingsBloc(
    this._getSettings,
    this._updateSettings,
  ) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _updateSettings(event.settings);
      final settings = await _getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}

