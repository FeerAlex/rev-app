import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/faction/faction_bloc.dart';
import '../../bloc/faction/faction_event.dart';
import '../../bloc/faction/faction_state.dart';
import '../../widgets/faction/faction_card.dart';
import 'faction_detail_page.dart';

class FactionsListPage extends StatelessWidget {
  const FactionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FactionBloc, FactionState>(
        builder: (context, state) {
          if (state is FactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FactionError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          if (state is FactionLoaded) {
            if (state.factions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет фракций',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте новую фракцию',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<FactionBloc>();
                bloc.add(const LoadFactions());
                // Пропускаем текущее состояние и ждем следующего (FactionLoaded или FactionError)
                await bloc.stream.skip(1).firstWhere(
                  (state) => state is FactionLoaded || state is FactionError,
                );
              },
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final factions = List<int>.from(state.factions.map((f) => f.id!));
                  final item = factions.removeAt(oldIndex);
                  factions.insert(newIndex, item);
                  context.read<FactionBloc>().add(ReorderFactionsEvent(factions));
                },
                children: List.generate(state.factions.length, (index) {
                final faction = state.factions[index];
                return Container(
                  key: ValueKey('faction_${faction.id}'),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Dismissible(
                    key: ValueKey('dismissible_${faction.id}'),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                            actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            title: const Text('Скрыть?'),
                            content: Text(faction.name),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                ),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Скрыть'),
                              ),
                            ],
                          );
                        },
                      ) ?? false;
                    },
                    onDismissed: (direction) {
                      if (faction.id != null) {
                        context.read<FactionBloc>().add(DeleteFactionEvent(faction.id!));
                      }
                    },
                    child: FactionCard(
                      faction: faction,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FactionDetailPage(faction: faction),
                          ),
                        );
                      },
                      onOrderToggle: () {
                        final updatedFaction = faction.copyWith(
                          orderCompleted: !faction.orderCompleted,
                        );
                        context.read<FactionBloc>().add(
                              UpdateFactionEvent(updatedFaction),
                            );
                      },
                      onWorkToggle: () {
                        final updatedFaction = faction.copyWith(
                          workCompleted: !faction.workCompleted,
                        );
                        context.read<FactionBloc>().add(
                              UpdateFactionEvent(updatedFaction),
                            );
                      },
                      onExpTap: () {
                        // Открываем страницу деталей для редактирования репутации
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FactionDetailPage(faction: faction),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
  }
}
