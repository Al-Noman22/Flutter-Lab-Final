import 'package:flutter_test/flutter_test.dart';
import 'package:quizzical/models/category_model.dart';
import 'package:quizzical/models/question_model.dart';

void main() {
  group('CategoryModel Tests', () {
    test('Parses from JSON correctly', () {
      final json = {'id': 9, 'name': 'General Knowledge'};
      final model = CategoryModel.fromJson(json);

      expect(model.id, 9);
      expect(model.name, 'General Knowledge');
      expect(model.shortName, 'General Knowledge');
      expect(model.toJson(), json);
    });

    test('Short name strips category prefixes like Entertainment', () {
      final json = {'id': 10, 'name': 'Entertainment: Books'};
      final model = CategoryModel.fromJson(json);

      expect(model.shortName, 'Books');
    });
  });

  group('QuestionModel Tests', () {
    test('Parses from JSON, unescapes HTML entities, and shuffles answers', () {
      final json = {
        'type': 'multiple',
        'difficulty': 'easy',
        'category': 'Entertainment: Books',
        'question': 'Who wrote &quot;Harry Potter&quot;?',
        'correct_answer': 'J.K. Rowling',
        'incorrect_answers': ['George R.R. Martin', 'J.R.R. Tolkien', 'Stephen King']
      };

      final question = QuestionModel.fromJson(json);

      expect(question.question, 'Who wrote "Harry Potter"?');
      expect(question.correctAnswer, 'J.K. Rowling');
      expect(question.allAnswers.length, 4);
      expect(question.allAnswers.contains('J.K. Rowling'), isTrue);
      expect(question.allAnswers.contains('George R.R. Martin'), isTrue);
      expect(question.isCorrect, isFalse);

      // Verify answer evaluation
      question.selectedAnswer = 'J.K. Rowling';
      question.isAnswered = true;
      expect(question.isCorrect, isTrue);

      question.selectedAnswer = 'Stephen King';
      expect(question.isCorrect, isFalse);
    });

    test('Handles boolean questions with True and False sorted', () {
      final json = {
        'type': 'boolean',
        'difficulty': 'easy',
        'category': 'General Knowledge',
        'question': 'The sky is blue.',
        'correct_answer': 'True',
        'incorrect_answers': ['False']
      };

      final question = QuestionModel.fromJson(json);
      expect(question.allAnswers, ['True', 'False']);
    });
  });
}
