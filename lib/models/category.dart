import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String imageUrl;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrl,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String,
      icon: _getIconFromString(json['icon'] as String),
      color: Color(int.parse(json['color'] as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'icon': icon.codePoint.toRadixString(16),
      'color': color.value.toRadixString(16),
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_bar':
        return Icons.local_bar;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'icecream':
        return Icons.icecream;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'dinner_dining':
        return Icons.dinner_dining;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'ramen_dining':
        return Icons.ramen_dining;
      default:
        return Icons.restaurant;
    }
  }
} 