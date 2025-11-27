import '../repositories/faction_repository.dart';

class ReorderFactions {
  final FactionRepository repository;

  ReorderFactions(this.repository);

  Future<void> call(List<int> factionIds) async {
    return await repository.reorderFactions(factionIds);
  }
}

