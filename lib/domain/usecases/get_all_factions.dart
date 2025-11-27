import '../entities/faction.dart';
import '../repositories/faction_repository.dart';

class GetAllFactions {
  final FactionRepository repository;

  GetAllFactions(this.repository);

  Future<List<Faction>> call() async {
    return await repository.getAllFactions();
  }
}

