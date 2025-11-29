import '../entities/faction.dart';
import '../repositories/faction_repository.dart';

/// Показывает скрытую фракцию (устанавливает isVisible = true)
class ShowFaction {
  final FactionRepository repository;

  ShowFaction(this.repository);

  Future<void> call(Faction faction) async {
    final updatedFaction = faction.copyWith(isVisible: true);
    await repository.updateFaction(updatedFaction);
  }
}

