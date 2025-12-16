import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import '../../../domain/usecases/get_all_questions.dart';
import '../../../domain/usecases/recognize_question_from_image.dart';
import '../../../domain/usecases/search_questions.dart';
import '../../widgets/common/help_dialog.dart';
import '../../widgets/quiz/question_card.dart';
import 'camera_scan_page.dart';

class QuizPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final GetAllQuestions clubGetAllQuestions;
  final SearchQuestions clubSearchQuestions;
  final GetAllQuestions examGetAllQuestions;
  final SearchQuestions examSearchQuestions;
  final RecognizeQuestionFromImage recognizeQuestionFromImage;

  const QuizPage({
    super.key,
    this.scaffoldKey,
    required this.clubGetAllQuestions,
    required this.clubSearchQuestions,
    required this.examGetAllQuestions,
    required this.examSearchQuestions,
    required this.recognizeQuestionFromImage,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Question> _questions = [];
  List<Question> _filteredQuestions = [];
  bool _isLoading = true;
  bool _isScanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Загружаем вопросы из обоих источников параллельно
      final results = await Future.wait([
        widget.clubGetAllQuestions(),
        widget.examGetAllQuestions(),
      ]);

      if (!mounted) return;

      // Объединяем результаты
      final allQuestions = [...results[0], ...results[1]];

      setState(() {
        _questions = allQuestions;
        _filteredQuestions = allQuestions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredQuestions = _questions;
      });
      return;
    }

    try {
      // Выполняем поиск в обоих источниках параллельно
      final results = await Future.wait([
        widget.clubSearchQuestions(query),
        widget.examSearchQuestions(query),
      ]);

      if (!mounted) return;

      // Объединяем результаты
      final allResults = [...results[0], ...results[1]];

      setState(() {
        _filteredQuestions = allResults;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'Клуб / Экзамен',
      '''На этой странице собраны вопросы из двух активностей игры:
      
      • Клуб знатоков - вопросы с оранжевыми чипсами ответов
      • Теософский экзамен - вопросы с синими чипсами ответов

      Используйте поисковую строку для быстрого поиска по тексту вопроса или ответам.

      Иконка камеры справа от поля поиска позволяет распознать вопрос с изображения (скриншота).

      Все данные взяты из разных источников, могут содержать ошибки и неточности.''',
    );
  }

  Future<void> _scanImage() async {
    String? tempFilePath;

    try {
      // Открываем камеру с фиксированной рамкой
      final croppedImagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScanPage(),
        ),
      );

      if (croppedImagePath == null) return;

      tempFilePath = croppedImagePath;

      setState(() {
        _isScanning = true;
      });

      // Используем use case из DI (через widget)
      final result = await widget.recognizeQuestionFromImage(croppedImagePath);

      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      if (result.isFound) {
        _searchController.text = result.question!.question;
        final scorePercent = (result.score * 100).toInt();


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Найден вопрос (совпадение: $scorePercent%)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (result.recognizedText.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось распознать текст с изображения'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final lines = result.recognizedText
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(5)
            .join('\n');


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Похожий вопрос не найден. Распознано:\n$lines'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сканировании изображения: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      // Удаляем временный файл после завершения работы
      if (tempFilePath != null) {
        try {
          final tempFile = File(tempFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          // Игнорируем ошибки при удалении временного файла
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('Клуб / Экзамен'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Поиск по вопросу или ответу...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      if (_isScanning)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.photo_camera, size: 20),
                          onPressed: _scanImage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Распознать вопрос с изображения',
                        ),
                    ],
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_filteredQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.trim().isEmpty
                  ? 'Вопросы не найдены'
                  : 'Ничего не найдено',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.trim().isEmpty
                  ? 'Добавьте вопросы в файлы questions_club.json или questions_theosophy.json'
                  : 'Попробуйте изменить запрос',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: _filteredQuestions.length,
        itemBuilder: (context, index) {
          return QuestionCard(question: _filteredQuestions[index]);
        },
      ),
    );
  }
}
