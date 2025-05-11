import 'package:flutter/material.dart';

enum PromotionType {
  discount,      // скидка
  freeDelivery,  // бесплатная доставка
  gift,          // подарок
  combo,         // комбо-предложение
  loyalty,       // программа лояльности
}

PromotionType.values.forEach((type) {
  type.getName();
  type.getColor();
  type.getIcon();
});

class Promotion {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final PromotionType type;
  final DateTime startDate;
  final DateTime endDate;
  final double? discountPercent;
  final double? minOrderAmount;
  final String? promoCode;
  final bool isActive;
  final List<String>? applicableCategories;
  final List<String>? applicableRestaurants;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.discountPercent,
    this.minOrderAmount,
    this.promoCode,
    this.isActive = true,
    this.applicableCategories,
    this.applicableRestaurants,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: PromotionType.values.firstWhere(
        (e) => e.toString() == 'PromotionType.${json['type']}',
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      promoCode: json['promoCode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      applicableCategories: (json['applicableCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      applicableRestaurants: (json['applicableRestaurants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'discountPercent': discountPercent,
      'minOrderAmount': minOrderAmount,
      'promoCode': promoCode,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'applicableRestaurants': applicableRestaurants,
    };
  }

  Color getTypeColor() {
    return type.getColor();
  }

  IconData getTypeIcon() {
    return type.getIcon();
  }

  String getTypeName() {
    return type.getName();
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isCurrent => !isExpired && !isUpcoming;
} 