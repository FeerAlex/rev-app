import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'presentation/di/service_locator.dart';
import 'domain/usecases/add_faction.dart';
import 'domain/usecases/delete_faction.dart';
import 'domain/usecases/get_all_factions.dart';
import 'domain/usecases/get_hidden_factions.dart';
import 'domain/usecases/reset_daily_flags.dart';
import 'domain/usecases/update_faction.dart';
import 'domain/usecases/reorder_factions.dart';
import 'domain/usecases/initialize_factions.dart';
import 'domain/usecases/show_faction.dart';
import 'presentation/bloc/faction/faction_bloc.dart';
import 'presentation/bloc/faction/faction_event.dart';
import 'presentation/pages/main/main_page.dart';
import 'domain/utils/daily_reset_helper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Глобальная обработка ошибок Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // В release режиме логируем ошибку
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };
  
  // Обработка асинхронных ошибок
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };
  
  try {
    // Инициализация timezone
    tz.initializeTimeZones();
    
    // Инициализация ServiceLocator
    await ServiceLocator().init();
    
    // Инициализация фракций (создание всех 13 фракций, если их еще нет)
    final serviceLocator = ServiceLocator();
    final initializeFactions = InitializeFactions(
      serviceLocator.factionRepository,
      serviceLocator.factionTemplateRepository,
    );
    await initializeFactions();
    
    // Проверка и сброс ежедневных отметок
    await DailyResetHelper.checkAndReset(
      serviceLocator.factionRepository,
      serviceLocator.appSettingsRepository,
      serviceLocator.dateTimeProvider,
    );
    
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Если инициализация не удалась, показываем экран с ошибкой
    runApp(ErrorApp(error: e, stackTrace: stackTrace));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
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
          GetHiddenFactions(serviceLocator.factionRepository),
        )..add(const LoadFactions()),
        child: MaterialApp(
          title: 'Rev App',
          theme: AppTheme.darkTheme,
          home: const MainPage(),
        ),
      );
    } catch (e) {
      // Fallback на случай ошибки при создании приложения
      return MaterialApp(
        title: 'Rev App',
        theme: AppTheme.darkTheme,
        home: ErrorScreen(
          error: e,
          message: 'Ошибка при инициализации приложения',
        ),
      );
    }
  }
}

/// Виджет для отображения ошибки при запуске приложения
class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  
  const ErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rev App',
      theme: AppTheme.darkTheme,
      home: ErrorScreen(
        error: error,
        stackTrace: stackTrace,
        message: 'Ошибка при запуске приложения',
      ),
    );
  }
}

/// Экран с ошибкой
class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final String message;
  
  const ErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode && stackTrace != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Stack trace:',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      stackTrace.toString(),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
