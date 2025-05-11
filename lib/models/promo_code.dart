import 'package:flutter/material.dart';

enum PromoCodeType {
  percentage,  // процентная скидка
  fixed,       // фиксированная сумма
  freeDelivery, // бесплатная доставка
  freeItem,    // бесплатный товар
}

class PromoCode {
  final String code;
  final String description;
  final PromoCodeType type;
  final double value; // процент или сумма скидки
  final DateTime validFrom;
  final DateTime validUntil;
  final double? minOrderAmount; // минимальная сумма заказа
  final int? maxUses; // максимальное количество использований
  final int currentUses; // текущее количество использований
  final List<String>? applicableRestaurants; // список ресторанов, где действует промокод
  final List<String>? applicableCategories; // категории блюд, на которые действует промокод
  final bool isActive;

  PromoCode({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    this.minOrderAmount,
    this.maxUses,
    this.currentUses = 0,
    this.applicableRestaurants,
    this.applicableCategories,
    this.isActive = true,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'],
      description: json['description'],
      type: PromoCodeType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => PromoCodeType.percentage,
      ),
      value: json['value'].toDouble(),
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      maxUses: json['maxUses'],
      currentUses: json['currentUses'] ?? 0,
      applicableRestaurants: json['applicableRestaurants'] != null
          ? List<String>.from(json['applicableRestaurants'])
          : null,
      applicableCategories: json['applicableCategories'] != null
          ? List<String>.from(json['applicableCategories'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'minOrderAmount': minOrderAmount,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'applicableRestaurants': applicableRestaurants,
      'applicableCategories': applicableCategories,
      'isActive': isActive,
    };
  }

  // Проверка валидности промокода
  bool isValid(DateTime currentDate, double orderAmount) {
    if (!isActive) return false;
    if (currentDate.isBefore(validFrom) || currentDate.isAfter(validUntil)) return false;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return false;
    if (maxUses != null && currentUses >= maxUses!) return false;
    return true;
  }

  // Расчет скидки
  double calculateDiscount(double orderAmount) {
    switch (type) {
      case PromoCodeType.percentage:
        return orderAmount * (value / 100);
      case PromoCodeType.fixed:
        return value;
      case PromoCodeType.freeDelivery:
        return 0; // Скидка на доставку обрабатывается отдельно
      case PromoCodeType.freeItem:
        return 0; // Бесплатный товар обрабатывается отдельно
    }
  }

  // Получение текста скидки для отображения
  String get discountText {
    switch (type) {
      case PromoCodeType.percentage:
        return '${value.toInt()}% скидка';
      case PromoCodeType.fixed:
        return '${value.toInt()} ₽ скидка';
      case PromoCodeType.freeDelivery:
        return 'Бесплатная доставка';
      case PromoCodeType.freeItem:
        return 'Бесплатный товар';
    }
  }
} 