import '../repositories/faction_repository.dart';
import '../repositories/faction_template_repository.dart';

class InitializeFactions {
  final FactionRepository _factionRepository;
  final FactionTemplateRepository _templateRepository;

  InitializeFactions(
    this._factionRepository,
    this._templateRepository,
  );

  Future<void> call() async {
    // Получаем все существующие фракции (включая скрытые)
    final existingFactions = await _factionRepository.getAllFactionsIncludingHidden();
    
    // Получаем все шаблоны фракций
    final allTemplates = _templateRepository.getAllTemplates();
    
    // Если фракции уже инициализированы, ничего не делаем
    if (existingFactions.length >= allTemplates.length) {
      return;
    }

    // Получаем список имен существующих фракций
    final existingNames = existingFactions.map((f) => f.name).toSet();

    // Создаем фракции из статического списка, которых еще нет в БД
    for (final template in allTemplates) {
      if (!existingNames.contains(template.name)) {
        final faction = _templateRepository.createFactionFromTemplate(template);
        await _factionRepository.addFaction(faction);
      }
    }
  }
}

