import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem food;
  int quantity;
  final List<String> additionalOptions;
  final String? specialInstructions;
  final List<SelectedOption> selectedOptions;
  
  CartItem({
    required this.id,
    required this.food,
    this.quantity = 1,
    this.additionalOptions = const [],
    this.specialInstructions,
    this.selectedOptions = const [],
  });
  
  // Расчет общей стоимости элемента корзины с учетом количества и дополнительных опций
  double get totalPrice {
    double basePrice = food.price * quantity;
    double optionsPrice = selectedOptions.fold(0.0, 
      (total, option) => total + option.choices.fold(0.0, 
        (sum, choice) => sum + choice.priceAdd
      )
    );
    return basePrice + (optionsPrice * quantity);
  }
  
  // Создание из JSON для хранения в localStorage
  factory CartItem.fromJson(Map<String, dynamic> json, FoodItem foodItem) {
    return CartItem(
      id: json['id'],
      food: foodItem,
      quantity: json['quantity'],
      additionalOptions: List<String>.from(json['additionalOptions'] ?? []),
      specialInstructions: json['specialInstructions'],
      selectedOptions: json['selectedOptions'] != null
          ? List<SelectedOption>.from(
              json['selectedOptions'].map((option) => SelectedOption.fromJson(option)))
          : [],
    );
  }
  
  // Преобразование в JSON для хранения в localStorage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': food.id,
      'quantity': quantity,
      'additionalOptions': additionalOptions,
      'specialInstructions': specialInstructions,
      'selectedOptions': selectedOptions.map((option) => option.toJson()).toList(),
    };
  }
  
  // Создание копии с новыми значениями
  CartItem copyWith({
    String? id,
    FoodItem? food,
    int? quantity,
    List<String>? additionalOptions,
    String? specialInstructions,
    List<SelectedOption>? selectedOptions,
  }) {
    return CartItem(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      additionalOptions: additionalOptions ?? this.additionalOptions,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}

class SelectedOption {
  final String name;
  final List<SelectedChoice> choices;
  
  SelectedOption({
    required this.name,
    required this.choices,
  });
  
  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'],
      choices: List<SelectedChoice>.from(
          json['choices'].map((choice) => SelectedChoice.fromJson(choice))),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
  }
}

class SelectedChoice {
  final String name;
  final double priceAdd;
  
  SelectedChoice({
    required this.name,
    required this.priceAdd,
  });
  
  factory SelectedChoice.fromJson(Map<String, dynamic> json) {
    return SelectedChoice(
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