import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/question_model.dart';

class ApiService {
  static const String _categoryUrl = 'https://opentdb.com/api_category.php';
  static const String _questionsBaseUrl = 'https://opentdb.com/api.php';

  // In-memory cache for categories during session
  static List<CategoryModel>? _cachedCategories;

  /// Fetches trivia categories. Cached during the session.
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    try {
      final response = await http.get(Uri.parse(_categoryUrl)).timeout(
        const Duration(seconds: 12),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> list = data['trivia_categories'] as List<dynamic>? ?? [];
        final categories = list.map((item) => CategoryModel.fromJson(item)).toList();
        _cachedCategories = categories;
        return categories;
      } else {
        throw Exception('Failed to load categories: Server returned status ${response.statusCode}');
      }
    } catch (e) {
      if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
        return _cachedCategories!;
      }
      rethrow;
    }
  }

  /// Fetches questions based on configuration parameters
  Future<List<QuestionModel>> getQuestions({
    required int amount,
    required int categoryId,
    String? difficulty, // 'easy', 'medium', 'hard', or null/'any'
    String? type, // 'multiple', 'boolean', or null/'any'
  }) async {
    final queryParams = <String, String>{
      'amount': amount.toString(),
      'category': categoryId.toString(),
    };

    if (difficulty != null && difficulty.isNotEmpty && difficulty.toLowerCase() != 'any') {
      queryParams['difficulty'] = difficulty.toLowerCase();
    }

    if (type != null && type.isNotEmpty && type.toLowerCase() != 'any') {
      queryParams['type'] = type.toLowerCase();
    }

    final uri = Uri.parse(_questionsBaseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final int responseCode = data['response_code'] as int? ?? 0;

      if (responseCode == 0) {
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
        if (results.isEmpty) {
          throw Exception('No questions returned by the server for this configuration.');
        }
        return results.map((item) => QuestionModel.fromJson(item)).toList();
      } else if (responseCode == 1) {
        // Not enough questions in OpenTDB for this strict filter combination.
        // Try fallback with less restrictive parameters (e.g., any difficulty/type)
        if (queryParams.containsKey('difficulty') || queryParams.containsKey('type')) {
          return getQuestions(
            amount: amount,
            categoryId: categoryId,
            difficulty: null,
            type: null,
          );
        }
        throw Exception('Not enough questions available for the selected category.');
      } else {
        throw Exception('API error code: $responseCode');
      }
    } else {
      throw Exception('Failed to load questions: Status ${response.statusCode}');
    }
  }
}
