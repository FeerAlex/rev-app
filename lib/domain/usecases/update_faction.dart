import '../entities/faction.dart';
import '../repositories/faction_repository.dart';

class UpdateFaction {
  final FactionRepository repository;

  UpdateFaction(this.repository);

  Future<void> call(Faction faction) async {
    return await repository.updateFaction(faction);
  }
}

