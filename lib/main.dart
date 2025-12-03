import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/di/service_locator.dart';
import 'domain/usecases/add_faction.dart';
import 'domain/usecases/delete_faction.dart';
import 'domain/usecases/get_all_factions.dart';
import 'domain/usecases/reset_daily_flags.dart';
import 'domain/usecases/update_faction.dart';
import 'domain/usecases/reorder_factions.dart';
import 'domain/usecases/initialize_factions.dart';
import 'domain/usecases/show_faction.dart';
import 'presentation/bloc/faction/faction_bloc.dart';
import 'presentation/bloc/faction/faction_event.dart';
import 'presentation/pages/main/main_page.dart';
import 'core/utils/daily_reset_helper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация timezone
  tz.initializeTimeZones();
  
  // Инициализация ServiceLocator
  await ServiceLocator().init();
  
  // Инициализация фракций (создание всех 13 фракций, если их еще нет)
  final serviceLocator = ServiceLocator();
  final initializeFactions = InitializeFactions(serviceLocator.factionRepository);
  await initializeFactions();
  
  // Проверка и сброс ежедневных отметок
  await DailyResetHelper.checkAndReset();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator();
    
    return BlocProvider(
      create: (context) => FactionBloc(
        GetAllFactions(serviceLocator.factionRepository),
        AddFaction(serviceLocator.factionRepository),
        UpdateFaction(serviceLocator.factionRepository),
        DeleteFaction(serviceLocator.factionRepository),
        ResetDailyFlags(serviceLocator.factionRepository),
        ReorderFactions(serviceLocator.factionRepository),
        ShowFaction(serviceLocator.factionRepository),
        serviceLocator.factionRepository,
      )..add(const LoadFactions()),
      child: MaterialApp(
        title: 'Rev App',
        theme: AppTheme.darkTheme,
        home: const MainPage(),
      ),
    );
  }
}
