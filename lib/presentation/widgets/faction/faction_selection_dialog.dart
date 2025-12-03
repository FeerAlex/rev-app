import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../../bloc/faction/faction_bloc.dart';
import '../../bloc/faction/faction_event.dart';

class FactionSelectionDialog extends StatelessWidget {
  const FactionSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Faction>>(
      future: context.read<FactionBloc>().getHiddenFactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: Text('Не удалось загрузить фракции: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ],
          );
        }

        final hiddenFactions = snapshot.data ?? [];

        if (hiddenFactions.isEmpty) {
          return AlertDialog(
            title: const Text('Нет доступных фракций'),
            content: const Text('Все фракции уже добавлены в список.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Выберите фракцию'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: hiddenFactions.length,
              itemBuilder: (context, index) {
                final faction = hiddenFactions[index];
                return ListTile(
                  title: Text(faction.name),
                  onTap: () {
                    context.read<FactionBloc>().add(ShowFactionEvent(faction));
                    Navigator.of(context).pop();
                  },
                  dense: true,
                  minTileHeight: 0,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}

