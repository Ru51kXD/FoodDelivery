import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'current_user';
  final Uuid _uuid = const Uuid();
  
  // Создание пользователя по умолчанию
  User createDefaultUser() {
    return User(
      id: _uuid.v4(),
      name: 'Гость',
      email: 'guest@example.com',
      phone: '',
      addresses: [],
      paymentMethods: [],
      favoriteRestaurants: [],
      favoriteFoods: [],
      orders: [],
      isEmailVerified: false,
      isPhoneVerified: false,
    );
  }
  
  // Получение текущего пользователя из хранилища
  Future<User?> getCurrentUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString(_userKey);
      
      if (userData == null || userData.isEmpty) {
        return null;
      }
      
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      print('Ошибка при получении данных пользователя: $e');
      return null;
    }
  }
  
  // Сохранение пользователя в хранилище
  Future<void> saveUser(User user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Ошибка при сохранении данных пользователя: $e');
      throw Exception('Не удалось сохранить данные пользователя');
    }
  }
  
  // Авторизация пользователя (в настоящем приложении здесь был бы запрос к API)
  Future<User> login(String email, String password) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Проверка учетных данных (в реальном приложении здесь был бы запрос к серверу)
    if (email == 'demo@example.com' && password == 'password123') {
      // Создаем демо-пользователя
      final user = User(
        id: _uuid.v4(),
        name: 'Иван Иванов',
        email: email,
        phone: '+7 (999) 123-45-67',
        avatarUrl: 'https://randomuser.me/api/portraits/men/43.jpg',
        addresses: [
          Address(
            id: '1',
            title: 'Дом',
            fullAddress: 'ул. Пушкина, д. 10, кв. 5',
            street: 'ул. Пушкина, д. 10',
            city: 'Москва',
            postalCode: '123456',
            country: 'Россия',
            apartment: '5',
            floor: '2',
            isDefault: true,
          ),
          Address(
            id: '2',
            title: 'Работа',
            fullAddress: 'Проспект Мира, д. 25, офис 301',
            street: 'Проспект Мира, д. 25',
            city: 'Москва',
            postalCode: '123456',
            country: 'Россия',
            isDefault: false,
          ),
        ],
        paymentMethods: [
          PaymentMethod(
            id: '1',
            type: PaymentType.card,
            title: 'Visa •••• 1234',
            cardBrand: 'Visa',
            last4: '1234',
            expiryMonth: '12',
            expiryYear: '2025',
            isDefault: true,
          ),
          PaymentMethod(
            id: '2',
            type: PaymentType.cash,
            title: 'Наличные',
            isDefault: false,
          ),
        ],
        isEmailVerified: true,
        isPhoneVerified: true,
      );
      
      // Сохраняем в локальном хранилище
      await saveUser(user);
      
      return user;
    } else {
      throw Exception('Неверный email или пароль');
    }
  }
  
  // Регистрация нового пользователя
  Future<User> register(String name, String email, String password, String phone) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Проверка, что email не занят (в реальном приложении)
    if (email == 'demo@example.com') {
      throw Exception('Этот email уже используется');
    }
    
    // Создаем нового пользователя
    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      phone: phone,
      addresses: [],
      paymentMethods: [],
      isEmailVerified: false,
      isPhoneVerified: false,
    );
    
    // Сохраняем в локальном хранилище
    await saveUser(user);
    
    return user;
  }
  
  // Выход из системы (удаление данных пользователя)
  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Ошибка при выходе из системы: $e');
      throw Exception('Не удалось выйти из системы');
    }
  }
  
  // Обновление информации о пользователе
  Future<User> updateUserInfo(
    String userId, {
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Обновляем данные
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при обновлении данных пользователя: $e');
      throw Exception('Не удалось обновить данные пользователя');
    }
  }
  
  // Добавление нового адреса
  Future<User> addAddress(String userId, Address address) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Если новый адрес отмечен как "по умолчанию", обновляем все существующие
      List<Address> updatedAddresses = [...currentUser.addresses];
      if (address.isDefault) {
        updatedAddresses = updatedAddresses.map((a) => 
          a.copyWith(isDefault: false)
        ).toList();
      }
      
      // Добавляем новый адрес
      updatedAddresses.add(address);
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        addresses: updatedAddresses,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при добавлении адреса: $e');
      throw Exception('Не удалось добавить адрес');
    }
  }
  
  // Обновление существующего адреса
  Future<User> updateAddress(String userId, Address address) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Находим индекс обновляемого адреса
      final index = currentUser.addresses.indexWhere((a) => a.id == address.id);
      
      if (index == -1) {
        throw Exception('Адрес не найден');
      }
      
      // Обновляем список адресов
      List<Address> updatedAddresses = [...currentUser.addresses];
      
      // Если обновленный адрес отмечен как "по умолчанию", обновляем все остальные
      if (address.isDefault) {
        updatedAddresses = updatedAddresses.map((a) => 
          a.id != address.id ? a.copyWith(isDefault: false) : a
        ).toList();
      }
      
      // Заменяем адрес в списке
      updatedAddresses[index] = address;
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        addresses: updatedAddresses,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при обновлении адреса: $e');
      throw Exception('Не удалось обновить адрес');
    }
  }
  
  // Удаление адреса
  Future<User> removeAddress(String userId, String addressId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Удаляем адрес из списка
      final updatedAddresses = currentUser.addresses
          .where((address) => address.id != addressId)
          .toList();
      
      // Если был удален адрес по умолчанию и есть другие адреса, устанавливаем первый как "по умолчанию"
      if (currentUser.addresses.any((a) => a.id == addressId && a.isDefault) &&
          updatedAddresses.isNotEmpty) {
        updatedAddresses.first = updatedAddresses.first.copyWith(isDefault: true);
      }
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        addresses: updatedAddresses,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при удалении адреса: $e');
      throw Exception('Не удалось удалить адрес');
    }
  }
  
  // Добавление нового метода оплаты
  Future<User> addPaymentMethod(String userId, PaymentMethod paymentMethod) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Если новый метод отмечен как "по умолчанию", обновляем все существующие
      List<PaymentMethod> updatedPaymentMethods = [...currentUser.paymentMethods];
      if (paymentMethod.isDefault) {
        updatedPaymentMethods = updatedPaymentMethods.map((m) => 
          m.copyWith(isDefault: false)
        ).toList();
      }
      
      // Добавляем новый метод оплаты
      updatedPaymentMethods.add(paymentMethod);
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        paymentMethods: updatedPaymentMethods,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при добавлении метода оплаты: $e');
      throw Exception('Не удалось добавить метод оплаты');
    }
  }
  
  // Удаление метода оплаты
  Future<User> removePaymentMethod(String userId, String paymentMethodId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Удаляем метод оплаты из списка
      final updatedPaymentMethods = currentUser.paymentMethods
          .where((method) => method.id != paymentMethodId)
          .toList();
      
      // Если был удален метод по умолчанию и есть другие методы, устанавливаем первый как "по умолчанию"
      if (currentUser.paymentMethods.any((m) => m.id == paymentMethodId && m.isDefault) &&
          updatedPaymentMethods.isNotEmpty) {
        updatedPaymentMethods.first = updatedPaymentMethods.first.copyWith(isDefault: true);
      }
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        paymentMethods: updatedPaymentMethods,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при удалении метода оплаты: $e');
      throw Exception('Не удалось удалить метод оплаты');
    }
  }
  
  // Добавление ресторана в избранное
  Future<User> addFavoriteRestaurant(String userId, String restaurantId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Проверяем, не добавлен ли уже ресторан в избранное
      if (currentUser.favoriteRestaurants.contains(restaurantId)) {
        return currentUser; // Уже в избранном
      }
      
      // Добавляем ресторан в избранное
      final updatedFavorites = [...currentUser.favoriteRestaurants, restaurantId];
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        favoriteRestaurants: updatedFavorites,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при добавлении ресторана в избранное: $e');
      throw Exception('Не удалось добавить ресторан в избранное');
    }
  }
  
  // Удаление ресторана из избранного
  Future<User> removeFavoriteRestaurant(String userId, String restaurantId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Удаляем ресторан из избранного
      final updatedFavorites = currentUser.favoriteRestaurants
          .where((id) => id != restaurantId)
          .toList();
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        favoriteRestaurants: updatedFavorites,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при удалении ресторана из избранного: $e');
      throw Exception('Не удалось удалить ресторан из избранного');
    }
  }
  
  // Добавление блюда в избранное
  Future<User> addFavoriteFood(String userId, String foodId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Проверяем, не добавлено ли уже блюдо в избранное
      if (currentUser.favoriteFoods.contains(foodId)) {
        return currentUser; // Уже в избранном
      }
      
      // Добавляем блюдо в избранное
      final updatedFavorites = [...currentUser.favoriteFoods, foodId];
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        favoriteFoods: updatedFavorites,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при добавлении блюда в избранное: $e');
      throw Exception('Не удалось добавить блюдо в избранное');
    }
  }
  
  // Удаление блюда из избранного
  Future<User> removeFavoriteFood(String userId, String foodId) async {
    try {
      // Получаем текущего пользователя
      final currentUser = await getCurrentUser();
      
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Пользователь не найден');
      }
      
      // Удаляем блюдо из избранного
      final updatedFavorites = currentUser.favoriteFoods
          .where((id) => id != foodId)
          .toList();
      
      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        favoriteFoods: updatedFavorites,
      );
      
      // Сохраняем обновленные данные
      await saveUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('Ошибка при удалении блюда из избранного: $e');
      throw Exception('Не удалось удалить блюдо из избранного');
    }
  }
} 