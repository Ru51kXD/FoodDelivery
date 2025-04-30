import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final Uuid _uuid = const Uuid();
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  
  // Инициализация корзины
  Future<void> initCart() async {
    _setLoading(true);
    try {
      _items = await _cartService.loadCart();
      notifyListeners();
    } catch (error) {
      _setError('Не удалось загрузить корзину: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление товара в корзину
  Future<void> addToCart(
    FoodItem food, {
    int quantity = 1,
    List<String> additionalOptions = const [],
    String? specialInstructions,
    List<SelectedOption> selectedOptions = const [],
  }) async {
    // Проверяем, есть ли уже такой товар в корзине
    final index = _items.indexWhere(
      (item) => 
        item.food.id == food.id && 
        _areListsEqual(item.additionalOptions, additionalOptions) &&
        item.specialInstructions == specialInstructions &&
        _areSelectedOptionsEqual(item.selectedOptions, selectedOptions)
    );
    
    if (index >= 0) {
      // Если товар уже есть в корзине, увеличиваем количество
      await updateItemQuantity(_items[index], _items[index].quantity + quantity);
    } else {
      // Если товара нет, добавляем новый
      final cartItem = CartItem(
        id: _uuid.v4(),
        food: food,
        quantity: quantity,
        additionalOptions: additionalOptions,
        specialInstructions: specialInstructions,
        selectedOptions: selectedOptions,
      );
      
      _items.add(cartItem);
      await _saveCart();
      notifyListeners();
    }
  }
  
  // Удаление товара из корзины
  Future<void> removeFromCart(CartItem item) async {
    _items.remove(item);
    await _saveCart();
    notifyListeners();
  }
  
  // Обновление количества товара
  Future<void> updateItemQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(item);
      return;
    }
    
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      await _saveCart();
      notifyListeners();
    }
  }
  
  // Очистка корзины
  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }
  
  // Получение товара по ID
  CartItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Проверка наличия товара в корзине
  bool hasItem(String foodId) {
    return _items.any((item) => item.food.id == foodId);
  }
  
  // Проверка наличия товара в корзине по ID (альтернативный метод)
  bool isInCart(String foodId) {
    return _items.any((item) => item.food.id == foodId);
  }
  
  // Удаление товара из корзины по ID товара
  Future<void> removeFromCartById(String foodId) async {
    final itemIndex = _items.indexWhere((item) => item.food.id == foodId);
    if (itemIndex >= 0) {
      await removeFromCart(_items[itemIndex]);
    }
  }
  
  // Расчет стоимости доставки
  double calculateDeliveryFee() {
    // Простой пример расчета стоимости доставки
    if (totalPrice > 2000) return 0; // Бесплатная доставка при заказе от 2000
    if (totalPrice > 1000) return 99;
    return 199;
  }
  
  // Расчет сервисного сбора
  double calculateServiceFee() {
    return totalPrice * 0.05; // 5% от стоимости заказа
  }
  
  // Расчет итоговой суммы заказа
  double calculateTotalAmount() {
    return totalPrice + calculateDeliveryFee() + calculateServiceFee();
  }
  
  // Сохранение корзины
  Future<void> _saveCart() async {
    try {
      await _cartService.saveCart(_items);
    } catch (error) {
      _setError('Не удалось сохранить корзину: $error');
    }
  }
  
  // Вспомогательные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    
    return true;
  }
  
  bool _areSelectedOptionsEqual(List<SelectedOption> list1, List<SelectedOption> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].name != list2[i].name || 
          list1[i].choices.length != list2[i].choices.length) {
        return false;
      }
      
      for (int j = 0; j < list1[i].choices.length; j++) {
        if (list1[i].choices[j].name != list2[i].choices[j].name) {
          return false;
        }
      }
    }
    
    return true;
  }
} 