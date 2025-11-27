import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettings {
  final SettingsRepository repository;

  UpdateSettings(this.repository);

  Future<void> call(Settings settings) async {
    return await repository.updateSettings(settings);
  }
}

