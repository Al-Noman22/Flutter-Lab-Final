import 'package:flutter/material.dart';

/// Model representing a trivia category from OpenTDB
class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  /// Factory constructor to parse category from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  /// Converts CategoryModel instance to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Returns cleaned/simplified name for display (e.g. removes "Entertainment: ")
  String get shortName {
    if (name.contains(': ')) {
      return name.split(': ').last;
    }
    return name;
  }

  /// Image path for the category card
  String? get imagePath {
    switch (id) {
      case 9:
        return 'assets/categories/raw_general_knowledge.png';
      case 10:
        return 'assets/categories/raw_books.png';
      case 17:
        return 'assets/categories/raw_science_nature.png';
      case 23:
        return 'assets/categories/raw_history.png';
      case 25:
        return 'assets/categories/raw_art.png';
      case 28:
        return 'assets/categories/raw_vehicles.png';
      default:
        return 'assets/categories/category_$id.png';
    }
  }

  /// Color variation for the category card (matching PDF screenshot)
  Color get backgroundColor {
    switch (id) {
      case 9: // General Knowledge
        return const Color(0xFFC3D4FE); // Blue
      case 10: // Books
        return const Color(0xFFC1F3CB); // Mint Green
      case 23: // History
        return const Color(0xFFFFF7CC); // Light Yellow
      case 17: // Science & Nature
        return const Color(0xFFF1C7FE); // Purple
      case 25: // Art
        return const Color(0xFFFDC8CC); // Pink
      case 28: // Vehicles
        return const Color(0xFFFFE7CC); // Peach/Orange
      default:
        // Hash code fallback
        final colors = [
          const Color(0xFFC3D4FE),
          const Color(0xFFC1F3CB),
          const Color(0xFFFFF7CC),
          const Color(0xFFF1C7FE),
          const Color(0xFFFDC8CC),
          const Color(0xFFFFE7CC),
        ];
        return colors[id % colors.length];
    }
  }

  /// Primary accent color matching the pastel background
  Color get accentColor {
    switch (id) {
      case 9:
        return const Color(0xFF5577D9);
      case 10:
        return const Color(0xFF40916C);
      case 17:
        return const Color(0xFF904AC2);
      case 23:
        return const Color(0xFFC6A000);
      case 25:
        return const Color(0xFFD36069);
      case 28:
        return const Color(0xFFD97926);
      default:
        return const Color(0xFF005C53);
    }
  }

  /// Icon corresponding to the category (fallback)
  IconData get icon {
    switch (id) {
      case 9: // General Knowledge
        return Icons.public;
      case 10: // Books
        return Icons.menu_book;
      case 11: // Film
        return Icons.movie;
      case 12: // Music
        return Icons.music_note;
      case 13: // Musicals & Theatres
        return Icons.theater_comedy;
      case 14: // Television
        return Icons.tv;
      case 15: // Video Games
        return Icons.sports_esports;
      case 16: // Board Games
        return Icons.casino;
      case 17: // Science & Nature
        return Icons.biotech;
      case 18: // Science: Computers
        return Icons.computer;
      case 19: // Science: Mathematics
        return Icons.calculate;
      case 20: // Mythology
        return Icons.auto_stories;
      case 21: // Sports
        return Icons.sports_soccer;
      case 22: // Geography
        return Icons.travel_explore;
      case 23: // History
        return Icons.history_edu;
      case 24: // Politics
        return Icons.gavel;
      case 25: // Art
        return Icons.palette;
      case 26: // Celebrities
        return Icons.star;
      case 27: // Animals
        return Icons.pets;
      case 28: // Vehicles
        return Icons.directions_car;
      case 29: // Comics
        return Icons.auto_stories;
      case 30: // Gadgets
        return Icons.devices;
      case 31: // Anime & Manga
        return Icons.animation;
      case 32: // Cartoon
        return Icons.smart_toy;
      default:
        return Icons.quiz;
    }
  }
}
