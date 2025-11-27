import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_dao.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDao _dao;

  SettingsRepositoryImpl(this._dao);

  @override
  Future<Settings> getSettings() async {
    final map = await _dao.getSettings();
    if (map == null) {
      return Settings.defaultSettings;
    }
    return SettingsModel.fromMap(map);
  }

  @override
  Future<void> updateSettings(Settings settings) async {
    await _dao.updateSettings(SettingsModel.toMap(settings));
  }
}

