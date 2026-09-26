# Answer Script: Category and Question Models

## 1. Category Model (`CategoryModel`)

```dart
class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  // Factory method to construct CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Method to serialize CategoryModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

---

## 2. Question Model (`QuestionModel`)

```dart
import 'package:html_unescape/html_unescape.dart';

final HtmlUnescape _unescape = HtmlUnescape();

class QuestionModel {
  final String type;             // 'multiple' or 'boolean'
  final String difficulty;       // 'easy', 'medium', 'hard'
  final String category;         // Category name
  final String question;         // Question statement
  final String correctAnswer;    // Correct answer string
  final List<String> incorrectAnswers; // List of incorrect answers
  final List<String> allAnswers; // Shuffled list of options

  String? selectedAnswer;        // User's selected option
  bool isAnswered;               // Has user confirmed an answer or timed out
  bool isTimedOut;               // Did the timer expire

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

  // Factory constructor to construct QuestionModel from OpenTDB API response
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'] as String? ?? '';
    final rawCorrect = json['correct_answer'] as String? ?? '';
    final rawIncorrect = (json['incorrect_answers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Unescape HTML encoded characters from API (e.g., &quot;, &#039;)
    final cleanQuestion = _unescape.convert(rawQuestion);
    final cleanCorrect = _unescape.convert(rawCorrect);
    final cleanIncorrect = rawIncorrect.map((e) => _unescape.convert(e)).toList();

    // Prepare all shuffled options
    final answers = [cleanCorrect, ...cleanIncorrect];
    if (json['type'] == 'boolean') {
      answers.sort((a, b) => b.compareTo(a)); // True, False
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

  // Helper getter to evaluate whether selected answer is correct
  bool get isCorrect => selectedAnswer != null && selectedAnswer == correctAnswer;

  // Convert to JSON Map
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
}
```
