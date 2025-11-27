import '../../domain/entities/faction.dart';
import '../../domain/repositories/faction_repository.dart';
import '../datasources/faction_dao.dart';
import '../models/faction_model.dart';

class FactionRepositoryImpl implements FactionRepository {
  final FactionDao _dao;

  FactionRepositoryImpl(this._dao);

  @override
  Future<List<Faction>> getAllFactions() async {
    final maps = await _dao.getAllFactions();
    return maps.map((map) => FactionModel.fromMap(map)).toList();
  }

  @override
  Future<Faction?> getFactionById(int id) async {
    final map = await _dao.getFactionById(id);
    return map != null ? FactionModel.fromMap(map) : null;
  }

  @override
  Future<int> addFaction(Faction faction) async {
    // Получаем максимальный order для установки новой фракции в конец списка
    final allFactions = await getAllFactions();
    final maxOrder = allFactions.isEmpty 
        ? 0 
        : allFactions.map((f) => f.displayOrder).reduce((a, b) => a > b ? a : b);
    
    final factionWithOrder = faction.copyWith(displayOrder: maxOrder + 1);
    return await _dao.insertFaction(FactionModel.toMap(factionWithOrder));
  }

  @override
  Future<void> updateFaction(Faction faction) async {
    await _dao.updateFaction(FactionModel.toMap(faction));
  }

  @override
  Future<void> deleteFaction(int id) async {
    await _dao.deleteFaction(id);
  }

  @override
  Future<void> resetDailyFlags() async {
    await _dao.resetDailyFlags();
  }

  @override
  Future<void> reorderFactions(List<int> factionIds) async {
    final orders = factionIds.asMap().entries.map((entry) => {
      'id': entry.value,
      'order': entry.key,
    }).toList();
    await _dao.updateFactionsOrder(orders);
  }
}

