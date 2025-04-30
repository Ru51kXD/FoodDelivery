class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int preparationTime; // в минутах
  final bool isPopular;
  final bool isVegetarian;
  final List<String> ingredients;
  final String? restaurantId;
  final List<String>? categories;
  final int? reviewCount;
  final bool? isSpicy;
  final List<FoodOption>? options;
  final bool? isAvailable;
  final bool? isFeatured;
  
  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.preparationTime,
    this.isPopular = false,
    this.isVegetarian = false,
    this.ingredients = const [],
    this.restaurantId,
    this.categories,
    this.reviewCount,
    this.isSpicy,
    this.options,
    this.isAvailable,
    this.isFeatured,
  });
  
  // Создание из JSON для загрузки из API
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) ? json['price'].toDouble() : json['price'],
      imageUrl: json['imageUrl'],
      category: json['category'] ?? "",
      rating: (json['rating'] is int) ? json['rating'].toDouble() : json['rating'],
      preparationTime: json['preparationTime'],
      isPopular: json['isPopular'] ?? false,
      isVegetarian: json['isVegetarian'] ?? false,
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : [],
      restaurantId: json['restaurantId'],
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : null,
      reviewCount: json['reviewCount'],
      isSpicy: json['isSpicy'],
      options: json['options'] != null
          ? List<FoodOption>.from(
              json['options'].map((option) => FoodOption.fromJson(option)))
          : null,
      isAvailable: json['isAvailable'],
      isFeatured: json['isFeatured'],
    );
  }
  
  // Преобразование в JSON для отправки в API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'preparationTime': preparationTime,
      'isPopular': isPopular,
      'isVegetarian': isVegetarian,
      'ingredients': ingredients,
      'restaurantId': restaurantId,
      'categories': categories,
      'reviewCount': reviewCount,
      'isSpicy': isSpicy,
      'options': options != null ? options!.map((option) => option.toJson()).toList() : null,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
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
      name: json['name'],
      choices: List<FoodOptionChoice>.from(
          json['choices'].map((choice) => FoodOptionChoice.fromJson(choice))),
      required: json['required'] ?? false,
      maxChoices: json['maxChoices'] ?? 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices.map((choice) => choice.toJson()).toList(),
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
    this.priceAdd = 0.0,
  });
  
  factory FoodOptionChoice.fromJson(Map<String, dynamic> json) {
    return FoodOptionChoice(
      name: json['name'],
      priceAdd: json['priceAdd']?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priceAdd': priceAdd,
    };
  }
} 