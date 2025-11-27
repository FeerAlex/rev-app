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
import 'domain/usecases/get_settings.dart';
import 'domain/usecases/update_settings.dart';
import 'presentation/bloc/faction/faction_bloc.dart';
import 'presentation/bloc/faction/faction_event.dart';
import 'presentation/bloc/settings/settings_bloc.dart';
import 'presentation/bloc/settings/settings_event.dart';
import 'presentation/pages/main_page.dart';
import 'core/utils/daily_reset_helper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация timezone
  tz.initializeTimeZones();
  
  // Инициализация ServiceLocator
  await ServiceLocator().init();
  
  // Проверка и сброс ежедневных отметок
  await DailyResetHelper.checkAndReset();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FactionBloc(
            GetAllFactions(serviceLocator.factionRepository),
            AddFaction(serviceLocator.factionRepository),
            UpdateFaction(serviceLocator.factionRepository),
            DeleteFaction(serviceLocator.factionRepository),
            ResetDailyFlags(serviceLocator.factionRepository),
            ReorderFactions(serviceLocator.factionRepository),
          )..add(const LoadFactions()),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            GetSettings(serviceLocator.settingsRepository),
            UpdateSettings(serviceLocator.settingsRepository),
          )..add(const LoadSettings()),
        ),
      ],
      child: MaterialApp(
        title: 'Rev App',
        theme: AppTheme.darkTheme,
        home: const MainPage(),
      ),
    );
  }
}
