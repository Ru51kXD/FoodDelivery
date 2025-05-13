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
  bool _dbAvailable = true; // Флаг доступности базы данных
  
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
  
  // Публичный метод инициализации корзины для LoadingScreen
  Future<void> initCart() async {
    return _loadCart();
  }
  
  // Загрузка корзины
  Future<void> _loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Пробуем загрузить из базы данных с таймаутом
      _items = await _loadCartWithTimeout();
    } catch (e) {
      _error = e.toString();
      _dbAvailable = false;
      print("Ошибка при загрузке корзины: $_error. Используем локальное хранилище.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод загрузки корзины с таймаутом
  Future<List<CartItem>> _loadCartWithTimeout() async {
    try {
      return await Future.any([
        _databaseService.getCartItems(),
        Future.delayed(const Duration(seconds: 2), () {
          // Если БД не ответила за 2 секунды, считаем её недоступной
          _dbAvailable = false;
          throw TimeoutException("Timeout loading cart from database");
        })
      ]);
    } catch (e) {
      _dbAvailable = false;
      print("База данных недоступна: $e");
      return [];
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
        
        // Сохраняем в БД, если она доступна
        if (_dbAvailable) {
          try {
            await _databaseService.updateCartItem(updatedItem).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                _dbAvailable = false;
                throw TimeoutException("Timeout updating cart item");
              }
            );
          } catch (dbError) {
            _dbAvailable = false;
            print("Ошибка при обновлении элемента корзины в БД: $dbError. Продолжаем работу с локальными данными.");
          }
        }
      } else {
        // Если товара нет, создаем новый элемент корзины
        final newItem = CartItem(
          id: _uuid.v4(),
          food: food,
          quantity: quantity,
        );
        _items.add(newItem);
        
        // Сохраняем в БД, если она доступна
        if (_dbAvailable) {
          try {
            await _databaseService.insertCartItem(newItem).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                _dbAvailable = false;
                throw TimeoutException("Timeout inserting cart item");
              }
            );
          } catch (dbError) {
            _dbAvailable = false;
            print("Ошибка при добавлении элемента корзины в БД: $dbError. Продолжаем работу с локальными данными.");
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      print("Общая ошибка при добавлении товара в корзину: $_error");
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
      
      // Удаляем из БД, если она доступна
      if (_dbAvailable) {
        try {
          await _databaseService.deleteCartItem(itemId).timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              _dbAvailable = false;
              throw TimeoutException("Timeout deleting cart item");
            }
          );
        } catch (dbError) {
          _dbAvailable = false;
          print("Ошибка при удалении элемента корзины из БД: $dbError. Продолжаем работу с локальными данными.");
        }
      }
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
        
        // Обновляем в БД, если она доступна
        if (_dbAvailable) {
          try {
            await _databaseService.updateCartItem(updatedItem).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                _dbAvailable = false;
                throw TimeoutException("Timeout updating cart item quantity");
              }
            );
          } catch (dbError) {
            _dbAvailable = false;
            print("Ошибка при обновлении количества в БД: $dbError. Продолжаем работу с локальными данными.");
          }
        }
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
      
      // Очищаем БД, если она доступна
      if (_dbAvailable) {
        try {
          await _databaseService.clearCart().timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              _dbAvailable = false;
              throw TimeoutException("Timeout clearing cart");
            }
          );
        } catch (dbError) {
          _dbAvailable = false;
          print("Ошибка при очистке корзины в БД: $dbError. Продолжаем работу с локальными данными.");
        }
      }
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

// Исключение для таймаута
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
} 