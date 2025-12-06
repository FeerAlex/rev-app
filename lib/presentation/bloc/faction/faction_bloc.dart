import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/usecases/add_faction.dart';
import '../../../domain/usecases/delete_faction.dart';
import '../../../domain/usecases/get_all_factions.dart';
import '../../../domain/usecases/get_hidden_factions.dart';
import '../../../domain/usecases/reset_daily_flags.dart';
import '../../../domain/usecases/update_faction.dart';
import '../../../domain/usecases/reorder_factions.dart';
import '../../../domain/usecases/show_faction.dart';
import 'faction_event.dart';
import 'faction_state.dart';

class FactionBloc extends Bloc<FactionEvent, FactionState> {
  GetAllFactions _getAllFactions;
  AddFaction _addFaction;
  UpdateFaction _updateFaction;
  DeleteFaction _deleteFaction;
  ResetDailyFlags _resetDailyFlags;
  ReorderFactions _reorderFactions;
  ShowFaction _showFaction;
  GetHiddenFactions _getHiddenFactions;

  FactionBloc(
    this._getAllFactions,
    this._addFaction,
    this._updateFaction,
    this._deleteFaction,
    this._resetDailyFlags,
    this._reorderFactions,
    this._showFaction,
    this._getHiddenFactions,
  ) : super(const FactionInitial()) {
    on<LoadFactions>(_onLoadFactions);
    on<AddFactionEvent>(_onAddFaction);
    on<UpdateFactionEvent>(_onUpdateFaction);
    on<DeleteFactionEvent>(_onDeleteFaction);
    on<ResetDailyFlagsEvent>(_onResetDailyFlags);
    on<ReorderFactionsEvent>(_onReorderFactions);
    on<ShowFactionEvent>(_onShowFaction);
  }

  /// Обновляет use cases с новыми репозиториями (используется после импорта БД)
  void updateUseCases(
    GetAllFactions getAllFactions,
    AddFaction addFaction,
    UpdateFaction updateFaction,
    DeleteFaction deleteFaction,
    ResetDailyFlags resetDailyFlags,
    ReorderFactions reorderFactions,
    ShowFaction showFaction,
    GetHiddenFactions getHiddenFactions,
  ) {
    _getAllFactions = getAllFactions;
    _addFaction = addFaction;
    _updateFaction = updateFaction;
    _deleteFaction = deleteFaction;
    _resetDailyFlags = resetDailyFlags;
    _reorderFactions = reorderFactions;
    _showFaction = showFaction;
    _getHiddenFactions = getHiddenFactions;
  }

  Future<void> _onLoadFactions(
    LoadFactions event,
    Emitter<FactionState> emit,
  ) async {
    emit(const FactionLoading());
    try {
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  Future<void> _onAddFaction(
    AddFactionEvent event,
    Emitter<FactionState> emit,
  ) async {
    try {
      await _addFaction(event.faction);
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  Future<void> _onUpdateFaction(
    UpdateFactionEvent event,
    Emitter<FactionState> emit,
  ) async {
    try {
      // Сохраняем order из исходной фракции в списке, чтобы порядок не сбился
      final currentState = state;
      Faction factionToSave = event.faction;
      
      if (currentState is FactionLoaded) {
        final originalFaction = currentState.factions.firstWhere(
          (f) => f.id == event.faction.id,
          orElse: () => event.faction,
        );
        // ВСЕГДА сохраняем displayOrder из исходной фракции в списке
        factionToSave = event.faction.copyWith(displayOrder: originalFaction.displayOrder);
      }
      
      // Обновляем в БД
      await _updateFaction(factionToSave);
      // Перезагружаем список из БД
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  Future<void> _onDeleteFaction(
    DeleteFactionEvent event,
    Emitter<FactionState> emit,
  ) async {
    try {
      await _deleteFaction(event.id);
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  Future<void> _onResetDailyFlags(
    ResetDailyFlagsEvent event,
    Emitter<FactionState> emit,
  ) async {
    try {
      await _resetDailyFlags();
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  Future<void> _onReorderFactions(
    ReorderFactionsEvent event,
    Emitter<FactionState> emit,
  ) async {
    // Оптимистичное обновление: сначала обновляем UI
    final currentState = state;
    if (currentState is FactionLoaded) {
      // Создаем Map для быстрого поиска фракций по id
      final factionMap = {for (var f in currentState.factions) f.id!: f};
      // Переупорядочиваем фракции согласно новому порядку
      final reorderedFactions = event.factionIds
          .map((id) => factionMap[id])
          .whereType<Faction>()
          .toList();
      // Сразу обновляем UI
      emit(FactionLoaded(reorderedFactions));
    }
    
    try {
      // Затем сохраняем порядок в БД
      await _reorderFactions(event.factionIds);
      // Перезагружаем список из БД для синхронизации
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      // В случае ошибки перезагружаем из БД для восстановления корректного состояния
      try {
        final factions = await _getAllFactions();
        emit(FactionLoaded(factions));
      } catch (reloadError) {
        emit(FactionError(e.toString()));
      }
    }
  }

  Future<void> _onShowFaction(
    ShowFactionEvent event,
    Emitter<FactionState> emit,
  ) async {
    try {
      await _showFaction(event.faction);
      final factions = await _getAllFactions();
      emit(FactionLoaded(factions));
    } catch (e) {
      emit(FactionError(e.toString()));
    }
  }

  /// Получить скрытые фракции для диалога выбора
  Future<List<Faction>> getHiddenFactions() async {
    return await _getHiddenFactions();
  }
}

