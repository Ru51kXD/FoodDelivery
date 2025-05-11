import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final List<String>? selectedOptions;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.selectedOptions,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedOptions: (json['selectedOptions'] as List?)?.cast<String>(),
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'specialInstructions': specialInstructions,
    };
  }

  double get totalPrice => price * quantity;

  OrderItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    int? quantity,
    List<String>? selectedOptions,
    String? specialInstructions,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
} 