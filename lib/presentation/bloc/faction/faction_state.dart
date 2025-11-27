import 'package:equatable/equatable.dart';
import '../../../domain/entities/faction.dart';

abstract class FactionState extends Equatable {
  const FactionState();

  @override
  List<Object?> get props => [];
}

class FactionInitial extends FactionState {
  const FactionInitial();
}

class FactionLoading extends FactionState {
  const FactionLoading();
}

class FactionLoaded extends FactionState {
  final List<Faction> factions;

  const FactionLoaded(this.factions);

  @override
  List<Object?> get props => [factions];
}

class FactionError extends FactionState {
  final String message;

  const FactionError(this.message);

  @override
  List<Object?> get props => [message];
}

