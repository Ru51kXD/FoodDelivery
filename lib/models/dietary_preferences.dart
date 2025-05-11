import 'package:flutter/material.dart';

enum DietaryType {
  vegetarian,    // вегетарианское
  vegan,         // веганское
  glutenFree,    // без глютена
  dairyFree,     // без молока
  lowCarb,       // низкоуглеводное
  lowFat,        // низкожировое
  lowCalorie,    // низкокалорийное
  highProtein,   // высокобелковое
}

class DietaryPreferences {
  final List<DietaryType> types;
  final List<String> allergies;
  final int? maxCalories;
  final bool? excludeSpicy;
  final bool? excludeNuts;
  final bool? excludeSeafood;

  DietaryPreferences({
    required this.types,
    required this.allergies,
    this.maxCalories,
    this.excludeSpicy,
    this.excludeNuts,
    this.excludeSeafood,
  });

  factory DietaryPreferences.fromJson(Map<String, dynamic> json) {
    return DietaryPreferences(
      types: (json['types'] as List<dynamic>)
          .map((e) => DietaryType.values.firstWhere(
                (type) => type.toString() == 'DietaryType.$e',
              ))
          .toList(),
      allergies: (json['allergies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      maxCalories: json['maxCalories'] as int?,
      excludeSpicy: json['excludeSpicy'] as bool?,
      excludeNuts: json['excludeNuts'] as bool?,
      excludeSeafood: json['excludeSeafood'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'types': types.map((e) => e.toString().split('.').last).toList(),
      'allergies': allergies,
      'maxCalories': maxCalories,
      'excludeSpicy': excludeSpicy,
      'excludeNuts': excludeNuts,
      'excludeSeafood': excludeSeafood,
    };
  }

  DietaryPreferences copyWith({
    List<DietaryType>? types,
    List<String>? allergies,
    int? maxCalories,
    bool? excludeSpicy,
    bool? excludeNuts,
    bool? excludeSeafood,
  }) {
    return DietaryPreferences(
      types: types ?? this.types,
      allergies: allergies ?? this.allergies,
      maxCalories: maxCalories ?? this.maxCalories,
      excludeSpicy: excludeSpicy ?? this.excludeSpicy,
      excludeNuts: excludeNuts ?? this.excludeNuts,
      excludeSeafood: excludeSeafood ?? this.excludeSeafood,
    );
  }

  // Получение иконки для типа диеты
  IconData getIconForType(DietaryType type) {
    switch (type) {
      case DietaryType.vegetarian:
        return Icons.eco;
      case DietaryType.vegan:
        return Icons.spa;
      case DietaryType.glutenFree:
        return Icons.no_meals;
      case DietaryType.dairyFree:
        return Icons.no_drinks;
      case DietaryType.lowCarb:
        return Icons.trending_down;
      case DietaryType.lowFat:
        return Icons.trending_down;
      case DietaryType.lowCalorie:
        return Icons.trending_down;
      case DietaryType.highProtein:
        return Icons.trending_up;
    }
  }

  // Получение цвета для типа диеты
  Color getColorForType(DietaryType type) {
    switch (type) {
      case DietaryType.vegetarian:
        return const Color(0xFF4CAF50);
      case DietaryType.vegan:
        return const Color(0xFF8BC34A);
      case DietaryType.glutenFree:
        return const Color(0xFFFFC107);
      case DietaryType.dairyFree:
        return const Color(0xFF2196F3);
      case DietaryType.lowCarb:
        return const Color(0xFF9C27B0);
      case DietaryType.lowFat:
        return const Color(0xFFE91E63);
      case DietaryType.lowCalorie:
        return const Color(0xFF00BCD4);
      case DietaryType.highProtein:
        return const Color(0xFFFF5722);
    }
  }

  // Получение названия для типа диеты
  String getNameForType(DietaryType type) {
    switch (type) {
      case DietaryType.vegetarian:
        return 'Вегетарианское';
      case DietaryType.vegan:
        return 'Веганское';
      case DietaryType.glutenFree:
        return 'Без глютена';
      case DietaryType.dairyFree:
        return 'Без молока';
      case DietaryType.lowCarb:
        return 'Низкоуглеводное';
      case DietaryType.lowFat:
        return 'Низкожировое';
      case DietaryType.lowCalorie:
        return 'Низкокалорийное';
      case DietaryType.highProtein:
        return 'Высокобелковое';
    }
  }
}

extension DietaryTypeExtension on DietaryType {
  String getName() {
    switch (this) {
      case DietaryType.vegetarian:
        return 'Вегетарианское';
      case DietaryType.vegan:
        return 'Веганское';
      case DietaryType.glutenFree:
        return 'Без глютена';
      case DietaryType.dairyFree:
        return 'Без молока';
      case DietaryType.lowCarb:
        return 'Низкоуглеводное';
      case DietaryType.lowFat:
        return 'Низкожировое';
      case DietaryType.lowCalorie:
        return 'Низкокалорийное';
      case DietaryType.highProtein:
        return 'Высокобелковое';
    }
  }

  Color getColor() {
    switch (this) {
      case DietaryType.vegetarian:
        return const Color(0xFF4CAF50);
      case DietaryType.vegan:
        return const Color(0xFF8BC34A);
      case DietaryType.glutenFree:
        return const Color(0xFFFFC107);
      case DietaryType.dairyFree:
        return const Color(0xFF2196F3);
      case DietaryType.lowCarb:
        return const Color(0xFF9C27B0);
      case DietaryType.lowFat:
        return const Color(0xFFE91E63);
      case DietaryType.lowCalorie:
        return const Color(0xFF00BCD4);
      case DietaryType.highProtein:
        return const Color(0xFFFF5722);
    }
  }

  IconData getIcon() {
    switch (this) {
      case DietaryType.vegetarian:
        return Icons.eco;
      case DietaryType.vegan:
        return Icons.spa;
      case DietaryType.glutenFree:
        return Icons.no_meals;
      case DietaryType.dairyFree:
        return Icons.no_drinks;
      case DietaryType.lowCarb:
        return Icons.trending_down;
      case DietaryType.lowFat:
        return Icons.trending_down;
      case DietaryType.lowCalorie:
        return Icons.trending_down;
      case DietaryType.highProtein:
        return Icons.trending_up;
    }
  }
} 