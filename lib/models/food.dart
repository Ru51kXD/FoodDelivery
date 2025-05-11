class Food {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String restaurantId;
  final List<String> categories;
  final bool isAvailable;
  final double? rating;
  final int? reviewCount;
  final bool? isVegetarian;
  final bool? isSpicy;
  final List<String>? ingredients;
  final Map<String, double>? nutritionInfo;
  final List<FoodOption>? options;
  final int? preparationTime;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.restaurantId,
    required this.categories,
    required this.isAvailable,
    this.rating,
    this.reviewCount,
    this.isVegetarian,
    this.isSpicy,
    this.ingredients,
    this.nutritionInfo,
    this.options,
    this.preparationTime,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      restaurantId: json['restaurant_id'] as String,
      categories: List<String>.from(json['categories'] as List),
      isAvailable: json['is_available'] as bool,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      isVegetarian: json['is_vegetarian'] as bool?,
      isSpicy: json['is_spicy'] as bool?,
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients'] as List) : null,
      nutritionInfo: json['nutrition_info'] != null
          ? Map<String, double>.from(
              (json['nutrition_info'] as Map).map(
                (key, value) => MapEntry(key as String, (value as num).toDouble()),
              ),
            )
          : null,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => FoodOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      preparationTime: json['preparationTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'restaurant_id': restaurantId,
      'categories': categories,
      'is_available': isAvailable,
      'rating': rating,
      'review_count': reviewCount,
      'is_vegetarian': isVegetarian,
      'is_spicy': isSpicy,
      'ingredients': ingredients,
      'nutrition_info': nutritionInfo,
      'options': options?.map((e) => e.toJson()).toList(),
      'preparationTime': preparationTime,
    };
  }
}

class FoodOption {
  final String name;
  final List<FoodOptionChoice> choices;
  final bool required;
  final int maxChoices;

  FoodOption({
    required this.name,
    required this.choices,
    this.required = false,
    this.maxChoices = 1,
  });

  factory FoodOption.fromJson(Map<String, dynamic> json) {
    return FoodOption(
      name: json['name'] as String,
      choices: (json['choices'] as List)
          .map((e) => FoodOptionChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      required: json['required'] as bool? ?? false,
      maxChoices: json['maxChoices'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices.map((e) => e.toJson()).toList(),
      'required': required,
      'maxChoices': maxChoices,
    };
  }
}

class FoodOptionChoice {
  final String name;
  final double priceAdd;

  FoodOptionChoice({
    required this.name,
    required this.priceAdd,
  });

  factory FoodOptionChoice.fromJson(Map<String, dynamic> json) {
    return FoodOptionChoice(
      name: json['name'] as String,
      priceAdd: (json['priceAdd'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priceAdd': priceAdd,
    };
  }
} 