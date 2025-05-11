import 'package:flutter/material.dart';

class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> categories;
  final List<String> tags;
  final Map<String, double> nutritionalInfo;
  final List<String> ingredients;
  final List<String> allergens;
  final bool isSpicy;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isHalal;
  final bool isKosher;
  final bool isLowCarb;
  final bool isLowFat;
  final bool isLowCalorie;
  final bool isHighProtein;
  final double rating;
  final int reviewCount;
  final int orderCount;
  final bool isAvailable;
  final int preparationTime; // в минутах

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.categories = const [],
    this.tags = const [],
    this.nutritionalInfo = const {},
    this.ingredients = const [],
    this.allergens = const [],
    this.isSpicy = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isLactoseFree = false,
    this.isHalal = false,
    this.isKosher = false,
    this.isLowCarb = false,
    this.isLowFat = false,
    this.isLowCalorie = false,
    this.isHighProtein = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.orderCount = 0,
    this.isAvailable = true,
    this.preparationTime = 30,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      nutritionalInfo: Map<String, double>.from(json['nutritionalInfo'] ?? {}),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      isSpicy: json['isSpicy'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isLactoseFree: json['isLactoseFree'] ?? false,
      isHalal: json['isHalal'] ?? false,
      isKosher: json['isKosher'] ?? false,
      isLowCarb: json['isLowCarb'] ?? false,
      isLowFat: json['isLowFat'] ?? false,
      isLowCalorie: json['isLowCalorie'] ?? false,
      isHighProtein: json['isHighProtein'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      orderCount: json['orderCount'] as int? ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      preparationTime: json['preparationTime'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories,
      'tags': tags,
      'nutritionalInfo': nutritionalInfo,
      'ingredients': ingredients,
      'allergens': allergens,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isLactoseFree': isLactoseFree,
      'isHalal': isHalal,
      'isKosher': isKosher,
      'isLowCarb': isLowCarb,
      'isLowFat': isLowFat,
      'isLowCalorie': isLowCalorie,
      'isHighProtein': isHighProtein,
      'rating': rating,
      'reviewCount': reviewCount,
      'orderCount': orderCount,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
    };
  }

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    List<String>? tags,
    Map<String, double>? nutritionalInfo,
    List<String>? ingredients,
    List<String>? allergens,
    bool? isSpicy,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isLactoseFree,
    bool? isHalal,
    bool? isKosher,
    bool? isLowCarb,
    bool? isLowFat,
    bool? isLowCalorie,
    bool? isHighProtein,
    double? rating,
    int? reviewCount,
    int? orderCount,
    bool? isAvailable,
    int? preparationTime,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      isSpicy: isSpicy ?? this.isSpicy,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isLactoseFree: isLactoseFree ?? this.isLactoseFree,
      isHalal: isHalal ?? this.isHalal,
      isKosher: isKosher ?? this.isKosher,
      isLowCarb: isLowCarb ?? this.isLowCarb,
      isLowFat: isLowFat ?? this.isLowFat,
      isLowCalorie: isLowCalorie ?? this.isLowCalorie,
      isHighProtein: isHighProtein ?? this.isHighProtein,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      orderCount: orderCount ?? this.orderCount,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
    );
  }

  List<IconData> get dietaryIcons {
    final icons = <IconData>[];
    if (isVegetarian) icons.add(Icons.eco);
    if (isVegan) icons.add(Icons.spa);
    if (isGlutenFree) icons.add(Icons.no_meals);
    if (isLactoseFree) icons.add(Icons.no_drinks);
    if (isHalal) icons.add(Icons.mosque);
    if (isKosher) icons.add(Icons.synagogue);
    if (isLowCarb) icons.add(Icons.trending_down);
    if (isLowFat) icons.add(Icons.trending_down);
    if (isLowCalorie) icons.add(Icons.local_fire_department);
    if (isHighProtein) icons.add(Icons.fitness_center);
    if (isSpicy) icons.add(Icons.local_fire_department);
    return icons;
  }

  List<String> get dietaryTexts {
    final texts = <String>[];
    if (isVegetarian) texts.add('Вегетарианское');
    if (isVegan) texts.add('Веганское');
    if (isGlutenFree) texts.add('Без глютена');
    if (isLactoseFree) texts.add('Без лактозы');
    if (isHalal) texts.add('Халяль');
    if (isKosher) texts.add('Кошерное');
    if (isLowCarb) texts.add('Низкоуглеводное');
    if (isLowFat) texts.add('Низкожирное');
    if (isLowCalorie) texts.add('Низкокалорийное');
    if (isHighProtein) texts.add('Высокобелковое');
    if (isSpicy) texts.add('Острое');
    return texts;
  }
} 