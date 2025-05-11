import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/food.dart';
import '../models/selected_option.dart';
import '../services/database_service.dart';

class CartProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  
  CartProvider() {
    _loadCart();
  }
  
  // Геттеры
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  double get totalPrice => totalAmount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  
  // Загрузка корзины
  Future<void> _loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _databaseService.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Добавление товара в корзину
  Future<void> addItem(Food food, {int quantity = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Проверяем, есть ли уже такой товар в корзине
      final existingItemIndex = _items.indexWhere((item) => item.food.id == food.id);
      
      if (existingItemIndex >= 0) {
        // Если товар уже есть, увеличиваем количество
        final existingItem = _items[existingItemIndex];
        final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + quantity);
        _items[existingItemIndex] = updatedItem;
        await _databaseService.updateCartItem(updatedItem);
      } else {
        // Если товара нет, создаем новый элемент корзины
        final newItem = CartItem(
          id: _uuid.v4(),
          food: food,
          quantity: quantity,
        );
        _items.add(newItem);
        await _databaseService.insertCartItem(newItem);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление товара из корзины
  Future<void> removeItem(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items.removeWhere((item) => item.id == itemId);
      await _databaseService.deleteCartItem(itemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Обновление количества товара
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex >= 0) {
        final updatedItem = _items[itemIndex].copyWith(quantity: quantity);
        _items[itemIndex] = updatedItem;
        await _databaseService.updateCartItem(updatedItem);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Очистка корзины
  Future<void> clearCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items.clear();
      await _databaseService.clearCart();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Вспомогательные методы
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Алиасы для совместимости
  Future<void> addToCart(Food food, {int quantity = 1, String? specialInstructions, List<SelectedOption>? selectedOptions}) => 
      addItem(food, quantity: quantity);
  Future<void> removeFromCart(String itemId) => removeItem(itemId);
  Future<void> updateItemQuantity(String itemId, int quantity) => updateQuantity(itemId, quantity);

  // Проверка наличия товара в корзине
  bool hasItem(String foodId) {
    return _items.any((item) => item.food.id == foodId);
  }

  bool isInCart(String foodId) => hasItem(foodId);

  // Получение количества товара в корзине
  int getItemQuantity(String foodId) {
    final item = _items.firstWhere(
      (item) => item.food.id == foodId,
      orElse: () => CartItem(
        id: '',
        food: Food(
          id: '',
          name: '',
          description: '',
          imageUrl: '',
          price: 0,
          restaurantId: '',
          categories: [],
          isAvailable: true,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }
} 