import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../data/repositories/app_settings_repository_impl.dart';
import '../../../data/repositories/database_initializer_impl.dart';
import '../../../data/repositories/database_path_provider_impl.dart';
import '../../../data/repositories/date_time_provider_impl.dart';
import '../../../data/repositories/faction_template_repository_impl.dart';
import '../../../data/repositories/file_exporter_impl.dart';
import '../../../data/repositories/file_importer_impl.dart';
import '../../../data/repositories/question_repository_impl.dart';
import '../../../data/repositories/repository_factory.dart';
import '../../../data/repositories/text_recognizer_factory.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/repositories/database_initializer.dart';
import '../../../domain/repositories/database_path_provider.dart';
import '../../../domain/repositories/date_time_provider.dart';
import '../../../domain/repositories/faction_repository.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../../../domain/repositories/file_exporter.dart';
import '../../../domain/repositories/file_importer.dart';
import '../../../domain/repositories/question_repository.dart';
import '../../../domain/repositories/text_recognizer.dart';
import '../../../domain/usecases/recognize_question_from_image.dart';
import '../../../domain/utils/question_source.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  Database? _database;
  String? _databasePath;
  FactionRepository? _factionRepository;
  FactionTemplateRepository? _factionTemplateRepository;
  AppSettingsRepository? _appSettingsRepository;
  DateTimeProvider? _dateTimeProvider;
  FileExporter? _fileExporter;
  FileImporter? _fileImporter;
  DatabasePathProvider? _databasePathProvider;
  DatabaseInitializer? _databaseInitializer;
  QuestionRepository? _clubQuestionRepository;
  QuestionRepository? _examQuestionRepository;
  TextRecognizer? _textRecognizer;
  RecognizeQuestionFromImage? _recognizeQuestionFromImage;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    _databasePath = join(databasesPath, 'rev_app.db');
    
    _databaseInitializer = DatabaseInitializerImpl();
    
    _database = await openDatabase(
      _databasePath!,
      version: 1,
      onCreate: (db, version) async {
        await _databaseInitializer!.initializeDatabase(db);
      },
    );

    _factionRepository = RepositoryFactory.createFactionRepository(_database!);
    _factionTemplateRepository = FactionTemplateRepositoryImpl();
    _appSettingsRepository = AppSettingsRepositoryImpl();
    _dateTimeProvider = DateTimeProviderImpl();
    _fileExporter = FileExporterImpl();
    _fileImporter = FileImporterImpl();
    _clubQuestionRepository = QuestionRepositoryImpl(
      source: QuestionSource.club,
    );
    _examQuestionRepository = QuestionRepositoryImpl(
      assetPath: 'assets/questions/questions_theosophy.json',
      source: QuestionSource.exam,
    );

    _textRecognizer = TextRecognizerFactory.createTextRecognizer();
    _recognizeQuestionFromImage = RecognizeQuestionFromImage(
      textRecognizer: _textRecognizer!,
      clubQuestionRepository: _clubQuestionRepository!,
      examQuestionRepository: _examQuestionRepository!,
    );
    _databasePathProvider = DatabasePathProviderImpl(
      _database,
      _databasePath,
      _databaseInitializer!,
      (Database db) {
        _database = db;
      },
    );
  }

  /// Получает путь к файлу базы данных
  Future<String> getDatabasePath() async {
    if (_databasePath != null) {
      return _databasePath!;
    }
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'rev_app.db');
  }

  /// Переинициализирует базу данных после импорта
  Future<void> reinitializeDatabase(String importedFilePath) async {
    // Обнуляем старый репозиторий, чтобы избежать использования закрытого соединения
    _factionRepository = null;
    
    await _databasePathProvider!.reinitializeDatabase(importedFilePath);
    
    // Обновляем путь к БД
    _databasePath = await getDatabasePath();
    
    // _database уже обновлен через callback в DatabasePathProviderImpl.reinitializeDatabase
    if (_database == null) {
      throw Exception('Не удалось получить соединение с базой данных после импорта');
    }
    
    // Создаем новый репозиторий с новым соединением через фабрику
    _factionRepository = RepositoryFactory.createFactionRepository(_database!);
  }

  Database get database => _database!;
  FactionRepository get factionRepository => _factionRepository!;
  FactionTemplateRepository get factionTemplateRepository => _factionTemplateRepository!;
  AppSettingsRepository get appSettingsRepository => _appSettingsRepository!;
  DateTimeProvider get dateTimeProvider => _dateTimeProvider!;
  FileExporter get fileExporter => _fileExporter!;
  FileImporter get fileImporter => _fileImporter!;
  DatabasePathProvider get databasePathProvider => _databasePathProvider!;
  QuestionRepository get clubQuestionRepository => _clubQuestionRepository!;
  QuestionRepository get examQuestionRepository => _examQuestionRepository!;
  RecognizeQuestionFromImage get recognizeQuestionFromImage => _recognizeQuestionFromImage!;
}

