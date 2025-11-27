import '../repositories/faction_repository.dart';

class DeleteFaction {
  final FactionRepository repository;

  DeleteFaction(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteFaction(id);
  }
}

