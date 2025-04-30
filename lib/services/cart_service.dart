import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import 'food_service.dart';

class CartService {
  static const String _cartKey = 'user_cart';
  final FoodService _foodService = FoodService();
  
  // Загрузка корзины из хранилища
  Future<List<CartItem>> loadCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? cartData = prefs.getStringList(_cartKey);
      
      if (cartData == null || cartData.isEmpty) {
        return [];
      }
      
      // Преобразование данных в объекты CartItem
      final List<CartItem> cartItems = [];
      
      for (String itemData in cartData) {
        final Map<String, dynamic> json = jsonDecode(itemData);
        final String foodId = json['foodId'];
        
        // Получение данных о блюде
        final FoodItem? food = await _foodService.getFoodById(foodId);
        
        if (food != null) {
          cartItems.add(CartItem.fromJson(json, food));
        }
      }
      
      return cartItems;
    } catch (e) {
      print('Ошибка при загрузке корзины: $e');
      return [];
    }
  }
  
  // Сохранение корзины в хранилище
  Future<void> saveCart(List<CartItem> items) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Преобразование объектов CartItem в JSON строки
      final List<String> cartData = items.map((item) => jsonEncode(item.toJson())).toList();
      
      await prefs.setStringList(_cartKey, cartData);
    } catch (e) {
      print('Ошибка при сохранении корзины: $e');
      throw Exception('Не удалось сохранить корзину');
    }
  }
  
  // Очистка корзины
  Future<void> clearCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Ошибка при очистке корзины: $e');
      throw Exception('Не удалось очистить корзину');
    }
  }
} 