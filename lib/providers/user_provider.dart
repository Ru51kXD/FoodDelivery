import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  
  // Инициализация пользователя при запуске приложения
  Future<void> initUser() async {
    _setLoading(true);
    try {
      _user = await _userService.getCurrentUser();
      
      // Если пользователь не найден, создаем гостевой аккаунт
      if (_user == null) {
        _user = _userService.createDefaultUser();
        await _userService.saveUser(_user!);
      }
      
      notifyListeners();
    } catch (error) {
      _setError('Не удалось загрузить данные пользователя: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Авторизация пользователя
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _userService.login(email, password);
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Ошибка авторизации: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Регистрация нового пользователя
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      _user = await _userService.register(name, email, password, phoneNumber);
      notifyListeners();
      return true;
    } catch (error) {
      _setError('Ошибка регистрации: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Выход из аккаунта
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _userService.logout();
      _user = null;
      notifyListeners();
    } catch (error) {
      _setError('Ошибка при выходе из аккаунта: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Обновление информации о пользователе
  Future<void> updateUserInfo({
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.updateUserInfo(
        _user!.id,
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        avatarUrl: avatarUrl ?? _user!.avatarUrl,
      );
      notifyListeners();
    } catch (error) {
      _setError('Не удалось обновить информацию: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление нового адреса
  Future<void> addAddress(Address address) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.addAddress(_user!.id, address);
      notifyListeners();
    } catch (error) {
      _setError('Не удалось добавить адрес: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Обновление адреса
  Future<void> updateAddress(Address address) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.updateAddress(_user!.id, address);
      notifyListeners();
    } catch (error) {
      _setError('Не удалось обновить адрес: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Удаление адреса
  Future<void> removeAddress(String addressId) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.removeAddress(_user!.id, addressId);
      notifyListeners();
    } catch (error) {
      _setError('Не удалось удалить адрес: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление способа оплаты
  Future<void> addPaymentMethod(PaymentMethod paymentMethod) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.addPaymentMethod(_user!.id, paymentMethod);
      notifyListeners();
    } catch (error) {
      _setError('Не удалось добавить способ оплаты: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Удаление способа оплаты
  Future<void> removePaymentMethod(String paymentMethodId) async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      _user = await _userService.removePaymentMethod(_user!.id, paymentMethodId);
      notifyListeners();
    } catch (error) {
      _setError('Не удалось удалить способ оплаты: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление/удаление ресторана из избранного
  Future<void> toggleFavoriteRestaurant(String restaurantId) async {
    if (_user == null) return;
    
    final isFavorite = _user!.favoriteRestaurants.contains(restaurantId);
    
    _setLoading(true);
    try {
      if (isFavorite) {
        _user = await _userService.removeFavoriteRestaurant(_user!.id, restaurantId);
      } else {
        _user = await _userService.addFavoriteRestaurant(_user!.id, restaurantId);
      }
      notifyListeners();
    } catch (error) {
      _setError('Не удалось обновить избранное: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление/удаление блюда из избранного
  Future<void> toggleFavoriteFood(String foodId) async {
    if (_user == null) return;
    
    final isFavorite = _user!.favoriteFoods.contains(foodId);
    
    _setLoading(true);
    try {
      if (isFavorite) {
        _user = await _userService.removeFavoriteFood(_user!.id, foodId);
      } else {
        _user = await _userService.addFavoriteFood(_user!.id, foodId);
      }
      notifyListeners();
    } catch (error) {
      _setError('Не удалось обновить избранное: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Добавление тестовых заказов для отображения в профиле (для демонстрации)
  Future<void> addTestOrders() async {
    if (_user == null) return;
    
    // Здесь должна быть логика добавления тестовых заказов
    // В реальном приложении заказы будут приходить с сервера
    
    // Сейчас просто обновим пользователя для инициализации
    notifyListeners();
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
} 