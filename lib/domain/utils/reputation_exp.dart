import '../entities/reputation_level.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/faction_template_repository.dart';

/// Константы опыта, требуемого для достижения уровней отношения
class ReputationExp {
  final AppSettingsRepository _settingsRepository;
  final FactionTemplateRepository _templateRepository;

  ReputationExp(this._settingsRepository, this._templateRepository);

  /// Получить требуемый опыт для уровня с учетом особых значений для некоторых фракций
  int getExpForLevel(ReputationLevel level, String factionName) {
    final template = _templateRepository.getTemplateByName(factionName);
    final hasSpecialExp = template?.hasSpecialExp ?? false;
    final levelIndex = _getLevelIndex(level);

    return _settingsRepository.getExpForLevel(factionName, levelIndex, hasSpecialExp);
  }

  /// Получить общий опыт, необходимый для достижения уровня (сумма всех предыдущих уровней)
  int getTotalExpForLevel(ReputationLevel level, String factionName) {
    final template = _templateRepository.getTemplateByName(factionName);
    final hasSpecialExp = template?.hasSpecialExp ?? false;
    final levelIndex = _getLevelIndex(level);

    return _settingsRepository.getTotalExpForLevel(factionName, levelIndex, hasSpecialExp);
  }

  int _getLevelIndex(ReputationLevel level) {
    switch (level) {
      case ReputationLevel.indifference:
        return 0;
      case ReputationLevel.friendliness:
        return 1;
      case ReputationLevel.respect:
        return 2;
      case ReputationLevel.honor:
        return 3;
      case ReputationLevel.adoration:
        return 4;
      case ReputationLevel.deification:
        return 5;
      case ReputationLevel.maximum:
        return 5; // Максимальный уровень - это достижение Обожествления
    }
  }
}

