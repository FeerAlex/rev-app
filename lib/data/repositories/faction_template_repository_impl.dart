import '../../domain/entities/faction_template.dart';
import '../../domain/entities/faction.dart';
import '../../domain/repositories/faction_template_repository.dart';
import '../datasources/factions_list.dart' as factions_list;

class FactionTemplateRepositoryImpl implements FactionTemplateRepository {
  @override
  List<FactionTemplate> getAllTemplates() {
    return factions_list.FactionsList.allFactions;
  }

  @override
  FactionTemplate? getTemplateByName(String name) {
    return factions_list.FactionsList.getTemplateByName(name);
  }

  @override
  Faction createFactionFromTemplate(FactionTemplate template) {
    return factions_list.FactionsList.createFactionFromTemplate(template);
  }
}

