import 'package:html_unescape/html_unescape.dart';

final HtmlUnescape _unescape = HtmlUnescape();

/// Model representing a single question from OpenTDB
class QuestionModel {
  final String type; // "multiple" or "boolean"
  final String difficulty; // "easy", "medium", "hard"
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  // Runtime state during quiz
  String? selectedAnswer;
  bool isAnswered;
  bool isTimedOut;

  QuestionModel({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
    this.selectedAnswer,
    this.isAnswered = false,
    this.isTimedOut = false,
  });

  /// Factory constructor to parse question from OpenTDB JSON format
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'] as String? ?? '';
    final rawCorrect = json['correct_answer'] as String? ?? '';
    final rawIncorrect = (json['incorrect_answers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Unescape HTML entities like &quot;, &#039;, &amp;, etc.
    final cleanQuestion = _unescape.convert(rawQuestion);
    final cleanCorrect = _unescape.convert(rawCorrect);
    final cleanIncorrect = rawIncorrect.map((e) => _unescape.convert(e)).toList();

    // Combine and shuffle answers once so option ordering remains stable
    final answers = [cleanCorrect, ...cleanIncorrect];
    if (json['type'] == 'boolean') {
      // For boolean, keep standard ['True', 'False'] order
      answers.sort((a, b) => b.compareTo(a)); // 'True' first, 'False' second
    } else {
      answers.shuffle();
    }

    return QuestionModel(
      type: json['type'] as String? ?? 'multiple',
      difficulty: json['difficulty'] as String? ?? 'easy',
      category: _unescape.convert(json['category'] as String? ?? ''),
      question: cleanQuestion,
      correctAnswer: cleanCorrect,
      incorrectAnswers: cleanIncorrect,
      allAnswers: answers,
    );
  }

  /// Converts QuestionModel instance to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'difficulty': difficulty,
      'category': category,
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
      'selected_answer': selectedAnswer,
      'is_answered': isAnswered,
      'is_timed_out': isTimedOut,
    };
  }

  /// Helper to check if the user's selected answer is correct
  bool get isCorrect => selectedAnswer != null && selectedAnswer == correctAnswer;

  /// Resets the runtime interaction state for replay
  void reset() {
    selectedAnswer = null;
    isAnswered = false;
    isTimedOut = false;
  }
}
