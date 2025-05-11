import 'package:flutter/material.dart';

enum FavoriteType {
  restaurant,
  dish,
}

class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final FavoriteType type;
  final DateTime addedAt;
  final String? name;
  final String? imageUrl;
  final String? description;
  final double? rating;
  final double? price;

  Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.addedAt,
    this.name,
    this.imageUrl,
    this.description,
    this.rating,
    this.price,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['userId'],
      itemId: json['itemId'],
      type: FavoriteType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => FavoriteType.restaurant,
      ),
      addedAt: DateTime.parse(json['addedAt']),
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      rating: json['rating']?.toDouble(),
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'type': type.toString().split('.').last,
      'addedAt': addedAt.toIso8601String(),
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'price': price,
    };
  }
} 