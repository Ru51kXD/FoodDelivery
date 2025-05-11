import 'food.dart';
import 'selected_option.dart';

class CartItem {
  final String id;
  final Food food;
  final int quantity;
  final String? specialInstructions;
  final List<SelectedOption>? selectedOptions;

  CartItem({
    required this.id,
    required this.food,
    required this.quantity,
    this.specialInstructions,
    this.selectedOptions,
  });

  double get totalPrice {
    double basePrice = food.price * quantity;
    double optionsPrice = 0;

    if (selectedOptions != null) {
      for (var option in selectedOptions!) {
        for (var choice in option.choices) {
          optionsPrice += choice.price * quantity;
        }
      }
    }

    return basePrice + optionsPrice;
  }

  CartItem copyWith({
    String? id,
    Food? food,
    int? quantity,
    String? specialInstructions,
    List<SelectedOption>? selectedOptions,
  }) {
    return CartItem(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      food: Food.fromJson(json['food'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      specialInstructions: json['specialInstructions'] as String?,
      selectedOptions: json['selectedOptions'] != null
          ? (json['selectedOptions'] as List)
              .map((e) => SelectedOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'selectedOptions': selectedOptions?.map((e) => e.toJson()).toList(),
    };
  }
} 