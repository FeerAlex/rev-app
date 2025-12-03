import '../entities/faction_template.dart';
import '../entities/faction.dart';

/// Репозиторий для работы с шаблонами фракций
abstract class FactionTemplateRepository {
  /// Получить все шаблоны фракций
  List<FactionTemplate> getAllTemplates();

  /// Получить шаблон фракции по имени
  FactionTemplate? getTemplateByName(String name);

  /// Создать Faction entity из шаблона
  Faction createFactionFromTemplate(FactionTemplate template);
}

