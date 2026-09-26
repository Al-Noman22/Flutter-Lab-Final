# Quizzical — Mobile App Development Lab Project

A clean, responsive, and accessible trivia quiz application built with Flutter conforming to the CSE-3212 Lab Final Exam requirements and OpenTDB specifications.

---

## 📱 App Flow & Architecture

The application implements the required navigation and state lifecycle:

```mermaid
graph TD
    Welcome[Screen 1: Welcome Screen] --> CategorySelection[Screen 2: Category Selection]
    CategorySelection --> QuizConfig[Screen 3: Quiz Configuration]
    QuizConfig --> QuizPlay[Screen 4: Quiz Gameplay]
    QuizPlay --> Results[Screen 5: Results Screen]
    Results -->|Play Again (Resets state, preserves config)| CategorySelection
```

---

## ✨ Features Implemented

1. **Screen 1 — Welcome**:
   - App title: **"Quizzical"**
   - Candidate / Student subtitle: **"Your_Name"**
   - High-fidelity vector illustration matching Figma (avatar with giant 3D question mark, floating spheres, and sparkle accents).
   - Primary CTA: **"GET STARTED"** in deep teal (`#005953`), navigating to Category Selection.

2. **Screen 2 — Category Selection**:
   - Fetches live categories from OpenTDB (`https://opentdb.com/api_category.php`).
   - In-memory session caching (`_cachedCategories` ensures categories load once per session).
   - 2-column responsive grid with pastel color palettes and iconography for all categories.
   - Animated shimmer skeleton loader while fetching data.
   - Retry banner on network error.
   - Tapping a category navigates to Quiz Configuration with the category ID & name.

3. **Screen 3 — Quiz Configuration**:
   - Gear & switches custom illustration.
   - Selected category badge display.
   - Question amount slider with interactive count indicator (range 1–50, default 10).
   - Difficulty dropdown (`Any Difficulty`, `Easy`, `Medium`, `Hard`).
   - Question type dropdown (`Multiple Choice`, `True / False`).
   - **"START"** button with loading indicator that fetches questions from OpenTDB.

4. **Screen 4 — Quiz Gameplay**:
   - Displays 1 question at a time.
   - Question counter (e.g. `7/10`) and animated blue progress bar.
   - `EXIT` button with confirmation dialog.
   - Per-question timer (25s countdown). On timeout, question is marked unanswered/incorrect and the correct answer is revealed.
   - Unescapes all HTML entities (`&quot;`, `&#039;`, `&amp;`, etc.) from API.
   - Shuffled answer buttons (4 for multiple choice, 2 for True / False).
   - Visual feedback:
     - **Correct answer**: Mint green card (`#C8E6C9`) with green checkmark icon.
     - **Incorrect choice**: Soft coral card (`#FFCDD2`) with red cross icon and revealed correct answer.
   - **"Next" / "View Results"** button advances to next question or completes the quiz.

5. **Screen 5 — Results**:
   - High score (≥50%): Confetti party horn illustration, **"Congratulation"**, green badge (e.g. `80%`), encouraging message.
   - Low score (<50%): Settings gear illustration, **"Keep Trying!"**, red/orange badge (e.g. `33%`), motivational feedback.
   - Summary: "You scored X/Y!".
   - Detailed performance tiles: Accuracy %, Correct count, Incorrect count, and Total elapsed time (`01:24`).
   - **"PLAY AGAIN"** CTA button: Resets quiz state, preserves last configuration via `SharedPreferences`, and returns to Category Selection.

---

## 📝 Models for Answer Script

The written models for the exam answer script are also stored in [ANSWER_SCRIPT_MODELS.md](file:///g:/Lab%20Final%20Flutter/ANSWER_SCRIPT_MODELS.md).

### 1. `CategoryModel`
```dart
class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### 2. `QuestionModel`
```dart
import 'package:html_unescape/html_unescape.dart';

final HtmlUnescape _unescape = HtmlUnescape();

class QuestionModel {
  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

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

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'] as String? ?? '';
    final rawCorrect = json['correct_answer'] as String? ?? '';
    final rawIncorrect = (json['incorrect_answers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final cleanQuestion = _unescape.convert(rawQuestion);
    final cleanCorrect = _unescape.convert(rawCorrect);
    final cleanIncorrect = rawIncorrect.map((e) => _unescape.convert(e)).toList();

    final answers = [cleanCorrect, ...cleanIncorrect];
    if (json['type'] == 'boolean') {
      answers.sort((a, b) => b.compareTo(a));
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

  bool get isCorrect => selectedAnswer != null && selectedAnswer == correctAnswer;
}
```

---

## 🚀 How to Run

```bash
# 1. Get dependencies
flutter pub get

# 2. Run analysis and tests
flutter analyze
flutter test

# 3. Run the application
flutter run -d chrome
# or
flutter run -d windows
```
