import '../repositories/faction_repository.dart';
import '../../core/constants/factions_list.dart';

class InitializeFactions {
  final FactionRepository repository;

  InitializeFactions(this.repository);

  Future<void> call() async {
    // Получаем все существующие фракции (включая скрытые)
    final existingFactions = await repository.getAllFactionsIncludingHidden();
    
    // Если фракции уже инициализированы, ничего не делаем
    if (existingFactions.length >= FactionsList.allFactions.length) {
      return;
    }

    // Получаем список имен существующих фракций
    final existingNames = existingFactions.map((f) => f.name).toSet();

    // Создаем фракции из статического списка, которых еще нет в БД
    for (final template in FactionsList.allFactions) {
      if (!existingNames.contains(template.name)) {
        final faction = FactionsList.createFactionFromTemplate(template);
        await repository.addFaction(faction);
      }
    }
  }
}

