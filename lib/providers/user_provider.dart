import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

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
      addresses: [], // Пустой список адресов
      paymentMethods: [], // Пустой список способов оплаты
    );
  }
  
  // Регистрация нового пользователя
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Создаем пользователя с указанным email и именем
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: '', // Можно добавить телефон при регистрации или позже
        address: '', // Адрес можно добавить позже
        isEmailVerified: false, // По умолчанию email не подтвержден
        addresses: [], // Пустой список адресов
        paymentMethods: [], // Пустой список способов оплаты
      );
      
      // Минимальная задержка для имитации сетевого запроса
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Пропускаем сохранение в БД в основном потоке
      // и сразу устанавливаем пользователя
      _user = newUser;
      
      // Запускаем сохранение в БД в фоне без ожидания
      _startBackgroundUserSave(newUser);
      
      print("Пользователь успешно зарегистрирован: ${newUser.name}");
    } catch (e) {
      _error = e.toString();
      print("Registration error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Фоновое сохранение пользователя
  void _startBackgroundUserSave(User user) {
    Future(() async {
      try {
        await _insertUser(user).timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            print("Database operation timed out in background save");
            return;
          }
        );
      } catch (e) {
        print("Background user save error: $e");
      }
    });
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
      // Сначала полностью сбрасываем пользователя
      _user = null;
      
      // Для безопасности пытаемся очистить данные в базе
      try {
        // Не ждем ответа от базы чтобы не блокировать выход
        _databaseService.clearUserSession().timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            print("Очистка сессии в БД прервана по таймауту");
            return;
          }
        );
      } catch (dbError) {
        print("Ошибка при очистке сессии в БД: $dbError");
        // Игнорируем ошибки с базой данных
      }
      
      // Создаем нового гостевого пользователя
      await Future.delayed(const Duration(milliseconds: 100)); // Короткая пауза
      _user = _createDefaultUser();
      
      print("Пользователь успешно вышел из системы");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при выходе: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Полный сброс состояния приложения
  Future<void> resetApplicationState() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Сбрасываем пользователя
      _user = null;
      
      // Создаем нового гостевого пользователя
      _user = _createDefaultUser();
      
      print("Состояние приложения полностью сброшено");
    } catch (e) {
      print("Ошибка при сбросе состояния: $e");
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
      // В реальном приложении здесь был бы запрос к API для аутентификации
      await Future.delayed(const Duration(milliseconds: 1000)); // Имитация задержки сети
      
      // Проверяем, существует ли пользователь с таким email в БД
      try {
        final existingUser = await _databaseService.getUserByEmail(email);
        if (existingUser != null) {
          _user = existingUser;
        } else {
          // Если пользователь не найден в БД, используем временные данные
          _user = User(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Пользователь',
            email: email,
            phone: '+7 (999) 123-45-67',
            address: 'Улица Примерная, 1',
            addresses: [], // Пустой список адресов
            paymentMethods: [], // Пустой список способов оплаты
          );
          
          // Сохраняем пользователя в БД
          await _insertUser(_user!);
        }
      } catch (dbError) {
        print("Ошибка при работе с БД: $dbError");
        // В случае ошибки БД создаем пользователя в памяти
        _user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Пользователь',
          email: email,
          phone: '+7 (999) 123-45-67',
          address: 'Улица Примерная, 1',
          addresses: [], // Пустой список адресов
          paymentMethods: [], // Пустой список способов оплаты
        );
      }
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
  
  // === Управление адресами доставки ===
  
  // Добавление нового адреса доставки
  Future<void> addAddress(Address address) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Если новый адрес указан как адрес по умолчанию, сбрасываем флаг у других адресов
      List<Address> updatedAddresses = [..._user!.addresses];
      
      if (address.isDefault) {
        updatedAddresses = updatedAddresses.map((addr) => 
          addr.copyWith(isDefault: false)
        ).toList();
      } else if (updatedAddresses.isEmpty) {
        // Если это первый адрес, делаем его по умолчанию
        address = address.copyWith(isDefault: true);
      }
      
      // Добавляем новый адрес
      updatedAddresses.add(address);
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Адрес успешно добавлен: ${address.street}");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при добавлении адреса: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Обновление существующего адреса
  Future<void> updateAddress(Address address) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Находим индекс адреса по id
      final addressIndex = _user!.addresses.indexWhere((addr) => addr.id == address.id);
      
      if (addressIndex == -1) {
        throw Exception('Адрес не найден');
      }
      
      // Создаем новый список адресов
      List<Address> updatedAddresses = [..._user!.addresses];
      
      // Если адрес становится адресом по умолчанию, обновляем все остальные
      if (address.isDefault) {
        updatedAddresses = updatedAddresses.map((addr) => 
          addr.id == address.id ? address : addr.copyWith(isDefault: false)
        ).toList();
      } else {
        // Если снимается флаг "по умолчанию" с единственного адреса по умолчанию,
        // не позволяем это сделать
        if (updatedAddresses[addressIndex].isDefault) {
          final hasAnotherDefault = updatedAddresses.any((addr) => 
            addr.id != address.id && addr.isDefault
          );
          
          if (!hasAnotherDefault) {
            address = address.copyWith(isDefault: true);
          }
        }
        
        // Обновляем адрес в списке
        updatedAddresses[addressIndex] = address;
      }
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Адрес успешно обновлен: ${address.street}");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при обновлении адреса: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление адреса
  Future<void> removeAddress(String addressId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Проверяем существование адреса
      final addressToRemove = _user!.addresses.firstWhere(
        (addr) => addr.id == addressId,
        orElse: () => throw Exception('Адрес не найден'),
      );
      
      // Удаляем адрес из списка
      List<Address> updatedAddresses = _user!.addresses
          .where((addr) => addr.id != addressId)
          .toList();
      
      // Если был удален адрес по умолчанию и есть другие адреса, устанавливаем первый как "по умолчанию"
      if (addressToRemove.isDefault && updatedAddresses.isNotEmpty) {
        updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      }
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Адрес успешно удален");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при удалении адреса: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Установить адрес по умолчанию
  Future<void> setDefaultAddress(String addressId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Проверяем существование адреса
      final addressExists = _user!.addresses.any((addr) => addr.id == addressId);
      
      if (!addressExists) {
        throw Exception('Адрес не найден');
      }
      
      // Обновляем список адресов, устанавливая флаг "по умолчанию"
      final updatedAddresses = _user!.addresses.map((addr) => 
        addr.id == addressId ? addr.copyWith(isDefault: true) : addr.copyWith(isDefault: false)
      ).toList();
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Адрес по умолчанию успешно установлен");
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print("Ошибка при установке адреса по умолчанию: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // === Управление способами оплаты ===
  
  // Добавление нового способа оплаты
  Future<void> addPaymentMethod(PaymentMethod method) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Если новый метод отмечен как "по умолчанию", обновляем все существующие
      List<PaymentMethod> updatedMethods = [..._user!.paymentMethods];
      
      if (method.isDefault) {
        updatedMethods = updatedMethods.map((m) => 
          m.copyWith(isDefault: false)
        ).toList();
      } else if (updatedMethods.isEmpty) {
        // Если это первый метод оплаты, делаем его по умолчанию
        method = method.copyWith(isDefault: true);
      }
      
      // Добавляем новый метод оплаты
      updatedMethods.add(method);
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(paymentMethods: updatedMethods);
      
      // Сначала обновляем пользователя локально 
      _user = updatedUser;
      notifyListeners(); // Уведомляем слушателей сразу
      
      // Затем сохраняем в БД с таймаутом
      await _databaseService.updateUser(updatedUser).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("Database update for payment method timed out");
          // Даже если БД не ответила, данные в памяти уже обновлены
          return;
        }
      );
      
      print("Способ оплаты успешно добавлен: ${method.title}");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при добавлении способа оплаты: $_error");
      rethrow; // Пробрасываем ошибку выше для обработки в UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Удаление способа оплаты
  Future<void> removePaymentMethod(String methodId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Проверяем существование метода оплаты
      final methodToRemove = _user!.paymentMethods.firstWhere(
        (method) => method.id == methodId,
        orElse: () => throw Exception('Способ оплаты не найден'),
      );
      
      // Удаляем метод из списка
      List<PaymentMethod> updatedMethods = _user!.paymentMethods
          .where((method) => method.id != methodId)
          .toList();
      
      // Если был удален метод по умолчанию и есть другие методы, устанавливаем первый как "по умолчанию"
      if (methodToRemove.isDefault && updatedMethods.isNotEmpty) {
        updatedMethods[0] = updatedMethods[0].copyWith(isDefault: true);
      }
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(paymentMethods: updatedMethods);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Способ оплаты успешно удален");
    } catch (e) {
      _error = e.toString();
      print("Ошибка при удалении способа оплаты: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Установить способ оплаты по умолчанию
  Future<void> setDefaultPaymentMethod(String methodId) async {
    if (_user == null) {
      _error = 'Пользователь не авторизован';
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Проверяем существование метода оплаты
      final methodExists = _user!.paymentMethods.any((method) => method.id == methodId);
      
      if (!methodExists) {
        throw Exception('Способ оплаты не найден');
      }
      
      // Обновляем список методов, устанавливая флаг "по умолчанию"
      final updatedMethods = _user!.paymentMethods.map((method) => 
        method.id == methodId ? method.copyWith(isDefault: true) : method.copyWith(isDefault: false)
      ).toList();
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(paymentMethods: updatedMethods);
      await _databaseService.updateUser(updatedUser);
      _user = updatedUser;
      
      print("Способ оплаты по умолчанию успешно установлен");
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print("Ошибка при установке способа оплаты по умолчанию: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Прямое добавление карты (упрощенный метод)
  Future<void> directAddPaymentMethod(PaymentMethod method) async {
    if (_user == null) {
      throw Exception('Пользователь не авторизован');
    }
    
    try {
      // Создаем копию списка методов оплаты
      List<PaymentMethod> updatedMethods = [..._user!.paymentMethods];
      
      // Если добавляемый метод - по умолчанию, обновляем статус существующих
      if (method.isDefault) {
        updatedMethods = updatedMethods.map((m) => 
          m.copyWith(isDefault: false)
        ).toList();
      } else if (updatedMethods.isEmpty) {
        // Если это первый метод оплаты, делаем его по умолчанию
        method = method.copyWith(isDefault: true);
      }
      
      // Добавляем метод в список
      updatedMethods.add(method);
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(paymentMethods: updatedMethods);
      _user = updatedUser;
      
      // Уведомляем UI
      notifyListeners();
      
      // Сохраняем в БД в фоновом режиме
      _databaseService.updateUser(updatedUser).catchError((e) {
        print("Error saving payment method to database: $e");
      });
      
      return;
    } catch (e) {
      print("Error in directAddPaymentMethod: $e");
      rethrow;
    }
  }
  
  // Прямое добавление адреса (упрощенный метод)
  Future<void> directAddAddress(Address address) async {
    if (_user == null) {
      throw Exception('Пользователь не авторизован');
    }
    
    try {
      // Создаем копию списка адресов
      List<Address> updatedAddresses = [..._user!.addresses];
      
      // Если новый адрес указан как адрес по умолчанию, сбрасываем флаг у других адресов
      if (address.isDefault) {
        updatedAddresses = updatedAddresses.map((addr) => 
          addr.copyWith(isDefault: false)
        ).toList();
      } else if (updatedAddresses.isEmpty) {
        // Если это первый адрес, делаем его по умолчанию
        address = address.copyWith(isDefault: true);
      }
      
      // Добавляем новый адрес
      updatedAddresses.add(address);
      
      // Обновляем пользователя
      final updatedUser = _user!.copyWith(addresses: updatedAddresses);
      _user = updatedUser;
      
      // Уведомляем UI
      notifyListeners();
      
      // Сохраняем в БД в фоновом режиме
      _databaseService.updateUser(updatedUser).catchError((e) {
        print("Error saving address to database: $e");
      });
      
      return;
    } catch (e) {
      print("Error in directAddAddress: $e");
      rethrow;
    }
  }
} 