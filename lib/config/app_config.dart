import 'package:flutter/material.dart';

/// Глобальные настройки приложения
class AppConfig {
  // Валюта
  static const String currencySymbol = 'тг';  // Аббревиатура тенге вместо символа
  static const String currencyName = 'тенге'; // Название валюты
  static const String currencyCode = 'KZT';   // Код валюты
  
  // Форматирование валюты
  static String formatCurrency(num amount) {
    return '${amount.toStringAsFixed(0)} $currencySymbol';
  }
  
  // Форматирование цены с отображением дробной части только при необходимости
  static String formatPrice(num price) {
    if (price == price.toInt()) {
      return '${price.toInt()} $currencySymbol';
    } else {
      return '${price.toStringAsFixed(1)} $currencySymbol';
    }
  }
  
  // Локализация
  static const Locale defaultLocale = Locale('ru', 'RU');
  
  // Другие настройки приложения...
  static const int defaultPageSize = 20;
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const double defaultPadding = 16.0;
} 