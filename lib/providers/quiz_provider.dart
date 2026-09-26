import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PreferencesService _prefsService = PreferencesService();

  // Category State
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoryError;

  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoryError => _categoryError;

  // Configuration State
  CategoryModel? _selectedCategory;
  int _amount = 10;
  String _difficulty = 'Any Difficulty'; // 'Any Difficulty', 'Easy', 'Medium', 'Hard'
  String _questionType = 'Multiple Choice'; // 'Multiple Choice', 'True / False'

  CategoryModel? get selectedCategory => _selectedCategory;
  int get amount => _amount;
  String get difficulty => _difficulty;
  String get questionType => _questionType;

  // Quiz Gameplay State
  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  bool _isLoadingQuestions = false;
  String? _questionError;
  int _score = 0;

  // Timer State (25 seconds per question as specified in 20-30s range)
  static const int perQuestionTimeLimit = 25;
  int _timerSeconds = perQuestionTimeLimit;
  Timer? _countdownTimer;
  final Stopwatch _totalQuizStopwatch = Stopwatch();
  int _totalQuizTimeSeconds = 0;

  // Answer interaction state
  bool _isAnswerSubmitted = false;

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoadingQuestions => _isLoadingQuestions;
  String? get questionError => _questionError;
  int get score => _score;
  int get timerSeconds => _timerSeconds;
  int get totalQuizTimeSeconds => _totalQuizTimeSeconds;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  bool get isQuizFinished => _questions.isNotEmpty && _currentIndex >= _questions.length;
  bool get isLastQuestion => _questions.isNotEmpty && _currentIndex == _questions.length - 1;

  QuestionModel? get currentQuestion {
    if (_questions.isNotEmpty && _currentIndex < _questions.length) {
      return _questions[_currentIndex];
    }
    return null;
  }

  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_currentIndex + 1) / _questions.length;
  }

  double get accuracyPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_score / _questions.length) * 100;
  }

  QuizProvider() {
    loadSavedConfig();
    fetchCategories();
  }

  /// Loads saved configuration from SharedPreferences
  Future<void> loadSavedConfig() async {
    try {
      final config = await _prefsService.loadConfig();
      _amount = config['amount'] as int? ?? 10;
      _difficulty = config['difficulty'] as String? ?? 'Any Difficulty';
      _questionType = config['type'] as String? ?? 'Multiple Choice';
      final savedCatId = config['categoryId'] as int?;
      final savedCatName = config['categoryName'] as String?;
      if (savedCatId != null && savedCatName != null) {
        _selectedCategory = CategoryModel(id: savedCatId, name: savedCatName);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved config: $e');
    }
  }

  /// Persists current configuration to SharedPreferences
  Future<void> saveCurrentConfig() async {
    try {
      await _prefsService.saveConfig(
        amount: _amount,
        difficulty: _difficulty,
        type: _questionType,
        categoryId: _selectedCategory?.id,
        categoryName: _selectedCategory?.name,
      );
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }

  /// Fetches categories from API with session caching
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    _isLoadingCategories = true;
    _categoryError = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories(forceRefresh: forceRefresh);
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCategories = false;
      _categoryError = 'Failed to load categories. Please check your internet connection.';
      notifyListeners();
    }
  }

  /// Sets selected category and updates default configuration
  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Updates question count
  void setAmount(int value) {
    _amount = value.clamp(1, 50);
    notifyListeners();
  }

  /// Updates difficulty setting
  void setDifficulty(String value) {
    _difficulty = value;
    notifyListeners();
  }

  /// Updates question type setting
  void setQuestionType(String value) {
    _questionType = value;
    notifyListeners();
  }

  /// Translates dropdown choices to API query parameters
  String? get _apiDifficultyParam {
    switch (_difficulty) {
      case 'Easy':
        return 'easy';
      case 'Medium':
        return 'medium';
      case 'Hard':
        return 'hard';
      default:
        return null; // Any Difficulty
    }
  }

  String? get _apiTypeParam {
    switch (_questionType) {
      case 'Multiple Choice':
        return 'multiple';
      case 'True / False':
        return 'boolean';
      default:
        return null;
    }
  }

  /// Starts the quiz: saves config, fetches questions, resets score and begins timer
  Future<bool> startQuiz() async {
    if (_selectedCategory == null) return false;

    _isLoadingQuestions = true;
    _questionError = null;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _isAnswerSubmitted = false;
    _totalQuizTimeSeconds = 0;
    _stopTimer();
    notifyListeners();

    // Persist configuration in SharedPreferences
    await saveCurrentConfig();

    try {
      final fetched = await _apiService.getQuestions(
        amount: _amount,
        categoryId: _selectedCategory!.id,
        difficulty: _apiDifficultyParam,
        type: _apiTypeParam,
      );

      _questions = fetched;
      _isLoadingQuestions = false;
      _totalQuizStopwatch.reset();
      _totalQuizStopwatch.start();
      _startQuestionTimer();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingQuestions = false;
      _questionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Starts or resets the timer for the active question
  void _startQuestionTimer() {
    _stopTimer();
    _timerSeconds = perQuestionTimeLimit;
    _isAnswerSubmitted = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        // Timer expired
        _stopTimer();
        _handleTimeOut();
      }
    });
  }

  /// Handles when question countdown reaches 0
  void _handleTimeOut() {
    final q = currentQuestion;
    if (q != null && !q.isAnswered) {
      q.isTimedOut = true;
      q.isAnswered = true;
      _isAnswerSubmitted = true;
      notifyListeners();
    }
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// User selects an answer option
  void selectAnswer(String answer) {
    final q = currentQuestion;
    if (q == null || q.isAnswered) return;

    _stopTimer();
    q.selectedAnswer = answer;
    q.isAnswered = true;
    _isAnswerSubmitted = true;

    if (q.isCorrect) {
      _score++;
    }
    notifyListeners();
  }

  /// Move to the next question or complete quiz
  void nextQuestion() {
    _stopTimer();

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _startQuestionTimer();
      notifyListeners();
    } else {
      // Quiz finished
      _totalQuizStopwatch.stop();
      _totalQuizTimeSeconds = _totalQuizStopwatch.elapsed.inSeconds;
      _currentIndex = _questions.length; // Indicates completion
      notifyListeners();
    }
  }

  /// Resets quiz state while preserving saved config in SharedPreferences
  void resetQuiz({bool keepConfig = true}) {
    _stopTimer();
    _totalQuizStopwatch.reset();
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _timerSeconds = perQuestionTimeLimit;
    _isAnswerSubmitted = false;
    _questionError = null;

    if (!keepConfig) {
      _selectedCategory = null;
    }
    notifyListeners();
  }

  /// Cancel and exit quiz back to category or welcome
  void exitQuiz() {
    _stopTimer();
    _totalQuizStopwatch.reset();
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _isAnswerSubmitted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _totalQuizStopwatch.stop();
    super.dispose();
  }
}
