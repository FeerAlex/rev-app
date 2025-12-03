import '../entities/faction.dart';
import '../repositories/faction_repository.dart';

/// Получение скрытых фракций
class GetHiddenFactions {
  final FactionRepository repository;

  GetHiddenFactions(this.repository);

  Future<List<Faction>> call() async {
    return await repository.getHiddenFactions();
  }
}

