import '../entities/faction.dart';
import '../repositories/faction_repository.dart';

class AddFaction {
  final FactionRepository repository;

  AddFaction(this.repository);

  Future<int> call(Faction faction) async {
    return await repository.addFaction(faction);
  }
}

