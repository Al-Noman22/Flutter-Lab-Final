import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyAmount = 'last_quiz_amount';
  static const String _keyDifficulty = 'last_quiz_difficulty';
  static const String _keyType = 'last_quiz_type';
  static const String _keyCategoryId = 'last_category_id';
  static const String _keyCategoryName = 'last_category_name';

  /// Saves quiz configuration into SharedPreferences
  Future<void> saveConfig({
    required int amount,
    required String difficulty,
    required String type,
    int? categoryId,
    String? categoryName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAmount, amount);
    await prefs.setString(_keyDifficulty, difficulty);
    await prefs.setString(_keyType, type);
    if (categoryId != null) {
      await prefs.setInt(_keyCategoryId, categoryId);
    }
    if (categoryName != null) {
      await prefs.setString(_keyCategoryName, categoryName);
    }
  }

  /// Loads stored configuration, providing defaults if none are stored
  Future<Map<String, dynamic>> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'amount': prefs.getInt(_keyAmount) ?? 10,
      'difficulty': prefs.getString(_keyDifficulty) ?? 'Any Difficulty',
      'type': prefs.getString(_keyType) ?? 'Multiple Choice',
      'categoryId': prefs.getInt(_keyCategoryId),
      'categoryName': prefs.getString(_keyCategoryName),
    };
  }
}
