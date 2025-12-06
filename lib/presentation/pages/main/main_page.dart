import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/service_locator.dart';
import '../../../domain/usecases/import_database.dart';
import '../../../domain/usecases/export_database.dart';
import '../../../domain/usecases/get_all_factions.dart';
import '../../../domain/usecases/add_faction.dart';
import '../../../domain/usecases/update_faction.dart';
import '../../../domain/usecases/delete_faction.dart';
import '../../../domain/usecases/reset_daily_flags.dart';
import '../../../domain/usecases/reorder_factions.dart';
import '../../../domain/usecases/show_faction.dart';
import '../../../domain/usecases/get_hidden_factions.dart';
import '../faction/factions_page.dart';
import '../map/map_page.dart';
import '../../bloc/faction/faction_bloc.dart';
import '../../bloc/faction/faction_event.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages = [
    FactionsPage(scaffoldKey: _scaffoldKey),
    MapPage(scaffoldKey: _scaffoldKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _pages[_currentPage],
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                      ),
                      child: Text(
                        'Rev App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Фракции'),
                      selected: _currentPage == 0,
                      onTap: () {
                        setState(() {
                          _currentPage = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('Карта'),
                      selected: _currentPage == 1,
                      onTap: () {
                        setState(() {
                          _currentPage = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Экспорт БД'),
                onTap: () async {
                  Navigator.pop(context);
                  await _exportDatabase(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Импорт БД'),
                onTap: () async {
                  Navigator.pop(context);
                  await _importDatabase(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      final serviceLocator = ServiceLocator();
      final exportDatabase = ExportDatabase(
        serviceLocator.fileExporter,
        serviceLocator.databasePathProvider,
      );
      
      final success = await exportDatabase();
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'База данных успешно экспортирована'
                : 'Ошибка при экспорте базы данных',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при экспорте: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importDatabase(BuildContext context) async {
    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Импорт базы данных'),
        content: const Text(
          'Внимание! Импорт базы данных заменит все текущие данные. '
          'Рекомендуется сделать резервную копию перед импортом.\n\n'
          'Продолжить?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Импортировать'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final serviceLocator = ServiceLocator();
      final importDatabase = ImportDatabase(serviceLocator.fileImporter);

      final importedFilePath = await importDatabase();
      
      if (importedFilePath == null) {
        return; // Пользователь отменил выбор
      }
      
      // Вызываем ServiceLocator.reinitializeDatabase для обновления всех репозиториев
      await serviceLocator.reinitializeDatabase(importedFilePath);
      
      if (!context.mounted) return;
      
      // Обновляем use cases в BLoC с новыми репозиториями
      final bloc = context.read<FactionBloc>();
      
      bloc.updateUseCases(
        GetAllFactions(serviceLocator.factionRepository),
        AddFaction(serviceLocator.factionRepository),
        UpdateFaction(serviceLocator.factionRepository),
        DeleteFaction(serviceLocator.factionRepository),
        ResetDailyFlags(serviceLocator.factionRepository),
        ReorderFactions(serviceLocator.factionRepository),
        ShowFaction(serviceLocator.factionRepository),
        GetHiddenFactions(serviceLocator.factionRepository),
      );
      
      bloc.add(const LoadFactions());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('База данных успешно импортирована'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      String errorMessage = 'Ошибка при импорте базы данных';
      
      // Более понятные сообщения об ошибках
      final errorString = e.toString();
      if (errorString.contains('Выбор файла отменен')) {
        // Пользователь отменил выбор - не показываем ошибку
        return;
      } else if (errorString.contains('не существует')) {
        errorMessage = 'Файл не найден. Убедитесь, что файл доступен.';
      } else if (errorString.contains('таблицу factions')) {
        errorMessage = 'Файл не является валидной базой данных Rev App. Отсутствует таблица factions.';
      } else if (errorString.contains('SQLite')) {
        errorMessage = 'Файл не является валидной SQLite базой данных.';
      } else {
        errorMessage = 'Ошибка при импорте: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

