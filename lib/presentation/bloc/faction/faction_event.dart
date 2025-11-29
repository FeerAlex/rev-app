import 'package:equatable/equatable.dart';
import '../../../domain/entities/faction.dart';

abstract class FactionEvent extends Equatable {
  const FactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadFactions extends FactionEvent {
  const LoadFactions();
}

class AddFactionEvent extends FactionEvent {
  final Faction faction;

  const AddFactionEvent(this.faction);

  @override
  List<Object?> get props => [faction];
}

class UpdateFactionEvent extends FactionEvent {
  final Faction faction;

  const UpdateFactionEvent(this.faction);

  @override
  List<Object?> get props => [faction];
}

class DeleteFactionEvent extends FactionEvent {
  final int id;

  const DeleteFactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ResetDailyFlagsEvent extends FactionEvent {
  const ResetDailyFlagsEvent();
}

class ReorderFactionsEvent extends FactionEvent {
  final List<int> factionIds;

  const ReorderFactionsEvent(this.factionIds);

  @override
  List<Object?> get props => [factionIds];
}

class ShowFactionEvent extends FactionEvent {
  final Faction faction;

  const ShowFactionEvent(this.faction);

  @override
  List<Object?> get props => [faction];
}

