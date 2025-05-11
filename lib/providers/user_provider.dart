import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  
  // Общая инициализация для LoadingScreen
  Future<void> init() async {
    return initUser();
  }
  
  // Инициализация пользователя
  Future<void> initUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Добавляем timeout для операции БД, чтобы не зависало бесконечно
      _user = await _databaseService.getCurrentUser().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print("Database operation timed out, creating default user");
          return _createDefaultUser();
        },
      );
      
      // Если пользователь не найден, создаем демо-пользователя
      if (_user == null) {
        _user = _createDefaultUser();
      }
    } catch (e) {
      _error = e.toString();
      print("Error in initUser: $e - Creating default user");
      // В случае любой ошибки создаем дефолтного пользователя
      _user = _createDefaultUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Создание дефолтного пользователя без обращения к БД
  User _createDefaultUser() {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Гость',
      email: 'guest@example.com',
      phone: '+7 (999) 123-45-67',
      address: 'Улица Примерная, 1',
    );
  }
  
  // Обновление информации о пользователе
  Future<void> updateUser({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedUser = _user!.copyWith(
        name: name,
        email: email,
        phone: phone,
        address: address,
        avatarUrl: avatarUrl,
      );
      
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Добавление ресторана в избранное
  Future<void> addFavoriteRestaurant(String restaurantId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedFavorites = [..._user!.favoriteRestaurants, restaurantId];
      final updatedUser = _user!.copyWith(favoriteRestaurants: updatedFavorites);
      
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление ресторана из избранного
  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedFavorites = _user!.favoriteRestaurants
          .where((id) => id != restaurantId)
          .toList();
      
      final updatedUser = _user!.copyWith(favoriteRestaurants: updatedFavorites);
      
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Переключение ресторана в избранное/из избранного
  Future<void> toggleFavoriteRestaurant(String restaurantId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    if (_user!.favoriteRestaurants.contains(restaurantId)) {
      await removeFavoriteRestaurant(restaurantId);
    } else {
      await addFavoriteRestaurant(restaurantId);
    }
  }
  
  // Добавление блюда в избранное
  Future<void> addFavoriteFood(String foodId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedFavorites = [..._user!.favoriteFoods, foodId];
      final updatedUser = _user!.copyWith(favoriteFoods: updatedFavorites);
      
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление блюда из избранного
  Future<void> removeFavoriteFood(String foodId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedFavorites = _user!.favoriteFoods
          .where((id) => id != foodId)
          .toList();
      
      final updatedUser = _user!.copyWith(favoriteFoods: updatedFavorites);
      
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Переключение блюда в избранное/из избранного
  Future<void> toggleFavoriteFood(String foodId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    if (_user!.favoriteFoods.contains(foodId)) {
      await removeFavoriteFood(foodId);
    } else {
      await addFavoriteFood(foodId);
    }
  }
  
  // Выход из учетной записи
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = null;
      // Создаем нового гостевого пользователя
      _user = _createDefaultUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Вход в учетную запись
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Создаем пользователя с указанным email - без обращения к БД
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Пользователь',
        email: email,
        phone: '+7 (999) 123-45-67',
        address: 'Улица Примерная, 1',
      );
    } catch (e) {
      _error = e.toString();
      print("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Вставка пользователя в БД (обёртка над сервисом БД)
  Future<void> _insertUser(User user) async {
    try {
      // Используем Future.delayed с таймаутом
      bool completed = false;
      
      Future.delayed(const Duration(seconds: 2), () {
        if (!completed) {
          print("Database operation timed out in _insertUser");
          return;
        }
      });
      
      // Проверяем наличие пользователя
      final existingUser = await _databaseService.getCurrentUser();
      print("Existing user check: ${existingUser?.id ?? 'no user found'}");
      
      // Если пользователь уже существует, обновляем его
      if (existingUser != null) {
        print("Updating existing user: ${existingUser.id}");
        await _databaseService.updateUser(user);
      } else {
        // Вставляем нового пользователя через инсерт в БД
        print("Inserting new user with ID: ${user.id}");
        final db = await _databaseService.database;
        await db.insert('users', user.toMap());
      }
      
      completed = true;
      print("User operation completed successfully");
    } catch (e) {
      print("Error in _insertUser: $e");
      // Не выбрасываем исключение, чтобы не блокировать основной поток
    }
  }
  
  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Принудительный сброс состояния загрузки в случае таймаута
  void forceResetLoadingState() {
    if (_isLoading) {
      print("Force resetting loading state due to timeout");
      _isLoading = false;
      notifyListeners();
    }
  }
} 