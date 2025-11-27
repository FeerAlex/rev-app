import '../repositories/faction_repository.dart';

class ResetDailyFlags {
  final FactionRepository repository;

  ResetDailyFlags(this.repository);

  Future<void> call() async {
    return await repository.resetDailyFlags();
  }
}

