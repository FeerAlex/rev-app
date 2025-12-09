import 'package:flutter/material.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/usecases/get_all_questions.dart';
import '../../../domain/usecases/search_questions.dart';
import '../../widgets/quiz/question_card.dart';

class QuizClubPage extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final GetAllQuestions getAllQuestions;
  final SearchQuestions searchQuestions;

  const QuizClubPage({
    super.key,
    this.scaffoldKey,
    required this.getAllQuestions,
    required this.searchQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: const Text('Клуб знатоков'),
      ),
      body: SafeArea(
        child: QuestionSectionView(
          getAllQuestions: getAllQuestions,
          searchQuestions: searchQuestions,
          emptyQuestionsHint: 'Добавьте вопросы в файл questions/questions_club.json',
        ),
      ),
    );
  }
}

class QuizTabsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final GetAllQuestions clubGetAllQuestions;
  final SearchQuestions clubSearchQuestions;
  final GetAllQuestions examGetAllQuestions;
  final SearchQuestions examSearchQuestions;

  const QuizTabsPage({
    super.key,
    this.scaffoldKey,
    required this.clubGetAllQuestions,
    required this.clubSearchQuestions,
    required this.examGetAllQuestions,
    required this.examSearchQuestions,
  });

  @override
  State<QuizTabsPage> createState() => _QuizTabsPageState();
}

class _QuizTabsPageState extends State<QuizTabsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      QuestionSectionView(
        key: const PageStorageKey('club'),
        getAllQuestions: widget.clubGetAllQuestions,
        searchQuestions: widget.clubSearchQuestions,
        emptyQuestionsHint: 'Добавьте вопросы в файл questions/questions_club.json',
      ),
      QuestionSectionView(
        key: const PageStorageKey('theosophy'),
        getAllQuestions: widget.examGetAllQuestions,
        searchQuestions: widget.examSearchQuestions,
        emptyQuestionsHint: 'Добавьте вопросы в файл questions/questions_theosophy.json',
      ),
    ];

    final titles = ['Клуб знатоков', 'Теософский экзамен'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Text(titles[_currentIndex]),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'Клуб',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            label: 'Экзамен',
          ),
        ],
      ),
    );
  }
}

class QuestionSectionView extends StatefulWidget {
  final GetAllQuestions getAllQuestions;
  final SearchQuestions searchQuestions;
  final String emptyQuestionsHint;

  const QuestionSectionView({
    super.key,
    required this.getAllQuestions,
    required this.searchQuestions,
    required this.emptyQuestionsHint,
  });

  @override
  State<QuestionSectionView> createState() => _QuestionSectionViewState();
}

class _QuestionSectionViewState extends State<QuestionSectionView> {
  final TextEditingController _searchController = TextEditingController();
  List<Question> _questions = [];
  List<Question> _filteredQuestions = [];
  bool _isLoading = true;
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
      final questions = await widget.getAllQuestions();
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _filteredQuestions = questions;
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
      final results = await widget.searchQuestions(query);
      if (!mounted) return;
      setState(() {
        _filteredQuestions = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Поиск по вопросу или ответу...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
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
              style: TextStyle(color: Colors.white70),
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
                  ? widget.emptyQuestionsHint
                  : 'Попробуйте изменить запрос',
              style: TextStyle(color: Colors.white70),
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
