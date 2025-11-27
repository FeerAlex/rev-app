import '../entities/faction.dart';

abstract class FactionRepository {
  Future<List<Faction>> getAllFactions();
  Future<Faction?> getFactionById(int id);
  Future<int> addFaction(Faction faction);
  Future<void> updateFaction(Faction faction);
  Future<void> deleteFaction(int id);
  Future<void> resetDailyFlags();
  Future<void> reorderFactions(List<int> factionIds);
}

